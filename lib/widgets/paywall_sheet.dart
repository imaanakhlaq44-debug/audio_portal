import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/story.dart';
import '../models/story_data.dart';
import '../services/premium_service.dart';
import '../theme/app_theme.dart';
import 'contact_card.dart';

bool _paywallOpen = false;

/// Shows the Premium paywall over whatever is on screen.
///
/// [story] is what the listener was stopped at, which picks the headline:
/// the end of a free preview, or a locked episode. Only one paywall is shown
/// at a time, however many requests arrive.
Future<void> showPaywall(BuildContext context, {Story? story}) async {
  if (_paywallOpen) return;
  _paywallOpen = true;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _OpenWhileMounted(child: PaywallSheet(story: story)),
  );
}

/// Holds [_paywallOpen] true exactly as long as the sheet is on screen,
/// however the sheet goes away.
class _OpenWhileMounted extends StatefulWidget {
  final Widget child;
  const _OpenWhileMounted({required this.child});

  @override
  State<_OpenWhileMounted> createState() => _OpenWhileMountedState();
}

class _OpenWhileMountedState extends State<_OpenWhileMounted> {
  @override
  void dispose() {
    _paywallOpen = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Asks a simple multiplication before anything that signs in or spends
/// money, so a child tapping around cannot reach the Google Play checkout.
Future<bool> confirmGrownUp(BuildContext context, {Random? random}) async {
  final rng = random ?? Random();
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) =>
        _GrownUpDialog(a: 6 + rng.nextInt(4), b: 6 + rng.nextInt(4)),
  );
  return ok ?? false;
}

/// The question itself. A widget of its own so the text field's controller
/// lives exactly as long as the dialog, closing animation included.
class _GrownUpDialog extends StatefulWidget {
  final int a;
  final int b;
  const _GrownUpDialog({required this.a, required this.b});

  @override
  State<_GrownUpDialog> createState() => _GrownUpDialogState();
}

class _GrownUpDialogState extends State<_GrownUpDialog> {
  final _controller = TextEditingController();
  bool _wrong = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _check() {
    if (int.tryParse(_controller.text.trim()) == widget.a * widget.b) {
      Navigator.pop(context, true);
    } else {
      setState(() => _wrong = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.family_restroom, color: c.primaryDeep),
          const SizedBox(width: 10),
          const Expanded(child: Text('Ask a grown-up')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'To continue, please answer:',
            style: AppTheme.body(size: 14, color: c.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.a} × ${widget.b} = ?',
            style: AppTheme.headline(size: 28, color: c.headline),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 3,
            onSubmitted: (_) => _check(),
            decoration: InputDecoration(
              hintText: 'Answer',
              errorText: _wrong ? 'That is not right. Try again.' : null,
              counterText: '',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _check, child: const Text('Continue')),
      ],
    );
  }
}

