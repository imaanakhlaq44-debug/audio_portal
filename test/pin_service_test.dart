import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qissora/services/pin_service.dart';

Uint8List _bytes(String s) => Uint8List.fromList(utf8.encode(s));

String _hex(List<int> b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

void main() {
  group('pbkdf2 (HMAC-SHA256)', () {
    // Published PBKDF2-HMAC-SHA256 vectors, cross-checked against Node's
    // crypto.pbkdf2Sync. Rolling your own KDF is only defensible if it is
    // pinned to an independent implementation - this is that pin.
    const vectors = [
      (
        'password',
        'salt',
        1,
        32,
        '120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b',
      ),
      (
        'password',
        'salt',
        2,
        32,
        'ae4d0c95af6b46d32d0adff928f06dd02a303f8ef3c251dfd6e2d85a95474c43',
      ),
      (
        'password',
        'salt',
        4096,
        32,
        'c5e478d59288c841aa530db6845c4c8d962893a001ce4e11a4963873aa98134a',
      ),
      // dkLen 40 > one SHA-256 block, so this one exercises the block loop.
      (
        'passwordPASSWORDpassword',
        'saltSALTsaltSALTsaltSALTsaltSALTsalt',
        4096,
        40,
        '348c89dbcbd32b2f32d814b8116e84cf2b17347ebc1800181c4e2a1fb8dd53e1'
            'c635518c7dac47e9',
      ),
      (
        '1234',
        'imaan-akhlaq-test-salt',
        1000,
        32,
        '475cda8327ec8dc1c121c5c4cdf5132a876faef9fe303c1aa15714201711243c',
      ),
    ];

    for (final (password, salt, iterations, dkLen, expected) in vectors) {
      test('$password / $salt / c=$iterations / dkLen=$dkLen', () {
        final out = PinService.pbkdf2(
          password,
          _bytes(salt),
          iterations,
          dkLen,
        );
        expect(out, hasLength(dkLen));
        expect(_hex(out), expected);
      });
    }

    test('rejects nonsense parameters', () {
      expect(
        () => PinService.pbkdf2('p', _bytes('s'), 0, 32),
        throwsArgumentError,
      );
      expect(
        () => PinService.pbkdf2('p', _bytes('s'), 1, 0),
        throwsArgumentError,
      );
    });
  });

  group('constantTimeEquals', () {
    test('matches only identical byte strings', () {
      expect(PinService.constantTimeEquals([1, 2, 3], [1, 2, 3]), isTrue);
      expect(PinService.constantTimeEquals([1, 2, 3], [1, 2, 4]), isFalse);
      expect(PinService.constantTimeEquals([1, 2, 3], [1, 2]), isFalse);
      expect(PinService.constantTimeEquals([], []), isTrue);
    });
  });

  group('salt', () {
    test('is the expected length and not a constant', () {
      final a = PinService.newSalt();
      final b = PinService.newSalt();
      expect(a, hasLength(PinService.saltBytes));
      expect(a, isNot(equals(b)), reason: 'salt must be random per install');
    });
  });

  group('create / verify', () {
    // A low iteration count keeps the suite quick; the cost parameter is not
    // what is under test here.
    const fast = 1000;

    test('accepts the right PIN and rejects the rest', () async {
      final cred = await PinService.create('4821', iterations: fast);

      expect(await PinService.verify('4821', cred), isTrue);
      expect(await PinService.verify('4822', cred), isFalse);
      expect(await PinService.verify('', cred), isFalse);
      expect(await PinService.verify('48210', cred), isFalse);
    });

    test(
      'never stores the PIN, and salts each credential separately',
      () async {
        final a = await PinService.create('4821', iterations: fast);
        final b = await PinService.create('4821', iterations: fast);

        expect(_hex(a.hash), isNot(contains('4821')));
        expect(a.saltB64, isNot(b.saltB64));
        expect(
          a.hashB64,
          isNot(b.hashB64),
          reason: 'same PIN on two devices must not produce the same hash',
        );
        expect(a.iterations, fast);
      },
    );

    test('base64 round trips back to the same bytes', () async {
      final cred = await PinService.create('9137', iterations: fast);
      final restored = PinCredential(
        salt: Uint8List.fromList(base64Decode(cred.saltB64)),
        hash: Uint8List.fromList(base64Decode(cred.hashB64)),
        iterations: cred.iterations,
      );
      expect(await PinService.verify('9137', restored), isTrue);
    });
  });
}
