import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:qissora/models/story.dart';
import 'package:qissora/models/story_data.dart';
import 'package:qissora/screens/now_playing_screen.dart';
import 'package:qissora/screens/parents_dashboard_screen.dart';
import 'package:qissora/screens/series_screen.dart';
import 'package:qissora/services/premium_service.dart';
import 'package:qissora/widgets/mini_player.dart';
import 'package:qissora/widgets/paywall_sheet.dart';

import 'fake_player.dart';
import 'test_helpers.dart';

void main() {
  late Directory dir;
  setUp(() async => dir = await setUpStorage());
  tearDown(() async => tearDownStorage(dir));

  final series = StoryData.allSeries.first;
  final first = series.episodes.first;
  final second = series.episodes[1];

  group('access rules', () {
    test('a free account previews episode 1 and nothing else', () {
      final free = PremiumService.forTesting();
      for (final s in StoryData.allSeries) {
        expect(free.isPreview(s.episodes.first), isTrue, reason: s.id);
        expect(free.isLocked(s.episodes.first), isFalse, reason: s.id);
        for (final e in s.episodes.skip(1)) {
          expect(free.isLocked(e), isTrue, reason: e.id);
        }
      }
    });

    test('the preview stops on a finished line, about halfway', () {
      final free = PremiumService.forTesting();
      for (final s in StoryData.allSeries) {
        final ep = s.episodes.first;
        final end = free.previewEnd(ep)!;
        final total = ep.captions.last.end;
        expect(end, greaterThanOrEqualTo(total ~/ 2), reason: ep.id);
        expect(end, lessThan(total), reason: ep.id);
        expect(
          ep.captions.map((c) => c.end),
          contains(end),
          reason: '${ep.id} should stop at the end of a caption line',
        );
      }
      expect(free.previewEnd(second), isNull, reason: 'locked, not previewed');
    });

    test('Premium unlocks everything, with no preview limit', () {
      final paid = PremiumService.forTesting()..isPremiumForTesting = true;
      for (final story in StoryData.allStories) {
        expect(paid.isLocked(story), isFalse, reason: story.id);
        expect(paid.previewEnd(story), isNull, reason: story.id);
      }
    });

    test('the welcome sits outside the episodes and plays for everyone', () {
      final free = PremiumService.forTesting();
      for (final s in StoryData.allSeries) {
        expect(s.tracks, s.episodes, reason: s.id);
        final welcome = s.welcome;
        expect(welcome, isNotNull, reason: s.id);
        expect(StoryData.byId(welcome!.track.id), isNull, reason: s.id);
        expect(free.isLocked(welcome.track), isFalse, reason: s.id);
      }
    });
  });

  group('a free listener', () {
    testWidgets('sees a lock on locked episodes and a preview badge on ep 1', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(420, 3000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        hostScreen(
          SeriesScreen(series: series),
          premium: PremiumService.forTesting(),
        ),
      );
      await tester.pump();

      expect(find.text('FREE PREVIEW'), findsOneWidget);
      expect(find.text('Episode 1 is a free preview'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Unlock with Premium'),
        findsNWidgets(series.episodes.length - 1),
      );
    });

    testWidgets('tapping a locked episode asks for the paywall, not the '
        'player', (tester) async {
      final player = FakePlayer();
      final requests = <Story>[];
      final sub = player.paywallRequests.listen(requests.add);
      addTearDown(sub.cancel);
      await tester.pumpWidget(
        hostScreen(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => openStory(context, second),
              child: const Text('open'),
            ),
          ),
          player: player,
          premium: PremiumService.forTesting(),
          inScaffold: true,
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(requests.map((s) => s.id), [second.id]);
      expect(player.calls, isEmpty);
      expect(find.byType(NowPlayingScreen), findsNothing);
    });

    testWidgets('can still start the free preview', (tester) async {
      final player = FakePlayer();
      await tester.pumpWidget(
        hostScreen(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => openStory(context, first),
              child: const Text('open'),
            ),
          ),
          player: player,
          premium: PremiumService.forTesting(),
          inScaffold: true,
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();

      expect(player.calls.first, startsWith('playStory(${first.id}'));
    });
  });

  group('paywall', () {
    Future<void> openPaywall(
      WidgetTester tester, {
      Story? story,
      PremiumService? premium,
    }) async {
      await tester.binding.setSurfaceSize(const Size(420, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        hostScreen(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showPaywall(context, story: story),
              child: const Text('paywall'),
            ),
          ),
          premium: premium ?? PremiumService.forTesting(),
          inScaffold: true,
        ),
      );
      await tester.tap(find.text('paywall'));
      await tester.pumpAndSettle();
    }

    testWidgets('after a preview, asks if they want to hear what is next', (
      tester,
    ) async {
      await openPaywall(tester, story: first);
      expect(find.text('Want to hear what happens next?'), findsOneWidget);
      expect(find.textContaining(series.title), findsOneWidget);
    });

    testWidgets('on a locked episode, says it is part of Premium', (
      tester,
    ) async {
      await openPaywall(tester, story: second);
      expect(find.text('Unlock every story'), findsOneWidget);
    });

    testWidgets('offers the Play prices, yearly first, with its saving', (
      tester,
    ) async {
      PremiumPlan plan(String id, String price, double raw) => PremiumPlan(
        basePlanId: id,
        price: price,
        rawPrice: raw,
        currencyCode: 'PKR',
        details: ProductDetails(
          id: PremiumService.productId,
          title: 'Qissora Premium',
          description: '',
          price: price,
          rawPrice: raw,
          currencyCode: 'PKR',
        ),
      );
      final premium = PremiumService.forTesting()
        ..plansForTesting = [
          plan(PremiumService.monthlyPlanId, 'Rs 300', 300),
          plan(PremiumService.annualPlanId, 'Rs 3,000', 3000),
        ];

      await openPaywall(tester, premium: premium);

      expect(find.text('Rs 300'), findsOneWidget);
      expect(find.text('Rs 3,000'), findsOneWidget);
      expect(find.text('SAVE 17%'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Yearly')).dy,
        lessThan(tester.getTopLeft(find.text('Monthly')).dy),
      );
    });

    testWidgets('asks a grown-up before subscribing, and rejects a wrong '
        'answer', (tester) async {
      await openPaywall(tester);
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(find.text('Ask a grown-up'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '1');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('That is not right. Try again.'), findsOneWidget);

      // Read the question off the screen and answer it properly.
      final question = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .firstWhere((s) => s.contains('×'));
      final nums = RegExp(r'\d+').allMatches(question).toList();
      final answer =
          int.parse(nums[0].group(0)!) * int.parse(nums[1].group(0)!);
      await tester.enterText(find.byType(TextField), '$answer');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // No Google Play in tests, so the parent is told Play is unreachable.
      expect(find.text('Google Play is not available'), findsOneWidget);
    });
  });

  testWidgets('the Parents area offers Google sign-in for a new phone', (
    tester,
  ) async {
    await tester.pumpWidget(
      hostScreen(
        const ParentsDashboardScreen(),
        premium: PremiumService.forTesting(),
      ),
    );
    await tester.pump();

    expect(find.text('Free plan'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(
      find.text('New phone? Sign in to get your Premium back.'),
      findsOneWidget,
    );
  });
}