/// Tells the parent how a purchase or restore went. Says nothing when they
/// cancelled.
Future<void> explainOutcome(BuildContext context, PremiumOutcome outcome) {
  final (title, message) = switch (outcome) {
    PremiumOutcome.unlocked => (
      'Welcome to Premium!',
      'Every episode of every series is now unlocked. Happy listening!',
    ),
    PremiumOutcome.pending => (
      'Payment pending',
      'Google Play is still confirming your payment. Premium unlocks by '
          'itself as soon as it goes through.',
    ),
    PremiumOutcome.nothingToRestore => (
      'No subscription found',
      'We could not find a Qissora Premium subscription on the Google Play '
          'account on this phone.',
    ),
    PremiumOutcome.signedIn => (
      'Signed in',
      'You are signed in with Google. There is no Premium subscription on '
          "this phone's Google Play account yet.",
    ),
    PremiumOutcome.unavailable => (
      'Google Play is not available',
      'Subscriptions could not be reached. Check the internet connection '
          'and that this phone is signed in to Google Play, then try again.',
    ),
    PremiumOutcome.failed => (
      'Something went wrong',
      'The subscription did not go through. Please try again. If you were '
          'charged, tap "Restore purchase" to unlock Premium.',
    ),
    PremiumOutcome.cancelled => ('', ''),
  };
  if (title.isEmpty) return Future.value();
  final canHelp =
      outcome == PremiumOutcome.unavailable || outcome == PremiumOutcome.failed;
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        if (canHelp)
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openWhatsApp(context);
            },
            child: const Text('WhatsApp us'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

/// Parent-gated subscribe or restore, with the outcome explained.
/// Returns true once Premium is unlocked.
///
/// Pass `gate: false` where a parent has already proved themselves, as in
/// the PIN-locked Parents area.
Future<bool> runPremiumAction(
  BuildContext context,
  Future<PremiumOutcome> Function() action, {
  bool gate = true,
}) async {
  if (gate && !await confirmGrownUp(context)) return false;
  final outcome = await action();
  if (!context.mounted) return outcome == PremiumOutcome.unlocked;
  await explainOutcome(context, outcome);
  return outcome == PremiumOutcome.unlocked;
}

class PaywallSheet extends StatelessWidget {
  final Story? story;

  const PaywallSheet({super.key, this.story});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final premium = context.read<PremiumService>();
    final story = this.story;
    final series = story == null ? null : StoryData.seriesOf(story);
    final previewEnded = story != null && premium.isPreview(story);
    final headline = previewEnded
        ? 'Want to hear what happens next?'
        : 'Unlock every story';
    final subline = switch ((previewEnded, series)) {
      (true, final s?) =>
        'That was the free preview of ${s.title}. Premium plays the whole '
            'story, and every other one.',
      (false, final s?) =>
        'This episode of ${s.title} is part of Qissora Premium.',
      _ => 'Every episode of every series, in English and Urdu.',
    };
    final seriesCount = StoryData.allSeries.length;
    final episodeCount = StoryData.allStories.length;

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- Header ----
            Container(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 26),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.light.primary,
                    AppColors.light.primaryDeep,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.workspace_premium,
                      color: AppColors.light.secondaryFixed,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.light.secondary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'QISSORA PREMIUM',
                      style: AppTheme.body(
                        size: 11,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ).copyWith(letterSpacing: 1.2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    headline,
                    textAlign: TextAlign.center,
                    style: AppTheme.headline(size: 24, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subline,
                    textAlign: TextAlign.center,
                    style: AppTheme.body(
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ).copyWith(height: 1.45),
                  ),
                ],
              ),
            ),

            // ---- Benefits ----
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
              child: Column(
                children: [
                  _Benefit(
                    icon: Icons.library_music_outlined,
                    tint: c.primaryFixed,
                    fg: c.primaryDeep,
                    title:
                        'All $seriesCount series, all $episodeCount '
                        'episodes',
                    subtitle:
                        'Stories of the Prophets and moral series, '
                        'from start to finish.',
                  ),
                  _Benefit(
                    icon: Icons.translate,
                    tint: c.secondaryFixed,
                    fg: c.secondaryDeep,
                    title: 'English and Urdu',
                    subtitle: 'Every story narrated in both languages.',
                  ),
                  _Benefit(
                    icon: Icons.auto_awesome_outlined,
                    tint: c.tertiaryFixed,
                    fg: c.tertiary,
                    title: 'New stories as they arrive',
                    subtitle: 'Fresh series are added to Premium for you.',
                  ),
                  _Benefit(
                    icon: Icons.verified_user_outlined,
                    tint: c.surfaceHigh,
                    fg: c.primaryDeep,
                    title: 'Safe for children',
                    subtitle: 'No ads, ever. Cancel anytime in Google Play.',
                  ),
                ],
              ),
            ),

            // ---- Plans and checkout ----
            const _Checkout(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () async {
                    final unlocked = await runPremiumAction(
                      context,
                      premium.restore,
                    );
                    if (unlocked && context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Restore purchase'),
                ),
                Text('•', style: TextStyle(color: c.outline)),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Not now',
                    style: TextStyle(color: c.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 20),
              child: Text(
                'For parents: signing in and subscribing need a grown-up. '
                'Payment is handled securely by Google Play.',
                textAlign: TextAlign.center,
                style: AppTheme.body(size: 12, color: c.outline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The plans Google Play offers, and the button that buys the chosen one.
class _Checkout extends StatefulWidget {
  const _Checkout();

  @override
  State<_Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<_Checkout> {
  String? _chosenId;
  bool _busy = false;

  Future<void> _buy(PremiumService premium, PremiumPlan? plan) async {
    // The spinner runs only while Google Play works: not during the
    // grown-up check before it, nor behind the result dialog after it.
    if (!await confirmGrownUp(context) || !mounted) return;
    setState(() => _busy = true);
    final PremiumOutcome outcome;
    try {
      outcome = await premium.subscribe(plan);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;
    await explainOutcome(context, outcome);
    if (outcome == PremiumOutcome.unlocked && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final premium = context.watch<PremiumService>();
    final plans = premium.plans;
    // Yearly is preselected: it is the better deal for families.
    final chosen =
        plans.where((p) => p.basePlanId == _chosenId).firstOrNull ??
        plans.where((p) => p.isAnnual).firstOrNull ??
        plans.firstOrNull;
    final monthly = plans.where((p) => !p.isAnnual).firstOrNull;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final plan in plans.reversed) ...[
            _PlanCard(
              plan: plan,
              selected: plan == chosen,
              saving: plan.isAnnual ? _saving(plan, monthly) : null,
              onTap: () => setState(() => _chosenId = plan.basePlanId),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 4),
          ElevatedButton.icon(
            onPressed: _busy ? null : () => _buy(premium, chosen),
            style: ElevatedButton.styleFrom(
              backgroundColor: c.secondary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.lock_open_rounded),
            label: Text(
              premium.isSignedIn ? 'Subscribe' : 'Continue with Google',
              style: AppTheme.body(
                size: 16,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// How much cheaper a year is than twelve months, as a whole percentage,
  /// or null when there is nothing to compare or no saving.
  static int? _saving(PremiumPlan annual, PremiumPlan? monthly) {
    if (monthly == null || monthly.currencyCode != annual.currencyCode) {
      return null;
    }
    final full = monthly.rawPrice * 12;
    if (full <= 0) return null;
    final pct = ((1 - annual.rawPrice / full) * 100).round();
    return pct > 0 ? pct : null;
  }
}

class _PlanCard extends StatelessWidget {
  final PremiumPlan plan;
  final bool selected;
  final int? saving;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.saving,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? c.primaryFixed : c.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? c.primary
                    : c.outlineVariant.withValues(alpha: 0.5),
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? c.primaryDeep : c.outline,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.isAnnual ? 'Yearly' : 'Monthly',
                            style: AppTheme.body(
                              size: 15,
                              weight: FontWeight.w700,
                              color: c.onSurface,
                            ),
                          ),
                          if (saving != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: c.secondary,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                'SAVE $saving%',
                                style: AppTheme.body(
                                  size: 10,
                                  weight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        plan.isAnnual ? 'Billed once a year' : 'Billed monthly',
                        style: AppTheme.body(
                          size: 12,
                          color: c.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  plan.price,
                  style: AppTheme.headline(size: 18, color: c.headline),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final Color fg;
  final String title;
  final String subtitle;

  const _Benefit({
    required this.icon,
    required this.tint,
    required this.fg,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: fg, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.body(
                    size: 15,
                    weight: FontWeight.w700,
                    color: c.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTheme.body(size: 13, color: c.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
