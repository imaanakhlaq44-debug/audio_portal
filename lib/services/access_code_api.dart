import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// What a code was given for.
enum CodeKind {
  /// One family, for a year.
  vip,

  /// A code a school hands to all its families: a month each.
  school,
}

/// A redeemed code, as the server reports it.
class CodeGrant {
  final CodeKind kind;
  final DateTime expiresAt;

  /// Lets the app ask later whether the code still stands, without signing
  /// the parent in again.
  final String ticket;

  const CodeGrant({
    required this.kind,
    required this.expiresAt,
    required this.ticket,
  });
}

enum CodeError {
  /// No such code, or it was switched off.
  invalid,

  /// A VIP code another Google account redeemed first.
  used,

  /// A school code every place of which is taken.
  full,

  /// This family has had a school trial already.
  trialUsed,

  /// Its time is over.
  expired,
  tooManyTries,
  offline,
  failed,
}

class AccessCodeException implements Exception {
  final CodeError kind;
  const AccessCodeException(this.kind);

  @override
  String toString() => 'AccessCodeException($kind)';
}

/// The code server (api/ in this repo). [idToken] is the Google ID token of
/// the parent signed in on the phone: a redemption belongs to that account.
abstract class AccessCodeApi {
  Future<CodeGrant> redeem(String code, String idToken);

  /// The longest-lasting live code this Google account holds, or null.
  Future<CodeGrant?> restore(String idToken);

  /// The code behind [ticket] if it still stands, or null once it has ended
  /// or been revoked. Throws [AccessCodeException] when the server can't be
  /// asked, which is not the same as a no.
  Future<CodeGrant?> check(String ticket);
}

class HttpAccessCodeApi implements AccessCodeApi {
  HttpAccessCodeApi({Uri? base})
    : _base = base ?? Uri.parse('https://api.qissora.app');

  final Uri _base;

  @override
  Future<CodeGrant> redeem(String code, String idToken) async {
    final (status, body) = await _post('/codes/redeem', {
      'code': code,
      'idToken': idToken,
    });
    if (status == 200) {
      if (_grant(body, body['ticket']) case final grant?) return grant;
      throw const AccessCodeException(CodeError.failed);
    }
    throw AccessCodeException(switch (body['error']) {
      'invalid' => CodeError.invalid,
      'used' => CodeError.used,
      'full' => CodeError.full,
      'trial_used' => CodeError.trialUsed,
      'expired' => CodeError.expired,
      'too_many_tries' => CodeError.tooManyTries,
      _ => CodeError.failed,
    });
  }

  @override
  Future<CodeGrant?> restore(String idToken) async {
    final (status, body) = await _post('/codes/restore', {'idToken': idToken});
    if (status == 404) return null;
    if (status == 200) {
      if (_grant(body, body['ticket']) case final grant?) return grant;
    }
    throw const AccessCodeException(CodeError.failed);
  }

  @override
  Future<CodeGrant?> check(String ticket) async {
    final (status, body) = await _post('/codes/check', {'ticket': ticket});
    if (status != 200) throw const AccessCodeException(CodeError.failed);
    if (body['active'] != true) return null;
    return _grant(body, ticket) ??
        (throw const AccessCodeException(CodeError.failed));
  }

  static CodeGrant? _grant(Map<String, dynamic> body, Object? ticket) {
    final expires = body['expiresAt'];
    final kind = CodeKind.values.asNameMap()[body['kind']];
    if (expires is! int || ticket is! String || kind == null) return null;
    return CodeGrant(
      kind: kind,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(expires),
      ticket: ticket,
    );
  }

  Future<(int, Map<String, dynamic>)> _post(
    String path,
    Map<String, String> body,
  ) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.postUrl(_base.resolve(path));
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );
      final text = await response.transform(utf8.decoder).join();
      Map<String, dynamic> json = const {};
      try {
        final decoded = jsonDecode(text);
        if (decoded is Map<String, dynamic>) json = decoded;
      } on FormatException {
        // Not ours, e.g. a captive portal's page: the status decides.
      }
      return (response.statusCode, json);
    } on SocketException {
      throw const AccessCodeException(CodeError.offline);
    } on TimeoutException {
      throw const AccessCodeException(CodeError.offline);
    } on HttpException {
      throw const AccessCodeException(CodeError.offline);
    } finally {
      client.close();
    }
  }
}
