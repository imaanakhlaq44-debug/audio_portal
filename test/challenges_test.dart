import 'package:flutter_test/flutter_test.dart';
import 'package:qissora/models/challenges.dart';
import 'package:qissora/models/story_data.dart';

void main() {
  group('challenges', () {
    test('every episode has one', () {
      final missing = StoryData.allStories
          .where((s) => !challengesByStoryId.containsKey(s.id))
          .map((s) => s.id)
          .toList();
      expect(
        missing,
        isEmpty,
        reason:
            'No challenge for: ${missing.join(', ')}. Run '
            'tools/extract_challenges.mjs then tools/gen_challenges_dart.mjs, '
            'and add anything the scripts do not have to '
            'tools/challenges.written.json.',
      );
    });

    test('none is blank', () {
      for (final entry in challengesByStoryId.entries) {
        expect(
          entry.value.title.trim(),
          isNotEmpty,
          reason: '${entry.key} has no title',
        );
        expect(
          entry.value.mission.trim(),
          isNotEmpty,
          reason: '${entry.key} has no mission',
        );
      }
    });

    test('none belongs to a story that no longer exists', () {
      final ids = StoryData.allStories.map((s) => s.id).toSet();
      final orphans = challengesByStoryId.keys
          .where((id) => !ids.contains(id))
          .toList();
      expect(orphans, isEmpty, reason: 'Orphaned: ${orphans.join(', ')}');
    });
  });
}
