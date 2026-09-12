import 'story_category.dart';

/// A single timed caption/subtitle line synced to the audio playback.
class CaptionLine {
  final Duration start;
  final Duration end;
  final String text;
  final bool
  isHighlight; // key dramatic line to emphasize in the mini caption card

  const CaptionLine({
    required this.start,
    required this.end,
    required this.text,
    this.isHighlight = false,
  });
}

class Story {
  final String id;
  final String title;
  final String narrator;
  final String coverAsset;
  final String audioAsset;
  final StoryCategory category;
  final String description;
  final bool isStoryOfTheDay;
  final List<CaptionLine> captions;

  const Story({
    required this.id,
    required this.title,
    required this.narrator,
    required this.coverAsset,
    required this.audioAsset,
    required this.category,
    required this.description,
    this.isStoryOfTheDay = false,
    this.captions = const [],
  });

  /// Full story text reconstructed from captions, for the "read along" modal.
  String get fullText => captions.map((c) => c.text).join('\n\n');

  String get durationLabel {
    if (captions.isEmpty) return '';
    final totalSeconds = captions.last.end.inSeconds;
    final minutes = (totalSeconds / 60).ceil();
    return '$minutes min';
  }
}
