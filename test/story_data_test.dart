import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:imaan_akhlaq/models/story.dart';
import 'package:imaan_akhlaq/models/story_category.dart';
import 'package:imaan_akhlaq/models/story_data.dart';

void main() {
  final stories = StoryData.allStories;

  group('catalogue integrity', () {
    test('is not empty and has unique ids', () {
      expect(stories, isNotEmpty);
      final ids = stories.map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate story id');
    });

    test('every audio and cover asset actually exists on disk', () {
      // Catches the classic "renamed the mp3, forgot the reference" bug, which
      // otherwise only shows up as a failed load on a child's device.
      for (final s in stories) {
        expect(File(s.audioAsset).existsSync(), isTrue,
            reason: 'missing audio for ${s.id}: ${s.audioAsset}');
        expect(File(s.coverAsset).existsSync(), isTrue,
            reason: 'missing cover for ${s.id}: ${s.coverAsset}');
      }
    });

    test('every story has a title, narrator and description', () {
      for (final s in stories) {
        expect(s.title.trim(), isNotEmpty, reason: s.id);
        expect(s.narrator.trim(), isNotEmpty, reason: s.id);
        expect(s.description.trim(), isNotEmpty, reason: s.id);
      }
    });

    test('exactly one story of the day', () {
      expect(stories.where((s) => s.isStoryOfTheDay).length, 1);
      expect(StoryData.storyOfTheDay.isStoryOfTheDay, isTrue);
    });

    test('every category the UI lists has at least one story', () {
      for (final c in StoryCategory.values) {
        expect(StoryData.byCategory(c), isNotEmpty, reason: c.label);
      }
    });
  });

  group('captions', () {
    test('are ordered, non-empty and do not overlap', () {
      for (final s in stories) {
        expect(s.captions, isNotEmpty, reason: '${s.id} has no captions');
        Duration? prevEnd;
        for (final c in s.captions) {
          expect(c.text.trim(), isNotEmpty, reason: s.id);
          expect(c.end, greaterThan(c.start),
              reason: '${s.id}: "${c.text}" ends before it starts');
          if (prevEnd != null) {
            expect(c.start, greaterThanOrEqualTo(prevEnd),
                reason: '${s.id}: caption overlaps the previous line');
          }
          prevEnd = c.end;
        }
      }
    });

    test('durationLabel is derived from the last caption', () {
      const story = Story(
        id: 'x',
        title: 'X',
        narrator: 'N',
        coverAsset: 'c.png',
        audioAsset: 'a.mp3',
        category: StoryCategory.bedtime,
        description: 'd',
        captions: [
          CaptionLine(
            start: Duration.zero,
            end: Duration(seconds: 61),
            text: 'hi',
          ),
        ],
      );
      expect(story.durationLabel, '2 min', reason: 'rounds up');

      const noCaptions = Story(
        id: 'y',
        title: 'Y',
        narrator: 'N',
        coverAsset: 'c.png',
        audioAsset: 'a.mp3',
        category: StoryCategory.bedtime,
        description: 'd',
      );
      expect(noCaptions.durationLabel, '');
    });

    test('fullText joins every line', () {
      final s = stories.first;
      expect(s.fullText, contains(s.captions.first.text));
      expect(s.fullText, contains(s.captions.last.text));
    });
  });

  group('lookup', () {
    test('byId finds a known story and misses an unknown one', () {
      expect(StoryData.byId(stories.first.id), isNotNull);
      expect(StoryData.byId('no_such_story'), isNull);
    });

    test('search is case-insensitive and matches title or category', () {
      final byTitle = StoryData.search(stories.first.title.toUpperCase());
      expect(byTitle.map((s) => s.id), contains(stories.first.id));

      final bedtime = StoryData.search('bedtime');
      expect(bedtime, isNotEmpty);
    });

    test('an empty query returns nothing rather than everything', () {
      expect(StoryData.search(''), isEmpty);
      expect(StoryData.search('   '), isEmpty);
    });
  });
}
