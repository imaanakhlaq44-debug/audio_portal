import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qissora/models/story_category.dart';
import 'package:qissora/models/story_data.dart';
import 'package:qissora/screens/now_playing_screen.dart';
import 'package:qissora/services/storage_service.dart';

import 'fake_player.dart';
import 'test_helpers.dart';

void main() {
  late Directory dir;
  late FakePlayer player;
  final story = StoryData.allStories.first;

  setUp(() async {
    dir = await setUpStorage();
    player = FakePlayer()..story = story;
  });

  tearDown(() async => tearDownStorage(dir));

  Future<void> open(WidgetTester tester) async {
    // The screen scrolls, and the transport controls sit below the fold on
    // the default 800x600 test surface - tapping them would silently miss.
    // setSurfaceSize is only legal inside a test, hence addTearDown here
    // rather than a plain tearDown.
    await tester.binding.setSurfaceSize(const Size(420, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      hostScreen(const NowPlayingScreen(), player: player),
    );
    await tester.pump();
  }

  group('what it shows', () {
    testWidgets('names the current story, its narrator and category', (
      tester,
    ) async {
      await open(tester);

      expect(find.text(story.title), findsOneWidget);
      expect(find.text(story.narrator), findsOneWidget);
      expect(find.text(story.category.label.toUpperCase()), findsOneWidget);
    });

    testWidgets('the transport button follows the playback state', (
      tester,
    ) async {
      await open(tester);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      player.emit(() => player.playing = true);
      await tester.pump();
      expect(find.byIcon(Icons.pause), findsOneWidget);

      // A finished story offers a replay rather than a dead play button.
      player.emit(() {
        player.playing = false;
        player.completed = true;
      });
      await tester.pump();
      expect(find.byIcon(Icons.replay_rounded), findsOneWidget);
    });

    testWidgets('surfaces a playback error with a way out', (tester) async {
      player.emit(() => player.error = 'Could not play this story.');
      await open(tester);

      expect(find.text('Could not play this story.'), findsOneWidget);
    });

    testWidgets('shows the sleep timer countdown only while it is armed', (
      tester,
    ) async {
      await open(tester);
      expect(find.text('Timer'), findsOneWidget);

      player.emit(() {
        player.sleepTimer = const Duration(minutes: 15);
        player.sleepLeft = const Duration(minutes: 14, seconds: 30);
      });
      await tester.pump();

      expect(find.text('Timer'), findsNothing);
      expect(find.text('14:30'), findsWidgets);
    });

    testWidgets('reflects the stored favourite and saved state', (
      tester,
    ) async {
      await writeToStorage(tester, () async {
        await StorageService.toggleFavorite(story.id);
        await StorageService.toggleSaved(story.id);
      });
      await open(tester);

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.bookmark), findsOneWidget);
      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('with no story loaded it draws nothing and leaves', (
      tester,
    ) async {
      player.emit(() => player.story = null);
      await open(tester);

      expect(find.text(story.title), findsNothing);
      expect(find.byIcon(Icons.play_arrow), findsNothing);
    });
  });

  group('what it asks the player to do', () {
    testWidgets('the main button toggles playback', (tester) async {
      await open(tester);

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      expect(player.calls, ['togglePlayPause']);
    });

    testWidgets('the main button is inert while loading', (tester) async {
      player.emit(() => player.loading = true);
      await open(tester);

      // Tapping the spinner must not queue a toggle.
      await tester.tap(find.byType(CircularProgressIndicator).first);
      await tester.pump();

      expect(player.calls, isEmpty);
    });

    testWidgets('the skip buttons move by ten seconds each way', (
      tester,
    ) async {
      await open(tester);

      await tester.tap(find.byIcon(Icons.replay_10));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.forward_10));
      await tester.pump();

      expect(player.calls, ['skipBackward', 'skipForward']);
    });

    testWidgets('restart sends the story back to the beginning', (
      tester,
    ) async {
      await open(tester);

      await tester.tap(find.byIcon(Icons.restart_alt_rounded));
      await tester.pump();

      expect(player.calls, ['restart']);
    });

    testWidgets('closing stops playback rather than just hiding the screen', (
      tester,
    ) async {
      await open(tester);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(
        player.calls,
        contains('stopAndClose'),
        reason: 'otherwise the story keeps playing behind a closed screen',
      );
    });

    testWidgets('retrying an error replays the same story', (tester) async {
      player.emit(() => player.error = 'Could not play this story.');
      await open(tester);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(player.calls.single, contains('playStory(${story.id}'));
    });

    testWidgets('the timer sheet arms the chosen duration', (tester) async {
      await open(tester);

      await tester.tap(find.text('Timer'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('15 min'));
      await tester.pumpAndSettle();

      expect(player.calls, contains('setSleepTimer(15)'));
    });
  });
}
