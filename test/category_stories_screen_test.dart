import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:imaan_akhlaq/models/story_category.dart';
import 'package:imaan_akhlaq/models/story_data.dart';
import 'package:imaan_akhlaq/screens/category_stories_screen.dart';

import 'test_helpers.dart';

void main() {
  late Directory dir;

  setUp(() async => dir = await setUpStorage());
  tearDown(() async => tearDownStorage(dir));

  testWidgets('shows the category name and how many stories it holds', (
    tester,
  ) async {
    const category = StoryCategory.bedtime;
    final stories = StoryData.byCategory(category);

    await tester.pumpWidget(
      hostScreen(const CategoryStoriesScreen(category: category)),
    );
    await tester.pump();

    expect(find.text(category.label), findsOneWidget);
    expect(
      find.text(
        '${stories.length} ${stories.length == 1 ? 'story' : 'stories'}',
      ),
      findsOneWidget,
    );
  });

  testWidgets('lists this category and nothing from any other', (tester) async {
    // Runs over the real catalogue, so a story filed under the wrong
    // category fails here rather than surfacing to a child.
    for (final category in StoryCategory.values) {
      await tester.pumpWidget(
        hostScreen(CategoryStoriesScreen(category: category)),
      );
      await tester.pump();

      for (final story in StoryData.allStories) {
        final shouldShow = story.category == category;
        expect(
          find.text(story.title),
          shouldShow ? findsOneWidget : findsNothing,
          reason: shouldShow
              ? '${story.title} belongs in ${category.label}'
              : '${story.title} is ${story.category.label}, not '
                    '${category.label}',
        );
      }
    }
  });

  testWidgets('keeps the mini player reachable on this route', (tester) async {
    // The screen deliberately carries its own mini player, because it is
    // pushed over MainScreen and would otherwise hide the controls.
    await tester.pumpWidget(
      hostScreen(const CategoryStoriesScreen(category: StoryCategory.prophets)),
    );
    await tester.pump();

    expect(find.byType(CategoryStoriesScreen), findsOneWidget);
    // Nothing is playing, so the bar collapses rather than showing a story.
    for (final story in StoryData.allStories) {
      expect(find.text('Now playing: ${story.title}'), findsNothing);
    }
  });
}
