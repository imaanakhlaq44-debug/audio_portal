import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qissora/models/challenges.dart';
import 'package:qissora/models/story_data.dart';
import 'package:qissora/screens/parents_dashboard_screen.dart';
import 'package:qissora/services/storage_service.dart';

import 'test_helpers.dart';

void main() {
  late Directory dir;

  setUp(() async => dir = await setUpStorage());
  tearDown(() async => tearDownStorage(dir));

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(hostScreen(const ParentsDashboardScreen()));
    await tester.pump();
  }

  /// The dashboard is a ListView, so anything below the fold has not been
  /// built yet and cannot be tapped until it is scrolled into view.
  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 200);
    await tester.pumpAndSettle();
  }

  group('what it reports', () {
    testWidgets('shows the child name a parent set', (tester) async {
      await writeToStorage(tester, () => StorageService.setChildName('Fatima'));
      await open(tester);

      expect(find.text("Child's Name"), findsOneWidget);
      expect(find.text('Fatima'), findsOneWidget);
    });

    testWidgets('counts finished listens, not started ones', (tester) async {
      final story = StoryData.allStories.first;
      final other = StoryData.allStories[1];

      await writeToStorage(tester, () async {
        // Started but abandoned: should not count as completed.
        await StorageService.saveProgress(
          other.id,
          position: const Duration(seconds: 30),
          duration: const Duration(minutes: 5),
        );
        await StorageService.markCompleted(story.id);
      });
      await open(tester);

      expect(find.text('1'), findsWidgets, reason: 'one completed listen');
      expect(
        find.text('1 / ${StoryData.allStories.length}'),
        findsOneWidget,
        reason: 'one story completed out of the whole catalogue',
      );
    });

    testWidgets('pluralises the saved counts', (tester) async {
      await writeToStorage(
        tester,
        () => StorageService.toggleSaved(StoryData.allStories.first.id),
      );
      await open(tester);
      await scrollTo(tester, find.text('1 story in the library'));

      expect(find.text('1 story in the library'), findsOneWidget);
      expect(find.text('0 stories saved'), findsOneWidget);
    });

    testWidgets('calls saved stories saved, never downloaded', (tester) async {
      await open(tester);
      await scrollTo(tester, find.text('Saved Stories'));

      expect(find.text('Saved Stories'), findsOneWidget);
      expect(
        find.textContaining('ownload'),
        findsNothing,
        reason: 'nothing is downloaded - the audio ships with the app',
      );
    });
  });

  group("today's challenge", () {
    testWidgets('shows the one from the last story played', (tester) async {
      final story = StoryData.allStories.first;
      await writeToStorage(
        tester,
        () => StorageService.saveProgress(
          story.id,
          position: const Duration(minutes: 1),
          duration: const Duration(minutes: 5),
        ),
      );
      await open(tester);

      final challenge = challengesByStoryId[story.id]!;
      expect(find.text(challenge.title), findsOneWidget);
      expect(find.textContaining('TODAY'), findsOneWidget);
    });

    testWidgets('invites a listen before anything has been played', (
      tester,
    ) async {
      await open(tester);

      expect(find.text("Today's challenge"), findsOneWidget);
      expect(
        find.textContaining('Play an episode together'),
        findsOneWidget,
      );
    });
  });

  group('default PIN warning', () {
    testWidgets('is shown while the shipped PIN is still in use', (
      tester,
    ) async {
      await open(tester);

      expect(StorageService.isUsingDefaultPin(), isTrue);
      final warning = find.text('Still the default PIN - tap to change it');
      await scrollTo(tester, warning);
      expect(warning, findsOneWidget);
    });

    testWidgets('goes away once the parent picks their own', (tester) async {
      await writeToStorage(tester, () => StorageService.setParentPin('8264'));
      await open(tester);

      final subtitle = find.text('Update the 4-digit access code');
      await scrollTo(tester, subtitle);
      expect(subtitle, findsOneWidget);
      expect(
        find.text('Still the default PIN - tap to change it'),
        findsNothing,
      );
    });

    testWidgets('never prints the PIN itself', (tester) async {
      await open(tester);

      // The lock screen used to advertise "Default PIN is 1234"; the
      // dashboard must not reintroduce that anywhere.
      expect(find.textContaining(StorageService.defaultPin), findsNothing);
    });
  });

  group('story list dialogs', () {
    testWidgets('lists the saved stories by name', (tester) async {
      final saved = StoryData.allStories[2];
      await writeToStorage(tester, () => StorageService.toggleSaved(saved.id));
      await open(tester);
      await scrollTo(tester, find.text('Saved Stories'));

      await tester.tap(find.text('Saved Stories'));
      await tester.pumpAndSettle();

      expect(find.text(saved.title), findsOneWidget);
      expect(find.text('Clear all'), findsOneWidget);
    });

    testWidgets('says so when there is nothing saved yet', (tester) async {
      await open(tester);
      await scrollTo(tester, find.text('Saved Favorites'));

      await tester.tap(find.text('Saved Favorites'));
      await tester.pumpAndSettle();

      expect(find.text('Nothing here yet.'), findsOneWidget);
      expect(
        find.text('Clear all'),
        findsNothing,
        reason: 'no clear button when there is nothing to clear',
      );
    });
  });

  group('reset listening history', () {
    testWidgets('asks before clearing', (tester) async {
      await open(tester);

      await scrollTo(tester, find.text('Reset Listening History'));
      await tester.tap(find.text('Reset Listening History'));
      await tester.pumpAndSettle();

      expect(find.text('Reset Listening History?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('cancelling leaves the history alone', (tester) async {
      final story = StoryData.allStories.first;
      await writeToStorage(
        tester,
        () => StorageService.markCompleted(story.id),
      );
      await open(tester);

      await scrollTo(tester, find.text('Reset Listening History'));
      await tester.tap(find.text('Reset Listening History'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(StorageService.totalPlays(), 1);
    });
  });
}
