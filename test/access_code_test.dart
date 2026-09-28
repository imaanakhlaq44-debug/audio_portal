import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qissora/models/story_data.dart';
import 'package:qissora/screens/parents_dashboard_screen.dart';
import 'package:qissora/services/access_code_api.dart';
import 'package:qissora/services/premium_service.dart';
import 'package:qissora/services/storage_service.dart';

import 'fake_access_code_api.dart';
import 'test_helpers.dart';

void main() {
  late Directory dir;
  late DateTime now;
  late FakeAccessCodeApi server;

  setUp(() async {
    dir = await setUpStorage();
    now = DateTime(2026, 10, 1, 12);
    server = FakeAccessCodeApi(
      vip: {'QVABCD2345'},
      school: {'QSABCD2345': 2, 'QSWXYZ6789': 500},
      now: () => now,
    );
  });
  tearDown(() async => tearDownStorage(dir));

  PremiumService family([String? token = 'token-amina']) =>
      PremiumService.forTesting()
        ..codeApi = server
        ..clock = (() => now)
        ..codeSignInForTesting = (() async => token);

  final locked = StoryData.allSeries.first.episodes[1];

  group('a VIP code', () {
    test('opens every episode for a year', () async {
      final premium = family();
      expect(premium.isLocked(locked), isTrue);

      expect(await premium.redeemCode('qv-abcd-2345'), CodeOutcome.unlocked);
      expect(premium.isPremium, isTrue);
      expect(premium.isSubscribed, isFalse);
      expect(premium.codeKind, CodeKind.vip);
      expect(premium.codeUntil, now.add(const Duration(days: 365)));
      for (final story in StoryData.allStories) {
        expect(premium.isLocked(story), isFalse, reason: story.id);
        expect(premium.previewEnd(story), isNull, reason: story.id);
      }
    });

    test('survives a restart, and ends on its day even offline', () async {
      await family().redeemCode('QV-ABCD-2345');
      await restartStorage();

      server.offline = true;
      final reopened = family();
      await reopened.init();
      expect(reopened.hasCode, isTrue);

      now = now.add(const Duration(days: 365));
      expect(reopened.hasCode, isFalse);
      expect(reopened.isLocked(locked), isTrue);
    });

    test('says why a code did not work, and leaves the app locked', () async {
      expect(await family().redeemCode('QV-ZZZZ-ZZZZ'), CodeOutcome.invalid);

      await family('token-amina').redeemCode('QV-ABCD-2345');
      final other = family('token-bilal');
      expect(await other.redeemCode('QV-ABCD-2345'), CodeOutcome.used);
      expect(other.isPremium, isFalse);

      server.offline = true;
      expect(await family().redeemCode('QV-ABCD-2345'), CodeOutcome.offline);
    });

    test(
      'a parent who backs out of signing in never reaches the server',
      () async {
        final premium = family(null);
        expect(await premium.redeemCode('QV-ABCD-2345'), CodeOutcome.cancelled);
        expect(server.calls, 0);
        expect(premium.isPremium, isFalse);
      },
    );
  });

  group('a school code', () {
    test('gives each family a month from the day it enters it', () async {
      final amina = family('token-amina');
      expect(await amina.redeemCode('QS-ABCD-2345'), CodeOutcome.unlocked);
      expect(amina.codeKind, CodeKind.school);
      expect(amina.codeUntil, now.add(const Duration(days: 30)));

      now = now.add(const Duration(days: 10));
      final bilal = family('token-bilal');
      expect(await bilal.redeemCode('QS-ABCD-2345'), CodeOutcome.unlocked);
      expect(bilal.codeUntil, now.add(const Duration(days: 30)));

      now = now.add(const Duration(days: 20));
      expect(amina.isPremium, isFalse, reason: "Amina's month is over");
      expect(bilal.isPremium, isTrue);
    });

    test('stops at its limit', () async {
      await family('token-a').redeemCode('QS-ABCD-2345');
      await family('token-b').redeemCode('QS-ABCD-2345');
      expect(
        await family('token-c').redeemCode('QS-ABCD-2345'),
        CodeOutcome.full,
      );
    });

    test('is a family\'s only school trial', () async {
      await family().redeemCode('QS-ABCD-2345');
      now = now.add(const Duration(days: 31));
      expect(await family().redeemCode('QS-WXYZ-6789'), CodeOutcome.trialUsed);
    });

    test('does not cut a VIP family\'s year short', () async {
      final premium = family();
      await premium.redeemCode('QV-ABCD-2345');
      expect(await premium.redeemCode('QS-ABCD-2345'), CodeOutcome.unlocked);
      expect(premium.codeKind, CodeKind.vip);
      expect(premium.codeUntil, now.add(const Duration(days: 365)));
    });
  });

  group('checking back with the server', () {
    test('a revoked code stops working', () async {
      final premium = family();
      await premium.redeemCode('QS-ABCD-2345');
      server.revoked.add('QSABCD2345');

      await premium.refreshCode();
      expect(premium.hasCode, isFalse);
      expect(StorageService.getAccessCode(), isNull);
    });

    test('not reaching the server keeps the code as it was', () async {
      final premium = family();
      await premium.redeemCode('QV-ABCD-2345');
      server.offline = true;

      await premium.refreshCode();
      expect(premium.hasCode, isTrue);
    });
  });

  group('in the Parents area', () {
    Future<void> open(WidgetTester tester, PremiumService premium) async {
      await tester.pumpWidget(
        hostScreen(const ParentsDashboardScreen(), premium: premium),
      );
      await tester.pump();
    }

    Future<void> enterCode(WidgetTester tester, String code) async {
      await tester.tap(find.text('Have a code?'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), code);
      await tester.pump();
      await tester.runAsync(() async {
        await tester.tap(find.text('Unlock'));
        // Lets the Hive write behind the redeem land on disk.
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();
    }

    testWidgets('a free family can enter a VIP code and is unlocked', (
      tester,
    ) async {
      final premium = family();
      await open(tester, premium);
      await enterCode(tester, 'qv-abcd-2345');

      expect(premium.hasCode, isTrue);
      expect(find.text('Qissora Premium'), findsOneWidget);
      expect(
        find.text('VIP: every episode is unlocked until Oct 1, 2027'),
        findsOneWidget,
      );
      expect(find.text('Have a code?'), findsNothing);
      expect(find.text('Get Premium'), findsNothing);
    });

    testWidgets('a school trial keeps Get Premium in view', (tester) async {
      final premium = family();
      await open(tester, premium);
      await enterCode(tester, 'QS-ABCD-2345');

      expect(
        find.text('School trial: every episode is unlocked until Oct 31, 2026'),
        findsOneWidget,
      );
      expect(find.text('Get Premium'), findsOneWidget);
      expect(find.text('Have a code?'), findsOneWidget);
    });

    testWidgets('a wrong code is explained in the dialog', (tester) async {
      await open(tester, family());
      await enterCode(tester, 'QV-ZZZZ-ZZZZ');

      expect(
        find.text("That code isn't right. Check it and try again."),
        findsOneWidget,
      );
    });

    testWidgets('a year nearly up says so and offers a new code', (
      tester,
    ) async {
      final premium = family();
      await tester.runAsync(() => premium.redeemCode('QV-ABCD-2345'));
      now = now.add(const Duration(days: 360));
      await open(tester, premium);

      expect(
        find.text('VIP ends in 5 days, on Oct 1, 2027. Ask us for a new code.'),
        findsOneWidget,
      );
      expect(find.text('Have a code?'), findsOneWidget);
    });

    testWidgets('a school trial nearly up points to Premium', (tester) async {
      final premium = family();
      await tester.runAsync(() => premium.redeemCode('QS-ABCD-2345'));
      now = now.add(const Duration(days: 27));
      await open(tester, premium);

      expect(
        find.text(
          'School trial ends in 3 days, on Oct 31, 2026. Get Premium to keep '
          'listening.',
        ),
        findsOneWidget,
      );
    });
  });
}
