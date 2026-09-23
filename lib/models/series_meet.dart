import 'story.dart';
import 'story_category.dart';

/// The spoken welcome that opens a series page: who the series is for, what
/// it teaches and what happens in it.
///
/// Recorded on its own rather than cut from the stories, so it carries no
/// captions and its [length] is stored here instead of being read off them.
class MeetTheSeries {
  final Story track;
  final Duration length;

  const MeetTheSeries({required this.track, required this.length});
}

/// Every welcome track's id. A welcome plays for everyone: it is what a
/// listener uses to decide whether a series is for their child.
final Set<String> welcomeTrackIds = {
  for (final welcome in seriesWelcomes.values) welcome.track.id,
};

/// Keyed by series id. A series with no entry shows no welcome.
const Map<String, MeetTheSeries> seriesWelcomes = {
  'adam_en': MeetTheSeries(
    track: Story(
      id: 'adam_en_meet',
      title: 'Meet the series · Hazrat Adam (A.S.)',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/adam.webp',
      audioAsset: 'assets/audio/en/adam/00_meet_the_series.ogg',
      category: StoryCategory.prophets,
      description: 'A short welcome to the series.',
    ),
    length: Duration(milliseconds: 68701),
  ),
  'adam_ur': MeetTheSeries(
    track: Story(
      id: 'adam_ur_meet',
      title: 'سلسلے کا تعارف · حضرت آدم علیہ السلام',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/adam.webp',
      audioAsset: 'assets/audio/ur/adam/00_meet_the_series.ogg',
      category: StoryCategory.prophets,
      description: 'سلسلے کا مختصر تعارف',
    ),
    length: Duration(milliseconds: 58861),
  ),
  'fairness_en': MeetTheSeries(
    track: Story(
      id: 'fairness_en_meet',
      title: 'Meet the series · The Golden Balance',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/fairness.webp',
      audioAsset: 'assets/audio/en/fairness/00_meet_the_series.ogg',
      category: StoryCategory.moral,
      description: 'A short welcome to the series.',
    ),
    length: Duration(milliseconds: 60150),
  ),
  'fairness_ur': MeetTheSeries(
    track: Story(
      id: 'fairness_ur_meet',
      title: 'سلسلے کا تعارف · سنہری ترازو',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/fairness.webp',
      audioAsset: 'assets/audio/ur/fairness/00_meet_the_series.ogg',
      category: StoryCategory.moral,
      description: 'سلسلے کا مختصر تعارف',
    ),
    length: Duration(milliseconds: 66950),
  ),
  'gratitude_en': MeetTheSeries(
    track: Story(
      id: 'gratitude_en_meet',
      title: 'Meet the series · The Things We Never Notice',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/gratitude.webp',
      audioAsset: 'assets/audio/en/gratitude/00_meet_the_series.ogg',
      category: StoryCategory.moral,
      description: 'A short welcome to the series.',
    ),
    length: Duration(milliseconds: 62870),
  ),
  'gratitude_ur': MeetTheSeries(
    track: Story(
      id: 'gratitude_ur_meet',
      title: 'سلسلے کا تعارف · وہ چیزیں جن پر ہماری نظر نہیں جاتی',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/gratitude.webp',
      audioAsset: 'assets/audio/ur/gratitude/00_meet_the_series.ogg',
      category: StoryCategory.moral,
      description: 'سلسلے کا مختصر تعارف',
    ),
    length: Duration(milliseconds: 62110),
  ),
  'honesty_en': MeetTheSeries(
    track: Story(
      id: 'honesty_en_meet',
      title: 'Meet the series · The Book of Trust',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/honesty.webp',
      audioAsset: 'assets/audio/en/honesty/00_meet_the_series.ogg',
      category: StoryCategory.moral,
      description: 'A short welcome to the series.',
    ),
    length: Duration(milliseconds: 63781),
  ),
  'honesty_ur': MeetTheSeries(
    track: Story(
      id: 'honesty_ur_meet',
      title: 'سلسلے کا تعارف · کتابِ امانت',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/honesty.webp',
      audioAsset: 'assets/audio/ur/honesty/00_meet_the_series.ogg',
      category: StoryCategory.moral,
      description: 'سلسلے کا مختصر تعارف',
    ),
    length: Duration(milliseconds: 56781),
  ),
  'hud_en': MeetTheSeries(
    track: Story(
      id: 'hud_en_meet',
      title: 'Meet the series · Hazrat Hud (A.S.)',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/hud.webp',
      audioAsset: 'assets/audio/en/hud/00_meet_the_series.ogg',
      category: StoryCategory.prophets,
      description: 'A short welcome to the series.',
    ),
    length: Duration(milliseconds: 62830),
  ),
  'hud_ur': MeetTheSeries(
    track: Story(
      id: 'hud_ur_meet',
      title: 'سلسلے کا تعارف · حضرت ہود علیہ السلام',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/hud.webp',
      audioAsset: 'assets/audio/ur/hud/00_meet_the_series.ogg',
      category: StoryCategory.prophets,
      description: 'سلسلے کا مختصر تعارف',
    ),
    length: Duration(milliseconds: 64550),
  ),
  'ibrahim_en': MeetTheSeries(
    track: Story(
      id: 'ibrahim_en_meet',
      title: 'Meet the series · Hazrat Ibrahim (A.S.)',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/ibrahim.webp',
      audioAsset: 'assets/audio/en/ibrahim/00_meet_the_series.ogg',
      category: StoryCategory.prophets,
      description: 'A short welcome to the series.',
    ),
    length: Duration(milliseconds: 73017),
  ),
  'ibrahim_ur': MeetTheSeries(
    track: Story(
      id: 'ibrahim_ur_meet',
      title: 'سلسلے کا تعارف · حضرت ابراہیم علیہ السلام',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/ibrahim.webp',
      audioAsset: 'assets/audio/ur/ibrahim/00_meet_the_series.ogg',
      category: StoryCategory.prophets,
      description: 'سلسلے کا مختصر تعارف',
    ),
    length: Duration(milliseconds: 70057),
  ),
  'idris_en': MeetTheSeries(
    track: Story(
      id: 'idris_en_meet',
      title: 'Meet the series · Hazrat Idris (A.S.)',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/idris.webp',
      audioAsset: 'assets/audio/en/idris/00_meet_the_series.ogg',
      category: StoryCategory.prophets,
      description: 'A short welcome to the series.',
    ),
    length: Duration(milliseconds: 62101),
  ),
  'idris_ur': MeetTheSeries(
    track: Story(
      id: 'idris_ur_meet',
      title: 'سلسلے کا تعارف · حضرت ادریس علیہ السلام',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/idris.webp',
      audioAsset: 'assets/audio/ur/idris/00_meet_the_series.ogg',
      category: StoryCategory.prophets,
      description: 'سلسلے کا مختصر تعارف',
    ),
    length: Duration(milliseconds: 68461),
  ),
  'kindness_en': MeetTheSeries(
    track: Story(
      id: 'kindness_en_meet',
      title: 'Meet the series · The Kindness That Came Back',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/kindness.webp',
      audioAsset: 'assets/audio/en/kindness/00_meet_the_series.ogg',
      category: StoryCategory.moral,
      description: 'A short welcome to the series.',
    ),
    length: Duration(milliseconds: 55270),
  ),
  'kindness_ur': MeetTheSeries(
    track: Story(
      id: 'kindness_ur_meet',
      title: 'سلسلے کا تعارف · وہ مہربانی جو لوٹ کر آئی',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/kindness.webp',
      audioAsset: 'assets/audio/ur/kindness/00_meet_the_series.ogg',
      category: StoryCategory.moral,
      description: 'سلسلے کا مختصر تعارف',
    ),
    length: Duration(milliseconds: 60470),
  ),
  'lut_en': MeetTheSeries(
    track: Story(
      id: 'lut_en_meet',
      title: 'Meet the series · Hazrat Lut (A.S.)',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/lut.webp',
      audioAsset: 'assets/audio/en/lut/00_meet_the_series.ogg',
      category: StoryCategory.prophets,
      description: 'A short welcome to the series.',
    ),
    length: Duration(milliseconds: 65297),
  ),
  'lut_ur': MeetTheSeries(
    track: Story(
      id: 'lut_ur_meet',
      title: 'سلسلے کا تعارف · حضرت لوط علیہ السلام',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/lut.webp',
      audioAsset: 'assets/audio/ur/lut/00_meet_the_series.ogg',
      category: StoryCategory.prophets,
      description: 'سلسلے کا مختصر تعارف',
    ),
    length: Duration(milliseconds: 68097),
  ),
  'nuh_en': MeetTheSeries(
    track: Story(
      id: 'nuh_en_meet',
      title: 'Meet the series · Hazrat Nuh (A.S.)',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/nuh.webp',
      audioAsset: 'assets/audio/en/nuh/00_meet_the_series.ogg',
      category: StoryCategory.prophets,
      description: 'A short welcome to the series.',
    ),
    length: Duration(milliseconds: 66501),
  ),
  'nuh_ur': MeetTheSeries(
    track: Story(
      id: 'nuh_ur_meet',
      title: 'سلسلے کا تعارف · حضرت نوح علیہ السلام',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/nuh.webp',
      audioAsset: 'assets/audio/ur/nuh/00_meet_the_series.ogg',
      category: StoryCategory.prophets,
      description: 'سلسلے کا مختصر تعارف',
    ),
    length: Duration(milliseconds: 65501),
  ),
  'patience_en': MeetTheSeries(
    track: Story(
      id: 'patience_en_meet',
      title: 'Meet the series · The Things That Take Time',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/patience.webp',
      audioAsset: 'assets/audio/en/patience/00_meet_the_series.ogg',
      category: StoryCategory.moral,
      description: 'A short welcome to the series.',
    ),
    length: Duration(milliseconds: 69221),
  ),
  'patience_ur': MeetTheSeries(
    track: Story(
      id: 'patience_ur_meet',
      title: 'سلسلے کا تعارف · جو چیزیں وقت لیتی ہیں',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/patience.webp',
      audioAsset: 'assets/audio/ur/patience/00_meet_the_series.ogg',
      category: StoryCategory.moral,
      description: 'سلسلے کا مختصر تعارف',
    ),
    length: Duration(milliseconds: 58821),
  ),
  'respect_en': MeetTheSeries(
    track: Story(
      id: 'respect_en_meet',
      title: 'Meet the series · Respect',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/respect.webp',
      audioAsset: 'assets/audio/en/respect/00_meet_the_series.ogg',
      category: StoryCategory.moral,
      description: 'A short welcome to the series.',
    ),
    length: Duration(milliseconds: 61741),
  ),
  'respect_ur': MeetTheSeries(
    track: Story(
      id: 'respect_ur_meet',
      title: 'سلسلے کا تعارف · احترام',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/respect.webp',
      audioAsset: 'assets/audio/ur/respect/00_meet_the_series.ogg',
      category: StoryCategory.moral,
      description: 'سلسلے کا مختصر تعارف',
    ),
    length: Duration(milliseconds: 59421),
  ),
  'salih_en': MeetTheSeries(
    track: Story(
      id: 'salih_en_meet',
      title: 'Meet the series · Hazrat Salih (A.S.)',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/salih.webp',
      audioAsset: 'assets/audio/en/salih/00_meet_the_series.ogg',
      category: StoryCategory.prophets,
      description: 'A short welcome to the series.',
    ),
    length: Duration(milliseconds: 67821),
  ),
  'salih_ur': MeetTheSeries(
    track: Story(
      id: 'salih_ur_meet',
      title: 'سلسلے کا تعارف · حضرت صالح علیہ السلام',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/salih.webp',
      audioAsset: 'assets/audio/ur/salih/00_meet_the_series.ogg',
      category: StoryCategory.prophets,
      description: 'سلسلے کا مختصر تعارف',
    ),
    length: Duration(milliseconds: 54981),
  ),
};
