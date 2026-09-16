import 'story.dart';
import 'story_category.dart';

enum StoryLanguage { english, urdu }

extension StoryLanguageX on StoryLanguage {
  String get label => switch (this) {
    StoryLanguage.english => 'English',
    StoryLanguage.urdu => 'اردو',
  };
}

/// A narrated series: one cover, an optional trailer, and its episodes in
/// order. Each trailer and episode is a [Story], so playback, progress,
/// favourites and captions work on them exactly as on a single story.
class Series {
  final String id;
  final String title;
  final StoryLanguage language;
  final StoryCategory category;
  final String coverAsset;
  final String description;
  final Story? trailer;
  final List<Story> episodes;

  const Series({
    required this.id,
    required this.title,
    required this.language,
    required this.category,
    required this.coverAsset,
    required this.description,
    this.trailer,
    required this.episodes,
  });

  /// Everything in play order: the trailer first, then the episodes.
  List<Story> get tracks => [?trailer, ...episodes];

  String get episodeCountLabel =>
      '${episodes.length} ${episodes.length == 1 ? 'episode' : 'episodes'}';
}
