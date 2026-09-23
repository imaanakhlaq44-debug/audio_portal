import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qissora/models/series.dart';
import 'package:qissora/models/story_category.dart';
import 'package:qissora/models/story_data.dart';
import 'package:qissora/screens/home_screen.dart';
import 'package:qissora/screens/series_screen.dart';
import 'package:qissora/services/storage_service.dart';
import 'package:qissora/widgets/child_avatar.dart';
import 'package:qissora/widgets/language_toggle.dart';
import 'package:qissora/widgets/story_tile.dart';

import 'fake_player.dart';
import 'test_helpers.dart';

void main() {
  late Directory dir;
  late FakePlayer player;

  setUp(() async {
    dir = await setUpStorage();
    player = FakePlayer();
  });

  tearDown(() async => tearDownStorage(dir));

  Future<void> open(WidgetTester tester) async {
    // Home is a tall scroller; the default 800x600 surface cuts off most of
    // it, and an unbuilt widget cannot be found or tapped.
    await tester.binding.setSurfaceSize(const Size(420, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      hostScreen(const HomeScreen(), inScaffold: true, player: player),
    );
    await tester.pump();
  }

  group('top bar', () {
    testWidgets('names the child, without greeting them', (tester) async {
      await writeToStorage(tester, () => StorageService.setChildName('Zayd'));
      await open(tester);

      expect(find.text('Zayd'), findsOneWidget);
      expect(find.textContaining('Salam'), findsNothing);
    });

    testWidgets('the picture is there to be tapped', (tester) async {
      await open(tester);

      expect(find.byType(ChildAvatar), findsOneWidget);
    });

    testWidgets('language switches from here, above the featured card', (
      tester,
    ) async {
      await open(tester);

      final toggle = find.byType(LanguageToggle);
      expect(toggle, findsOneWidget);
      expect(
        tester.getCenter(toggle).dy,
        lessThan(tester.getCenter(find.text('FEATURED SERIES')).dy),
      );
    });
  });

  group('featured series', () {
    testWidgets('features a series from the catalogue', (tester) async {
      await open(tester);

      expect(find.text('FEATURED SERIES'), findsOneWidget);
      expect(
        find.text(
          StoryData.featuredOn(
            DateTime.now(),
            language: StoryLanguage.english,
          ).title,
        ),
        findsWidgets,
      );
    });

    testWidgets('opens the series playlist when tapped', (tester) async {
      await open(tester);

      await tester.tap(find.text('FEATURED SERIES'));
      await tester.pumpAndSettle();

      expect(find.byType(SeriesScreen), findsOneWidget);
    });
  });

  group('continue listening', () {
    testWidgets('is hidden until there is something to resume', (tester) async {
      await open(tester);

      expect(find.text('Continue Listening'), findsNothing);
    });

    testWidgets('lists a part-played story with where to resume from', (
      tester,
    ) async {
      final story = StoryData.allStories.first;
      await writeToStorage(
        tester,
        () => StorageService.saveProgress(
          story.id,
          position: const Duration(minutes: 1, seconds: 5),
          duration: const Duration(minutes: 4),
        ),
      );
      await open(tester);

      expect(find.text('Continue Listening'), findsOneWidget);
      // StoryProgressLabel.fmt zero-pads: 01:05, not 1:05.
      expect(find.textContaining('Resume from 01:05'), findsOneWidget);
      expect(find.textContaining('left'), findsWidgets);
    });

    testWidgets('ignores a story barely started', (tester) async {
      final story = StoryData.allStories.first;
      await writeToStorage(
        tester,
        () => StorageService.saveProgress(
          story.id,
          // Under the 5-second floor StoryProgress.isResumable applies.
          position: const Duration(seconds: 2),
          duration: const Duration(minutes: 4),
        ),
      );
      await open(tester);

      expect(find.text('Continue Listening'), findsNothing);
    });

    testWidgets('drops a story once it is finished', (tester) async {
      final story = StoryData.allStories.first;
      await writeToStorage(tester, () async {
        await StorageService.saveProgress(
          story.id,
          position: const Duration(minutes: 1),
          duration: const Duration(minutes: 4),
        );
        await StorageService.markCompleted(story.id);
      });
      await open(tester);

      expect(find.text('Continue Listening'), findsNothing);
    });
  });

  group('language', () {
    testWidgets('with Urdu chosen, shows only Urdu series', (tester) async {
      // Written through runAsync like every other stored setting: a Hive
      // write started from a tap inside the fake clock never completes.
      await writeToStorage(
        tester,
        () => StorageService.setLanguage(StoryLanguage.urdu),
      );
      await open(tester);

      final urdu = StoryData.featuredOn(
        DateTime.now(),
        language: StoryLanguage.urdu,
      );
      expect(find.text(urdu.title), findsWidgets);
      for (final series in StoryData.seriesInLanguage(StoryLanguage.english)) {
        expect(find.text(series.title), findsNothing, reason: series.title);
      }
    });
  });

  group('sections', () {
    testWidgets('shows a row only for categories that have series', (
      tester,
    ) async {
      await open(tester);

      for (final category in StoryCategory.values) {
        expect(
          find.text(category.label),
          StoryData.seriesIn(category).isEmpty ? findsNothing : findsOneWidget,
          reason: category.label,
        );
      }
    });
  });

  group('playback', () {
    testWidgets('starts a fresh featured series at its trailer', (
      tester,
    ) async {
      await open(tester);

      await tester.tap(find.byType(PlayCircleButton).first);
      await tester.pump();

      expect(
        player.calls.single,
        contains(
          StoryData.featuredOn(
            DateTime.now(),
            language: StoryLanguage.english,
          ).tracks.first.id,
        ),
        reason: 'the tap must reach the player from the widget tree',
      );
    });
  });
}
