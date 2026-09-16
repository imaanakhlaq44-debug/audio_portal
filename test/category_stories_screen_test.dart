import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qissora/models/story_category.dart';
import 'package:qissora/models/story_data.dart';
import 'package:qissora/screens/category_stories_screen.dart';
import 'package:qissora/screens/series_screen.dart';
import 'package:qissora/widgets/series_card.dart';

import 'test_helpers.dart';

void main() {
  late Directory dir;

  setUp(() async => dir = await setUpStorage());
  tearDown(() async => tearDownStorage(dir));

  testWidgets('shows the category name and how many series it holds', (
    tester,
  ) async {
    const category = StoryCategory.moral;
    final series = StoryData.seriesIn(category);

    await tester.pumpWidget(
      hostScreen(const CategoryStoriesScreen(category: category)),
    );
    await tester.pump();

    expect(find.text(category.label), findsOneWidget);
    expect(find.text('${series.length} series'), findsOneWidget);
  });

  testWidgets('lists this category and nothing from any other', (tester) async {
    // Runs over the real catalogue, so a series filed under the wrong
    // category fails here rather than surfacing to a child.
    await tester.binding.setSurfaceSize(const Size(420, 6000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final category in StoryCategory.values) {
      await tester.pumpWidget(
        hostScreen(CategoryStoriesScreen(category: category)),
      );
      await tester.pump();

      for (final series in StoryData.allSeries) {
        final shouldShow = series.category == category;
        expect(
          find.widgetWithText(SeriesCard, series.title),
          shouldShow ? findsOneWidget : findsNothing,
          reason: '${series.title} is ${series.category.label}',
        );
      }
    }
  });

  testWidgets('tapping a series opens its playlist', (tester) async {
    // The playlist opens with a large cover; make room to build the rows.
    await tester.binding.setSurfaceSize(const Size(420, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final series = StoryData.allSeries.first;
    await tester.pumpWidget(
      hostScreen(CategoryStoriesScreen(category: series.category)),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(SeriesCard, series.title));
    await tester.pumpAndSettle();

    expect(find.byType(SeriesScreen), findsOneWidget);
    expect(find.text('Trailer'), findsOneWidget);
    for (final episode in series.episodes.take(2)) {
      expect(find.text(episode.title), findsOneWidget);
    }
  });

  testWidgets('shows an empty state for a category with no series yet', (
    tester,
  ) async {
    final empty = StoryCategory.values.where(
      (c) => StoryData.seriesIn(c).isEmpty,
    );
    if (empty.isEmpty) return;

    await tester.pumpWidget(
      hostScreen(CategoryStoriesScreen(category: empty.first)),
    );
    await tester.pump();

    expect(find.text('More stories coming soon!'), findsOneWidget);
  });
}
