import 'series.dart';
import 'series/adam_en.dart';
import 'series/fairness_en.dart';
import 'series/adam_ur.dart';
import 'series/fairness_ur.dart';
import 'series/gratitude_ur.dart';
import 'series/honesty_ur.dart';
import 'series/hud_ur.dart';
import 'series/idris_ur.dart';
import 'series/kindness_ur.dart';
import 'series/nuh_ur.dart';
import 'series/salih_ur.dart';
import 'series/respect_ur.dart';
import 'series/patience_ur.dart';
import 'series/gratitude_en.dart';
import 'series/honesty_en.dart';
import 'series/hud_en.dart';
import 'series/idris_en.dart';
import 'series/kindness_en.dart';
import 'series/nuh_en.dart';
import 'series/patience_en.dart';
import 'series/respect_en.dart';
import 'series/salih_en.dart';
import 'story.dart';
import 'story_category.dart';

/// The catalogue. Every series ships inside the app; its episodes
/// are the playable [Story] units.
class StoryData {
  /// Prophet series in the order the Prophets came.
  static const List<Series> allSeries = [
    adamEnglish,
    idrisEnglish,
    nuhEnglish,
    hudEnglish,
    salihEnglish,
    fairnessEnglish,
    honestyEnglish,
    kindnessEnglish,
    respectEnglish,
    gratitudeEnglish,
    patienceEnglish,
    adamUrdu,
    idrisUrdu,
    nuhUrdu,
    hudUrdu,
    salihUrdu,
    fairnessUrdu,
    honestyUrdu,
    kindnessUrdu,
    respectUrdu,
    gratitudeUrdu,
    patienceUrdu,
  ];

  static final List<Story> allStories = [
    for (final series in allSeries) ...series.tracks,
  ];

  static final Map<String, Series> _seriesByStoryId = {
    for (final series in allSeries)
      for (final story in series.tracks) story.id: series,
  };

  /// Every series in [language], or in both languages when null.
  static List<Series> seriesInLanguage(StoryLanguage? language) => allSeries
      .where((s) => language == null || s.language == language)
      .toList();

  /// The series shown large on the home screen, rotating once a day.
  static Series featuredOn(DateTime day, {StoryLanguage? language}) {
    final pool = seriesInLanguage(language);
    final from = pool.isEmpty ? allSeries : pool;
    final dayOfYear = day.difference(DateTime(day.year)).inDays;
    return from[dayOfYear % from.length];
  }

  static List<Series> seriesIn(
    StoryCategory category, {
    StoryLanguage? language,
  }) =>
      seriesInLanguage(language).where((s) => s.category == category).toList();

  static Story? byId(String id) {
    for (final s in allStories) {
      if (s.id == id) return s;
    }
    return null;
  }

  static Series? seriesOf(Story story) => _seriesByStoryId[story.id];

  /// What plays after [story] finishes: the next track of its series, or
  /// nothing at the end of the series.
  static Story? nextAfter(Story story) {
    final tracks = seriesOf(story)?.tracks;
    if (tracks == null) return null;
    final i = tracks.indexWhere((t) => t.id == story.id);
    return i >= 0 && i + 1 < tracks.length ? tracks[i + 1] : null;
  }

  /// Episodes whose title, or whose series title, contains [query].
  static List<Story> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return allStories.where((s) {
      final series = seriesOf(s);
      return s.title.toLowerCase().contains(q) ||
          (series?.title.toLowerCase().contains(q) ?? false) ||
          s.category.label.toLowerCase().contains(q);
    }).toList();
  }
}
