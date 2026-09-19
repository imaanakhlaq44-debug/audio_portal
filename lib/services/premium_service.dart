import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../models/story.dart';
import '../models/story_data.dart';
import 'storage_service.dart';

/// How a purchase or restore ended.
enum PremiumOutcome {
  unlocked,
  cancelled,

  /// Google Play took the order but is still waiting for the money, e.g. a
  /// cash or bank payment. Premium unlocks by itself once it clears.
  pending,
  nothingToRestore,

  /// Signed in with Google, but this Google Play account has no
  /// subscription yet.
  signedIn,

  /// Google Play is not reachable here (no Play Store, offline, or the
  /// subscription is not published yet).
  unavailable,
  failed,
}

/// One way to pay for Premium, as Google Play prices it for this listener.
class PremiumPlan {
  final String basePlanId;

  /// Formatted by Google Play in the listener's own currency, e.g. "Rs 299".
  final String price;
  final double rawPrice;
  final String currencyCode;
  final ProductDetails details;

  const PremiumPlan({
    required this.basePlanId,
    required this.price,
    required this.rawPrice,
    required this.currencyCode,
    required this.details,
  });

  bool get isAnnual => basePlanId == PremiumService.annualPlanId;
}

/// Who may hear what, and the Google Play subscription behind it.
///
/// Free listeners get the first episode of every series, up to about its
/// halfway point; Premium opens everything. The access rules live here so the
/// player, the tiles and the paywall all agree.
///
/// Premium is the `qissora` subscription in Google Play, bought after the
/// parent signs in with Google. What Play reports is cached, so a subscriber
/// who opens the app offline keeps Premium until Play can be asked again.
class PremiumService extends ChangeNotifier {
  PremiumService._() : _live = true;

  /// A service with no Play Store or Google account behind it, for tests.
  @visibleForTesting
  PremiumService.forTesting() : _live = false;

  static final PremiumService instance = PremiumService._();

  /// The subscription's product ID in Play Console.
  static const String productId = 'qissora';
  static const String monthlyPlanId = 'monthly';
  static const String annualPlanId = 'annual';

  /// The OAuth web client of the Firebase project (qissora-22c32). Android
  /// sign-in needs it; it is an identifier, not a secret.
  static const String _serverClientId =
      '142720400050-m3tgskacv3te4ledpb5nrml02cnk2va8'
      '.apps.googleusercontent.com';

  final bool _live;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  Completer<PremiumOutcome>? _pendingPurchase;
  bool _sawActiveSubscription = false;
  bool _signInReady = false;

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  String? _accountEmail;

  /// The Google account a parent signed in with, if any.
  String? get accountEmail => _accountEmail;
  bool get isSignedIn => _accountEmail != null;

  List<PremiumPlan> _plans = const [];

  /// The plans Google Play offers this listener, cheapest period first.
  /// Empty until Play answers, or when it cannot be reached.
  List<PremiumPlan> get plans => _plans;

  /// Sets the entitlement directly, for tests.
  @visibleForTesting
  set isPremiumForTesting(bool value) => _setPremium(value, persist: false);

