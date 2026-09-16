import 'dart:io';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:qissora/services/storage_service.dart';

import 'test_helpers.dart';

void main() {
  group('StoryProgress', () {
    StoryProgress make({
      int posSec = 0,
      int durSec = 0,
      bool completed = false,
      int plays = 0,
    }) => StoryProgress(
      position: Duration(seconds: posSec),
      duration: Duration(seconds: durSec),
      completed: completed,
      updatedAt: DateTime(2026, 1, 1),
      playCount: plays,
    );

    test('fraction is 0 when the duration is unknown', () {
      expect(make(posSec: 30).fraction, 0);
    });

    test('fraction is clamped to 0..1', () {
      expect(make(posSec: 30, durSec: 60).fraction, closeTo(0.5, 0.001));
      expect(make(posSec: 90, durSec: 60).fraction, 1.0);
    });

    test('a few seconds in is not yet resumable', () {
      expect(make(posSec: 4, durSec: 300).isResumable, isFalse);
      expect(make(posSec: 5, durSec: 300).isResumable, isTrue);
    });

    test('finished or near-finished stories are not resumable', () {
      expect(
        make(posSec: 100, durSec: 300, completed: true).isResumable,
        isFalse,
      );
      expect(make(posSec: 299, durSec: 300).isResumable, isFalse);
    });

    test('survives a toMap/fromMap round trip', () {
      final p = make(posSec: 42, durSec: 300, completed: true, plays: 3);
      final back = StoryProgress.fromMap(p.toMap())!;
      expect(back.position, p.position);
      expect(back.duration, p.duration);
      expect(back.completed, isTrue);
      expect(back.playCount, 3);
    });

    test('rejects junk instead of throwing', () {
      expect(StoryProgress.fromMap('not a map'), isNull);
      expect(StoryProgress.fromMap(null), isNull);
      // A partial map must still decode, with zeroed defaults.
      final partial = StoryProgress.fromMap({'pos': 'bad', 'done': 'yes'})!;
      expect(partial.position, Duration.zero);
      expect(partial.completed, isFalse);
    });
  });

  group('StorageService', () {
    late Directory dir;

    setUp(() async => dir = await setUpStorage());
    tearDown(() async => tearDownStorage(dir));

    test('seeds a default PIN and child name on first run', () async {
      expect(await StorageService.verifyPin(StorageService.defaultPin), isTrue);
      expect(StorageService.isUsingDefaultPin(), isTrue);
      expect(StorageService.getChildName(), StorageService.defaultChildName);
    });

    test('verifyPin follows the stored PIN', () async {
      expect(await StorageService.verifyPin('1234'), isTrue);
      await StorageService.setParentPin('9081');
      expect(await StorageService.verifyPin('1234'), isFalse);
      expect(await StorageService.verifyPin('9081'), isTrue);
      expect(StorageService.isUsingDefaultPin(), isFalse);
    });

    test('favorites toggle on and off', () async {
      expect(StorageService.isFavorite('little_lamb'), isFalse);
      await StorageService.toggleFavorite('little_lamb');
      expect(StorageService.getFavorites(), ['little_lamb']);
      await StorageService.toggleFavorite('little_lamb');
      expect(StorageService.getFavorites(), isEmpty);
    });

    test('saved stories toggle on and off', () async {
      expect(StorageService.isSaved('ocean_whispers'), isFalse);
      await StorageService.toggleSaved('ocean_whispers');
      expect(StorageService.getSavedStories(), ['ocean_whispers']);
      expect(StorageService.isSaved('ocean_whispers'), isTrue);

      await StorageService.toggleSaved('ocean_whispers');
      expect(StorageService.getSavedStories(), isEmpty);
    });

    test('favorites and saved stories are independent lists', () async {
      await StorageService.toggleFavorite('brave_little_ant');
      await StorageService.toggleSaved('ocean_whispers');

      expect(StorageService.getFavorites(), ['brave_little_ant']);
      expect(StorageService.getSavedStories(), ['ocean_whispers']);

      await StorageService.clearSavedStories();
      expect(
        StorageService.getFavorites(),
        ['brave_little_ant'],
        reason: 'clearing saved stories must not touch favorites',
      );
    });

    test('theme mode round trips', () async {
      expect(StorageService.getThemeMode(), ThemeMode.system);
      await StorageService.setThemeMode(ThemeMode.dark);
      expect(StorageService.getThemeMode(), ThemeMode.dark);
    });

    test('saveProgress keeps a previously known duration', () async {
      await StorageService.saveProgress(
        'ocean_whispers',
        position: const Duration(seconds: 10),
        duration: const Duration(seconds: 300),
      );
      // A later save before the duration is known must not wipe it.
      await StorageService.saveProgress(
        'ocean_whispers',
        position: const Duration(seconds: 20),
        duration: Duration.zero,
      );
      final p = StorageService.getProgress('ocean_whispers')!;
      expect(p.position, const Duration(seconds: 20));
      expect(p.duration, const Duration(seconds: 300));
      expect(StorageService.getLastStoryId(), 'ocean_whispers');
    });

    test('markCompleted rewinds, flags done and counts the play', () async {
      await StorageService.saveProgress(
        'brave_little_ant',
        position: const Duration(seconds: 280),
        duration: const Duration(seconds: 300),
      );
      await StorageService.markCompleted('brave_little_ant');

      final p = StorageService.getProgress('brave_little_ant')!;
      expect(p.position, Duration.zero, reason: 'next play starts fresh');
      expect(p.completed, isTrue);
      expect(p.playCount, 1);
      expect(StorageService.completedCount(), 1);
      expect(StorageService.totalPlays(), 1);
      expect(StorageService.getResumable(), isEmpty);
    });

    test('getResumable lists in-progress stories, most recent first', () async {
      await StorageService.saveProgress(
        'honest_woodcutter',
        position: const Duration(seconds: 30),
        duration: const Duration(seconds: 300),
      );
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await StorageService.saveProgress(
        'bedtime_dua',
        position: const Duration(seconds: 60),
        duration: const Duration(seconds: 300),
      );
      // Too early in to count as "continue listening".
      await StorageService.saveProgress(
        'little_lamb',
        position: const Duration(seconds: 2),
        duration: const Duration(seconds: 300),
      );

      final ids = StorageService.getResumable().map((e) => e.key).toList();
      expect(ids, ['bedtime_dua', 'honest_woodcutter']);
    });

    test('clearProgress drops the last-story pointer with it', () async {
      await StorageService.saveProgress(
        'prophet_salih',
        position: const Duration(seconds: 30),
        duration: const Duration(seconds: 300),
      );
      await StorageService.clearProgress('prophet_salih');
      expect(StorageService.getProgress('prophet_salih'), isNull);
      expect(StorageService.getLastStoryId(), isNull);
    });
  });
}
