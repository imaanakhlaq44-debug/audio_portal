import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qissora/services/storage_service.dart';

import 'test_helpers.dart';

void main() {
  late Directory dir;

  setUp(() async => dir = await setUpStorage());
  tearDown(() async => tearDownStorage(dir));

  group('PIN storage', () {
    test('the PIN is never written to the box in clear text', () async {
      await StorageService.setParentPin('7391');

      final box = Hive.box('settings_box');
      final stored = box.toMap().values.map((v) => '$v').toList();

      expect(
        stored.any((v) => v.contains('7391')),
        isFalse,
        reason: 'found the raw PIN in storage: $stored',
      );
      expect(box.get('parent_pin'), isNull, reason: 'legacy key must be gone');
      expect(box.get('parent_pin_hash'), isA<String>());
      expect(box.get('parent_pin_salt'), isA<String>());
      expect(box.get('parent_pin_iterations'), isA<int>());
    });

    test('a PIN survives a restart', () async {
      await StorageService.setParentPin('5150');

      // Close and reopen the boxes the way a real app restart would.
      await restartStorage();

      expect(await StorageService.verifyPin('5150'), isTrue);
      expect(await StorageService.verifyPin('1234'), isFalse);
    });

    test('rejects near-misses and malformed input', () async {
      await StorageService.setParentPin('0042');

      for (final wrong in ['0043', '4200', '042', '00420', '', 'abcd']) {
        expect(
          await StorageService.verifyPin(wrong),
          isFalse,
          reason: '"$wrong" should not unlock',
        );
      }
      expect(await StorageService.verifyPin('0042'), isTrue);
    });

    test(
      'recovers instead of bricking when the credential is corrupt',
      () async {
        await StorageService.setParentPin('8888');
        await Hive.box('settings_box').put('parent_pin_hash', 'not base64 !!');

        // Falls back to the default rather than locking the parent out forever.
        expect(await StorageService.verifyPin('1234'), isTrue);
        expect(await StorageService.verifyPin('8888'), isFalse);
      },
    );

    test('isFourDigitPin accepts only four digits', () {
      expect(StorageService.isFourDigitPin('0000'), isTrue);
      expect(StorageService.isFourDigitPin('9999'), isTrue);
      expect(StorageService.isFourDigitPin('123'), isFalse);
      expect(StorageService.isFourDigitPin('12345'), isFalse);
      expect(StorageService.isFourDigitPin('12a4'), isFalse);
      expect(StorageService.isFourDigitPin(' 123'), isFalse);
      expect(StorageService.isFourDigitPin(''), isFalse);
    });
  });

  group('migration from the plain-text PIN', () {
    /// Puts the box back into the pre-1.2 shape: a plain-text `parent_pin`
    /// and none of the hash keys.
    Future<void> writeLegacyPin(String pin) async {
      final box = Hive.box('settings_box');
      await box.put('parent_pin', pin);
      await box.delete('parent_pin_hash');
      await box.delete('parent_pin_salt');
      await box.delete('parent_pin_iterations');
      await box.delete('parent_pin_is_default');
    }

    test('an existing custom PIN keeps working and gets hashed', () async {
      await writeLegacyPin('2468');
      await restartStorage();

      expect(await StorageService.verifyPin('2468'), isTrue);
      expect(StorageService.isUsingDefaultPin(), isFalse);
      expect(Hive.box('settings_box').get('parent_pin'), isNull);
    });

    test('a legacy default PIN is still recognised as the default', () async {
      await writeLegacyPin(StorageService.defaultPin);
      await restartStorage();

      expect(await StorageService.verifyPin('1234'), isTrue);
      expect(StorageService.isUsingDefaultPin(), isTrue);
    });

    test('a junk legacy value falls back to the default PIN', () async {
      await writeLegacyPin('not-a-pin');
      await restartStorage();

      expect(await StorageService.verifyPin(StorageService.defaultPin), isTrue);
      expect(Hive.box('settings_box').get('parent_pin'), isNull);
    });
  });

  group('lockout', () {
    test('the first failures are free', () async {
      for (var i = 1; i <= StorageService.freePinAttempts; i++) {
        final lock = await StorageService.registerFailedPinAttempt();
        expect(lock, Duration.zero, reason: 'attempt $i should not lock');
        expect(StorageService.isPinLocked(), isFalse);
      }
      expect(StorageService.pinAttemptsBeforeLockout(), 0);
    });

    test(
      'further failures climb the ladder and then hold at the cap',
      () async {
        for (var i = 0; i < StorageService.freePinAttempts; i++) {
          await StorageService.registerFailedPinAttempt();
        }

        for (final expected in StorageService.pinLockoutLadder) {
          expect(await StorageService.registerFailedPinAttempt(), expected);
        }
        // Past the end of the ladder the last entry repeats.
        final cap = StorageService.pinLockoutLadder.last;
        expect(await StorageService.registerFailedPinAttempt(), cap);
        expect(await StorageService.registerFailedPinAttempt(), cap);
      },
    );

    test('a lockout is armed and reported as remaining time', () async {
      for (var i = 0; i <= StorageService.freePinAttempts; i++) {
        await StorageService.registerFailedPinAttempt();
      }

      expect(StorageService.isPinLocked(), isTrue);
      final left = StorageService.pinLockRemaining();
      expect(left, greaterThan(Duration.zero));
      expect(left, lessThanOrEqualTo(StorageService.pinLockoutLadder.first));
    });

    test('a lockout survives a restart', () async {
      for (var i = 0; i <= StorageService.freePinAttempts; i++) {
        await StorageService.registerFailedPinAttempt();
      }

      await restartStorage();

      expect(
        StorageService.isPinLocked(),
        isTrue,
        reason: 'force-quitting must not hand out fresh guesses',
      );
      expect(StorageService.failedPinAttempts(), greaterThan(0));
    });

    test('an elapsed deadline unlocks on its own', () async {
      for (var i = 0; i <= StorageService.freePinAttempts; i++) {
        await StorageService.registerFailedPinAttempt();
      }
      expect(StorageService.isPinLocked(), isTrue);

      // Move the deadline into the past rather than waiting 30 real seconds.
      await Hive.box('settings_box').put(
        'pin_locked_until',
        DateTime.now()
            .subtract(const Duration(seconds: 1))
            .millisecondsSinceEpoch,
      );

      expect(StorageService.isPinLocked(), isFalse);
      expect(StorageService.pinLockRemaining(), Duration.zero);
    });

    test('a correct PIN clears the ladder', () async {
      for (var i = 0; i <= StorageService.freePinAttempts; i++) {
        await StorageService.registerFailedPinAttempt();
      }
      expect(StorageService.isPinLocked(), isTrue);

      await StorageService.clearPinFailures();

      expect(StorageService.isPinLocked(), isFalse);
      expect(StorageService.failedPinAttempts(), 0);
      expect(
        StorageService.pinAttemptsBeforeLockout(),
        StorageService.freePinAttempts,
      );
    });

    test('counts down the free attempts as they are used', () async {
      expect(
        StorageService.pinAttemptsBeforeLockout(),
        StorageService.freePinAttempts,
      );
      await StorageService.registerFailedPinAttempt();
      expect(
        StorageService.pinAttemptsBeforeLockout(),
        StorageService.freePinAttempts - 1,
      );
    });
  });
}
