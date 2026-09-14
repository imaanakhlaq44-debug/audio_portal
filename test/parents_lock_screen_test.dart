import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:imaan_akhlaq/screens/parents_dashboard_screen.dart';
import 'package:imaan_akhlaq/screens/parents_lock_screen.dart';
import 'package:imaan_akhlaq/services/pin_service.dart';
import 'package:imaan_akhlaq/services/storage_service.dart';

import 'test_helpers.dart';

void main() {
  late Directory dir;

  setUp(() async {
    // Keep the derivation on this isolate; see PinService.deriveInline.
    PinService.deriveInline = true;
    dir = await setUpStorage();
  });

  tearDown(() async {
    PinService.deriveInline = false;
    await tearDownStorage(dir);
  });

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(hostScreen(const ParentsLockScreen()));
    await tester.pump();
  }

  /// Taps the PIN out digit by digit and lets the verification finish.
  ///
  /// The last digit is tapped inside [WidgetTester.runAsync] on purpose. It
  /// is the one that starts verification, and a wrong PIN writes the failure
  /// count to Hive. A write started inside the fake-async zone testWidgets
  /// installs leaves Hive's write lock holding a future from a zone that is
  /// about to die — the write itself completes, but the box can never be
  /// closed again, and the whole run hangs in teardown with no failure to
  /// point at. Driving that tap in a real zone avoids it entirely.
  Future<void> enterPin(WidgetTester tester, String pin) async {
    final digits = pin.split('');
    for (final digit in digits.take(digits.length - 1)) {
      await tester.tap(find.text(digit));
      await tester.pump();
    }

    await tester.runAsync(() async {
      await tester.tap(find.text(digits.last));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });

    await tester.pump(); // paint the outcome
    await tester.pump(const Duration(milliseconds: 500)); // finish any route
  }

  group('the gate', () {
    testWidgets('asks for a PIN and never reveals it', (tester) async {
      await open(tester);

      expect(find.text('Parents Area'), findsOneWidget);
      expect(find.text('Enter your 4-digit PIN to continue'), findsOneWidget);
      expect(
        find.textContaining(StorageService.defaultPin),
        findsNothing,
        reason: 'the screen used to print "Default PIN is 1234" under the pad',
      );
    });

    testWidgets('the right PIN opens the dashboard', (tester) async {
      await open(tester);
      await enterPin(tester, StorageService.defaultPin);

      expect(find.byType(ParentsDashboardScreen), findsOneWidget);
    });

    testWidgets('a wrong PIN says so and stays put', (tester) async {
      await open(tester);
      await enterPin(tester, '9999');

      expect(find.byType(ParentsDashboardScreen), findsNothing);
      expect(find.textContaining('Incorrect PIN'), findsOneWidget);
      expect(StorageService.failedPinAttempts(), 1);
    });

    testWidgets('a custom PIN works and the old default stops working', (
      tester,
    ) async {
      await writeToStorage(tester, () => StorageService.setParentPin('5309'));
      await open(tester);

      await enterPin(tester, StorageService.defaultPin);
      expect(find.byType(ParentsDashboardScreen), findsNothing);

      await enterPin(tester, '5309');
      expect(find.byType(ParentsDashboardScreen), findsOneWidget);
    });
  });

  group('rate limiting', () {
    testWidgets('warns as the free attempts run out', (tester) async {
      await open(tester);

      // Free attempts are 4; the warning starts once 2 or fewer remain.
      await enterPin(tester, '9999');
      await enterPin(tester, '9999');
      await enterPin(tester, '9999');

      expect(find.textContaining('1 try left'), findsOneWidget);
    });

    testWidgets('locks the pad with a countdown once they are gone', (
      tester,
    ) async {
      await open(tester);

      for (var i = 0; i <= StorageService.freePinAttempts; i++) {
        await enterPin(tester, '9999');
      }

      expect(StorageService.isPinLocked(), isTrue);
      expect(find.text('Too many incorrect attempts'), findsOneWidget);
      expect(find.textContaining('Try again in'), findsOneWidget);
    });

    testWidgets('a locked pad ignores the keypad entirely', (tester) async {
      await open(tester);
      for (var i = 0; i <= StorageService.freePinAttempts; i++) {
        await enterPin(tester, '9999');
      }
      final attemptsWhenLocked = StorageService.failedPinAttempts();

      // Even the correct PIN must not get through while locked.
      await enterPin(tester, StorageService.defaultPin);

      expect(find.byType(ParentsDashboardScreen), findsNothing);
      expect(
        StorageService.failedPinAttempts(),
        attemptsWhenLocked,
        reason: 'a locked pad should not even count the attempt',
      );
    });

    testWidgets('the right PIN clears the ladder', (tester) async {
      await open(tester);

      await enterPin(tester, '9999');
      await enterPin(tester, '9999');
      expect(StorageService.failedPinAttempts(), 2);

      await enterPin(tester, StorageService.defaultPin);

      expect(StorageService.failedPinAttempts(), 0);
      expect(StorageService.isPinLocked(), isFalse);
    });

    testWidgets('an expired lockout lets the parent back in', (tester) async {
      await open(tester);
      for (var i = 0; i <= StorageService.freePinAttempts; i++) {
        await enterPin(tester, '9999');
      }
      expect(StorageService.isPinLocked(), isTrue);

      // Wind the deadline back rather than waiting 30 real seconds.
      await writeToStorage(
        tester,
        () => Hive.box('settings_box').put(
          'pin_locked_until',
          DateTime.now()
              .subtract(const Duration(seconds: 1))
              .millisecondsSinceEpoch,
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      await enterPin(tester, StorageService.defaultPin);
      expect(find.byType(ParentsDashboardScreen), findsOneWidget);
    });
  });
}