  @visibleForTesting
  set plansForTesting(List<PremiumPlan> value) {
    _plans = value;
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // Access rules
  // ------------------------------------------------------------------

  /// The one episode of each series free listeners can start.
  bool isPreview(Story story) {
    final episodes = StoryData.seriesOf(story)?.episodes;
    return episodes != null &&
        episodes.isNotEmpty &&
        episodes.first.id == story.id;
  }

  /// Whether [story] cannot be played at all without Premium.
  bool isLocked(Story story) => !_isPremium && !isPreview(story);

  /// Where a free listener's preview of [story] stops, or null when there
  /// is no limit (Premium, or a story that is locked outright).
  ///
  /// The cut falls at the end of the caption line that crosses the halfway
  /// point, so the preview ends on a finished sentence rather than mid-word.
  /// [duration] is the player's measured length, used when the story has no
  /// captions to go by.
  Duration? previewEnd(Story story, {Duration duration = Duration.zero}) {
    if (_isPremium || !isPreview(story)) return null;
    final captions = story.captions;
    if (captions.isEmpty) {
      return duration > Duration.zero ? duration ~/ 2 : null;
    }
    final half = captions.last.end ~/ 2;
    for (final line in captions) {
      if (line.end >= half) return line.end;
    }
    return half;
  }

  // ------------------------------------------------------------------
  // Google Play
  // ------------------------------------------------------------------

  /// Restores the cached state, then asks Google Play for prices and for any
  /// subscription this Play account already has. Call once at startup; it
  /// never throws and never shows UI.
  Future<void> init() async {
    _isPremium = StorageService.getCachedPremium();
    _accountEmail = StorageService.getAccountEmail();
    if (!_live) return;
    notifyListeners();

    try {
      if (!await _connect()) return;
      await _refreshFromPlay();
    } catch (e) {
      // Offline or Play Services missing: the cached state stands.
      if (kDebugMode) debugPrint('Premium init failed: $e');
    }
  }

  /// Listens to Play and loads the plans, if Play is reachable. Safe to call
  /// again after a failed start, e.g. when the phone was offline.
  Future<bool> _connect() async {
    final iap = InAppPurchase.instance;
    if (!await iap.isAvailable()) return false;
    _purchaseSub ??= iap.purchaseStream.listen(
      _onPurchases,
      onError: (Object e) {
        if (kDebugMode) debugPrint('purchaseStream error: $e');
      },
    );
    if (_plans.isEmpty) await _loadPlans();
    return true;
  }

  Future<void> _loadPlans() async {
    final response = await InAppPurchase.instance.queryProductDetails({
      productId,
    });
    final plans = <PremiumPlan>[];
    for (final d in response.productDetails) {
      if (d is! GooglePlayProductDetails) continue;
      final index = d.subscriptionIndex;
      final offers = d.productDetails.subscriptionOfferDetails;
      if (index == null || offers == null) continue;
      final offer = offers[index];
      // Base plans only; promotional offers would show a trial price here.
      if (offer.offerId != null) continue;
      if (offer.basePlanId != monthlyPlanId &&
          offer.basePlanId != annualPlanId) {
        continue;
      }
      plans.add(
        PremiumPlan(
          basePlanId: offer.basePlanId,
          price: d.price,
          rawPrice: d.rawPrice,
          currencyCode: d.currencyCode,
          details: d,
        ),
      );
    }
    plans.sort((a, b) => a.isAnnual == b.isAnnual ? 0 : (a.isAnnual ? 1 : -1));
    _plans = plans;
    notifyListeners();
  }

  /// Asks Play which subscriptions this account holds. Play only reports
  /// active ones, so hearing nothing back means Premium has lapsed.
  Future<bool> _refreshFromPlay() async {
    _sawActiveSubscription = false;
    await InAppPurchase.instance.restorePurchases();
    // The results arrive on the purchase stream just after the call returns.
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!_sawActiveSubscription && _isPremium) {
      _setPremium(false);
    }
    return _sawActiveSubscription;
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.productID != productId) continue;
      switch (p.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _sawActiveSubscription = true;
          _setPremium(true);
          _finish(PremiumOutcome.unlocked);
        case PurchaseStatus.pending:
          _finish(PremiumOutcome.pending);
        case PurchaseStatus.canceled:
          _finish(PremiumOutcome.cancelled);
        case PurchaseStatus.error:
          if (kDebugMode) debugPrint('Purchase error: ${p.error}');
          _finish(PremiumOutcome.failed);
      }
      // Acknowledges the purchase. Google refunds any subscription left
      // unacknowledged for three days.
      if (p.pendingCompletePurchase) {
        try {
          await InAppPurchase.instance.completePurchase(p);
        } catch (e) {
          if (kDebugMode) debugPrint('completePurchase failed: $e');
        }
      }
    }
  }

  void _finish(PremiumOutcome outcome) {
    final pending = _pendingPurchase;
    if (pending != null && !pending.isCompleted) pending.complete(outcome);
  }

  void _setPremium(bool value, {bool persist = true}) {
    if (persist && _live) StorageService.setCachedPremium(value);
    if (value == _isPremium) return;
    _isPremium = value;
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // Google account
  // ------------------------------------------------------------------

  /// Signs a parent in with Google, returning null if they backed out.
  Future<GoogleSignInAccount?> _signIn() async {
    final google = GoogleSignIn.instance;
    if (!_signInReady) {
      await google.initialize(serverClientId: _serverClientId);
      _signInReady = true;
    }
    try {
      final account = await google.authenticate();
      _accountEmail = account.email;
      await StorageService.setAccountEmail(account.email);
      notifyListeners();
      return account;
    } on GoogleSignInException catch (e) {
      if (kDebugMode) debugPrint('Google sign-in: ${e.code} ${e.description}');
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  /// Signs a parent in with Google from the Parents area, then checks Google
  /// Play for a subscription, so a family on a new phone gets Premium back
  /// in one step.
  Future<PremiumOutcome> signIn() async {
    if (!_live) return PremiumOutcome.unavailable;
    try {
      if (await _signIn() == null) return PremiumOutcome.cancelled;
    } catch (_) {
      return PremiumOutcome.failed;
    }
    final outcome = await restore();
    return outcome == PremiumOutcome.nothingToRestore
        ? PremiumOutcome.signedIn
        : outcome;
  }

  /// Signs out of Google. Premium stays: it belongs to the Google Play
  /// account on this phone, not to this sign-in.
  Future<void> signOut() async {
    if (_live && _signInReady) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
    }
    _accountEmail = null;
    await StorageService.setAccountEmail(null);
    notifyListeners();
  }

  /// Removes the Google account from the app and revokes its access. The
  /// subscription itself is cancelled in Google Play, not here.
  Future<void> deleteAccount() async {
    if (_live) {
      try {
        if (!_signInReady) {
          await GoogleSignIn.instance.initialize(
            serverClientId: _serverClientId,
          );
          _signInReady = true;
        }
        await GoogleSignIn.instance.disconnect();
      } catch (_) {}
    }
    await signOut();
  }

  // ------------------------------------------------------------------
  // Buying
  // ------------------------------------------------------------------

  /// Signs in with Google, then buys [plan] through Google Play.
  Future<PremiumOutcome> subscribe([PremiumPlan? plan]) async {
    if (!_live) return PremiumOutcome.unavailable;
    try {
      if (!await _connect()) return PremiumOutcome.unavailable;
    } catch (_) {
      return PremiumOutcome.unavailable;
    }
    final chosen = plan ?? (_plans.isEmpty ? null : _plans.last);
    if (chosen == null) return PremiumOutcome.unavailable;
    if (_pendingPurchase != null && !_pendingPurchase!.isCompleted) {
      return _pendingPurchase!.future;
    }

    final GoogleSignInAccount? account;
    try {
      account = await _signIn();
    } catch (_) {
      return PremiumOutcome.failed;
    }
    if (account == null) return PremiumOutcome.cancelled;

    final completer = _pendingPurchase = Completer<PremiumOutcome>();
    try {
      final started = await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: GooglePlayPurchaseParam(
          productDetails: chosen.details,
          // Ties the order to this Google account without handing Play the
          // account ID itself; the server checks it when verifying.
          applicationUserName: sha256
              .convert(utf8.encode(account.id))
              .toString(),
        ),
      );
      if (!started) _finish(PremiumOutcome.failed);
    } catch (e) {
      if (kDebugMode) debugPrint('buyNonConsumable failed: $e');
      _finish(PremiumOutcome.failed);
    }
    return completer.future;
  }

  /// Looks for a subscription this Google Play account already has.
  Future<PremiumOutcome> restore() async {
    if (!_live) return PremiumOutcome.unavailable;
    try {
      if (!await _connect()) return PremiumOutcome.unavailable;
      return await _refreshFromPlay()
          ? PremiumOutcome.unlocked
          : PremiumOutcome.nothingToRestore;
    } catch (_) {
      return PremiumOutcome.unavailable;
    }
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }
}
