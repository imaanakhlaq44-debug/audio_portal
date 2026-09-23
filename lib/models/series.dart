import 'series_meet.dart';
import 'story.dart';
import 'story_category.dart';

enum StoryLanguage { english, urdu }

extension StoryLanguageX on StoryLanguage {
  String get label => switch (this) {
    StoryLanguage.english => 'English',
    StoryLanguage.urdu => 'اردو',
  };
}

/// A narrated series: one cover and its episodes in order. Each episode is a
/// [Story], so playback, progress, favourites and captions work on them
/// exactly as on a single story.
class Series {
  final String id;
  final String title;
  final StoryLanguage language;
  final StoryCategory category;
  final String coverAsset;
  final String description;

  final List<Story> episodes;

  const Series({
    required this.id,
    required this.title,
    required this.language,
    required this.category,
    required this.coverAsset,
    required this.description,
    required this.episodes,
  });

  /// Everything in play order.
  List<Story> get tracks => episodes;

  /// The spoken welcome that opens the series page, if one was recorded.
  MeetTheSeries? get welcome => seriesWelcomes[id];

  String get episodeCountLabel => switch (language) {
    StoryLanguage.urdu => '${episodes.length} اقساط',
    StoryLanguage.english =>
      '${episodes.length} ${episodes.length == 1 ? 'episode' : 'episodes'}',
  };
}
