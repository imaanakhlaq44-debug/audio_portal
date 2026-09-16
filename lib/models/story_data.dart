import 'series.dart';
import 'series/fairness_en.dart';
import 'story.dart';
import 'story_category.dart';

/// The catalogue. Every series ships inside the app; its trailer and episodes
/// are the playable [Story] units.
class StoryData {
  static const List<Series> allSeries = [fairnessEnglish];

  static final List<Story> allStories = [
    for (final series in allSeries) ...series.tracks,
  ];

  static final Map<String, Series> _seriesByStoryId = {
    for (final series in allSeries)
      for (final story in series.tracks) story.id: series,
  };

  /// The series shown large on the home screen, rotating once a day.
  static Series featuredOn(DateTime day) {
    final dayOfYear = day.difference(DateTime(day.year)).inDays;
    return allSeries[dayOfYear % allSeries.length];
  }

  static List<Series> seriesIn(StoryCategory category) =>
      allSeries.where((s) => s.category == category).toList();

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
