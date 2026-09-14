import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imaan_akhlaq/models/story_data.dart';
import 'package:imaan_akhlaq/screens/library_screen.dart';
import 'package:imaan_akhlaq/services/storage_service.dart';

import 'test_helpers.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await setUpStorage();
  });

  tearDown(() async => tearDownStorage(dir));

  testWidgets('an empty library shows no story tiles', (tester) async {
    await tester.pumpWidget(
      hostScreen(const LibraryScreen(), inScaffold: true),
    );
    await tester.pump();

    for (final story in StoryData.allStories) {
      expect(find.text(story.title), findsNothing);
    }
  });

  testWidgets('favourited and saved stories both appear in the library', (
    tester,
  ) async {
    final favourite = StoryData.allStories[0];
    final saved = StoryData.allStories[1];
    final untouched = StoryData.allStories[2];

    await writeToStorage(
      tester,
      () => StorageService.toggleFavorite(favourite.id),
    );
    await writeToStorage(tester, () => StorageService.toggleSaved(saved.id));

    await tester.pumpWidget(
      hostScreen(const LibraryScreen(), inScaffold: true),
    );
    await tester.pump();

    expect(find.text(favourite.title), findsOneWidget);
    expect(
      find.text(saved.title),
      findsOneWidget,
      reason: 'a saved (bookmarked) story belongs in the library too',
    );
    expect(find.text(untouched.title), findsNothing);
  });

  testWidgets('the library reacts to a story being saved while open', (
    tester,
  ) async {
    final story = StoryData.allStories.first;

    await tester.pumpWidget(
      hostScreen(const LibraryScreen(), inScaffold: true),
    );
    await tester.pump();
    expect(find.text(story.title), findsNothing);

    await writeToStorage(tester, () => StorageService.toggleSaved(story.id));
    await tester.pump();

    expect(find.text(story.title), findsOneWidget);
  });

  group('search', () {
    testWidgets('matches on title regardless of case', (tester) async {
      final story = StoryData.allStories.first;

      await tester.pumpWidget(
        hostScreen(const LibraryScreen(), inScaffold: true),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), story.title.toUpperCase());
      await tester.pump();

      expect(find.textContaining('Search Results'), findsOneWidget);
      expect(find.text(story.title), findsOneWidget);
    });

    testWidgets('says so when nothing matches', (tester) async {
      await tester.pumpWidget(
        hostScreen(const LibraryScreen(), inScaffold: true),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'zzzzz no such story');
      await tester.pump();

      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });
  });
}
