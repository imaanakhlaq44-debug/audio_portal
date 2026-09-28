import 'package:qissora/services/access_code_api.dart';

/// The code server in memory, following the same rules as api/: a VIP code
/// is for one family for a year; a school code gives each family a month,
/// up to its limit, and a family gets one school trial ever.
class FakeAccessCodeApi implements AccessCodeApi {
  FakeAccessCodeApi({
    Set<String> vip = const {},
    Map<String, int> school = const {},
    required this.now,
  }) : _vip = {...vip},
       _school = {...school};

  final Set<String> _vip;

  /// School code -> how many families may use it.
  final Map<String, int> _school;
  final DateTime Function() now;

  /// Makes every call fail as if the phone were offline.
  bool offline = false;
  final Set<String> revoked = {};

  /// (code, token) -> grant.
  final Map<(String, String), CodeGrant> _redeemed = {};
  int calls = 0;

  static String _key(String code) =>
      code.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');

  @override
  Future<CodeGrant> redeem(String code, String idToken) async {
    calls++;
    if (offline) throw const AccessCodeException(CodeError.offline);
    final key = _key(code);
    final kind = _vip.contains(key)
        ? CodeKind.vip
        : _school.containsKey(key)
        ? CodeKind.school
        : null;
    if (kind == null || revoked.contains(key)) {
      throw const AccessCodeException(CodeError.invalid);
    }
    if (_redeemed[(key, idToken)] case final mine?) {
      if (!now().isBefore(mine.expiresAt)) {
        throw const AccessCodeException(CodeError.expired);
      }
      return mine;
    }
    final uses = _redeemed.keys.where((k) => k.$1 == key).length;
    if (kind == CodeKind.school) {
      final hadTrial = _redeemed.entries.any(
        (e) => e.key.$2 == idToken && e.value.kind == CodeKind.school,
      );
      if (hadTrial) throw const AccessCodeException(CodeError.trialUsed);
      if (uses >= _school[key]!) {
        throw const AccessCodeException(CodeError.full);
      }
    } else if (uses >= 1) {
      throw const AccessCodeException(CodeError.used);
    }
    final grant = CodeGrant(
      kind: kind,
      expiresAt: now().add(Duration(days: kind == CodeKind.vip ? 365 : 30)),
      ticket: 'ticket-$key-$idToken',
    );
    _redeemed[(key, idToken)] = grant;
    return grant;
  }

  @override
  Future<CodeGrant?> restore(String idToken) async {
    calls++;
    if (offline) throw const AccessCodeException(CodeError.offline);
    CodeGrant? best;
    for (final MapEntry(key: (code, token), value: grant)
        in _redeemed.entries) {
      if (token != idToken || revoked.contains(code)) continue;
      if (!now().isBefore(grant.expiresAt)) continue;
      if (best == null || grant.expiresAt.isAfter(best.expiresAt)) {
        best = grant;
      }
    }
    return best;
  }

  @override
  Future<CodeGrant?> check(String ticket) async {
    calls++;
    if (offline) throw const AccessCodeException(CodeError.offline);
    for (final MapEntry(key: (code, _), value: grant) in _redeemed.entries) {
      if (grant.ticket != ticket) continue;
      return revoked.contains(code) || !now().isBefore(grant.expiresAt)
          ? null
          : grant;
    }
    return null;
  }
}
