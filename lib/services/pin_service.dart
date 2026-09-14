import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// A stored parent PIN: the derived key plus the parameters needed to
/// re-derive it. The PIN itself is never kept.
@immutable
class PinCredential {
  final Uint8List salt;
  final Uint8List hash;
  final int iterations;

  const PinCredential({
    required this.salt,
    required this.hash,
    required this.iterations,
  });

  String get saltB64 => base64Encode(salt);
  String get hashB64 => base64Encode(hash);
}

/// Password hashing for the parents' PIN.
///
/// A four-digit PIN is only 10,000 possibilities, so no hash makes it
/// *unguessable* to someone who can copy the Hive file off the device and
/// grind it offline. What this buys is worth having anyway:
///
/// - the PIN is no longer sitting in plain text in a file that lands in
///   Android auto-backup, a `adb backup`, or an older sibling's hands;
/// - a per-install random salt means the stored value gives nothing away,
///   not even "these two devices use the same PIN";
/// - the iteration count makes each guess cost real time, which combines
///   with the on-device lockout in [StorageService] to make interactive
///   guessing impractical.
///
/// PBKDF2-HMAC-SHA256 (RFC 2898), verified in `test/pin_service_test.dart`
/// against published vectors.
class PinService {
  PinService._();

  /// Cost per verification.
  ///
  /// Deliberately below the ~600k OWASP suggests for passwords. That figure
  /// assumes the iteration count is the main defence, which cannot be true
  /// here: a 4-digit PIN is 10,000 candidates, so an offline attacker wins at
  /// any cost we could impose. Guessing is stopped by the lockout ladder in
  /// [StorageService] instead, and the job of this number is only to be
  /// expensive enough to matter while staying invisible to a parent.
  ///
  /// Measured with `test/zz_bench` on a desktop (Dart JIT): 50k ≈ 330 ms,
  /// 100k ≈ 590 ms. A low-end phone is several times slower, so 100k would
  /// read as "the app froze" on exactly the devices this app targets.
  static const int defaultIterations = 50000;

  static const int saltBytes = 16;
  static const int keyBytes = 32;

  static final Random _rng = Random.secure();

  static Uint8List newSalt() {
    final salt = Uint8List(saltBytes);
    for (var i = 0; i < salt.length; i++) {
      salt[i] = _rng.nextInt(256);
    }
    return salt;
  }

  /// Derive a new credential for [pin] with a fresh salt.
  static Future<PinCredential> create(
    String pin, {
    int iterations = defaultIterations,
  }) async {
    final salt = newSalt();
    final hash = await deriveKey(pin, salt, iterations);
    return PinCredential(salt: salt, hash: hash, iterations: iterations);
  }

  /// Whether [pin] matches [credential].
  static Future<bool> verify(String pin, PinCredential credential) async {
    final candidate = await deriveKey(
      pin,
      credential.salt,
      credential.iterations,
    );
    return constantTimeEquals(candidate, credential.hash);
  }

  /// Runs the key derivation off the UI isolate - at 100k iterations this
  /// would otherwise drop frames on the PIN pad.
  static Future<Uint8List> deriveKey(
    String pin,
    Uint8List salt,
    int iterations,
  ) {
    if (deriveInline) {
      return SynchronousFuture(pbkdf2(pin, salt, iterations, keyBytes));
    }
    return compute(_deriveEntry, <Object>[pin, salt, iterations]);
  }

  /// Runs the derivation on the calling isolate instead of through
  /// [compute].
  ///
  /// Widget tests need this: `compute` spawns an isolate, and its result is
  /// never delivered under the fake-async clock `testWidgets` installs — so
  /// a screen awaiting a PIN check would hang forever rather than fail. The
  /// app itself must never set this; the whole point of the isolate is to
  /// keep 50,000 rounds of PBKDF2 off the frame.
  @visibleForTesting
  static bool deriveInline = false;

  static Uint8List _deriveEntry(List<Object> args) =>
      pbkdf2(args[0] as String, args[1] as Uint8List, args[2] as int, keyBytes);

  /// PBKDF2-HMAC-SHA256. Synchronous core, kept public so tests can run it
  /// against known vectors without an isolate hop.
  static Uint8List pbkdf2(
    String password,
    Uint8List salt,
    int iterations,
    int keyLength,
  ) {
    if (iterations < 1) {
      throw ArgumentError.value(iterations, 'iterations', 'must be >= 1');
    }
    if (keyLength < 1) {
      throw ArgumentError.value(keyLength, 'keyLength', 'must be >= 1');
    }

    final hmac = Hmac(sha256, utf8.encode(password));
    final out = Uint8List(keyLength);
    var written = 0;
    var blockIndex = 1;

    while (written < keyLength) {
      // U1 = PRF(password, salt || INT_32_BE(blockIndex))
      final seed = Uint8List(salt.length + 4)..setRange(0, salt.length, salt);
      ByteData.view(seed.buffer).setUint32(salt.length, blockIndex, Endian.big);

      var u = Uint8List.fromList(hmac.convert(seed).bytes);
      final block = Uint8List.fromList(u);

      // T_i = U1 ^ U2 ^ ... ^ Uc
      for (var i = 1; i < iterations; i++) {
        u = Uint8List.fromList(hmac.convert(u).bytes);
        for (var j = 0; j < block.length; j++) {
          block[j] ^= u[j];
        }
      }

      final take = min(block.length, keyLength - written);
      out.setRange(written, written + take, block);
      written += take;
      blockIndex++;
    }

    return out;
  }

  /// Compares without an early exit, so the time taken says nothing about
  /// how much of the hash matched.
  static bool constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
