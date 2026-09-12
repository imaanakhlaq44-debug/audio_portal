import 'story.dart';
import 'story_category.dart';

/// Helper to quickly build a CaptionLine list from "start-end: text" style
/// second offsets (mm:ss.mmm not needed — we just use raw seconds as double).
List<CaptionLine> _caps(List<List<dynamic>> raw) {
  return raw.map((row) {
    final startSec = (row[0] as num).toDouble();
    final endSec = (row[1] as num).toDouble();
    final text = row[2] as String;
    final isHighlight = row.length > 3 ? row[3] as bool : false;
    return CaptionLine(
      start: Duration(milliseconds: (startSec * 1000).round()),
      end: Duration(milliseconds: (endSec * 1000).round()),
      text: text,
      isHighlight: isHighlight,
    );
  }).toList();
}

class StoryData {
  static final List<Story> allStories = [
    Story(
      id: 'honest_woodcutter',
      title: 'The Honest Woodcutter',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/honest_woodcutter.png',
      audioAsset: 'assets/audio/honest_woodcutter.mp3',
      category: StoryCategory.moral,
      isStoryOfTheDay: false,
      description: 'A tale of honesty and gratitude by the river.',
      captions: _caps([
        [0.12, 3.32, 'Once upon a time, there was a very honest woodcutter.'],
        [4.08, 6.98, 'He lived in a small village near a large forest.'],
        [
          7.98,
          11.34,
          'Every day, he went to the forest to cut wood to sell in the market.',
        ],
        [
          12.46,
          17.22,
          'One hot day, while cutting a branch near a river, his axe slipped from his hands.',
        ],
        [
          18.06,
          22.22,
          '"Oh no! My only axe has fallen into the deep river!" he cried.',
          true,
        ],
        [
          23.14,
          28.04,
          'He sat by the river and began to cry, wondering how he would feed his family.',
        ],
        [
          29.16,
          32.66,
          'Suddenly, a kind angel appeared from the sparkling water.',
        ],
        [
          33.56,
          39.78,
          'The angel held up a golden axe and asked, "Is this yours?" The woodcutter shook his head.',
        ],
        [
          40.34,
          45.06,
          '"No, that is not mine." The angel then showed a silver axe.',
        ],
        [
          45.86,
          53.42,
          'Again, the woodcutter said, "That is not mine either." Finally, the angel brought out his old simple axe.',
        ],
        [54.40, 57.14, '"Yes, that one is mine," he smiled.'],
        [
          58.24,
          63.46,
          'The angel was so pleased with his honesty that she gave him all three axes as a gift.',
        ],
        [
          64.58,
          69.84,
          'The woodcutter thanked Allah for helping honest people, and he lived happily ever after.',
        ],
      ]),
    ),
    Story(
      id: 'brave_little_ant',
      title: 'The Brave Little Ant',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/brave_little_ant.png',
      audioAsset: 'assets/audio/brave_little_ant.mp3',
      category: StoryCategory.animals,
      description: 'A tiny ant proves that kindness comes in all sizes.',
      captions: _caps([
        [
          0.12,
          6.26,
          'Once upon a time, in a green garden, there lived a tiny, brave ant named Zayd.',
        ],
        [7.42, 7.92, 'One day,'],
        [8.30, 10.92, 'Zayd saw a dove drinking water by the stream.'],
        [
          11.92,
          16.20,
          'Suddenly, a strong wind blew and the dove fell into the water!',
          true,
        ],
        [17.14, 19.86, 'The little ant did not think of his own small size.'],
        [
          20.52,
          23.52,
          'He quickly picked up a leaf and pushed it into the water.',
        ],
        [24.48, 27.40, '"Climb onto the leaf, dear dove!" he called out.'],
        [28.34, 31.54, 'The dove climbed on and floated safely to the shore.'],
        [32.54, 34.78, 'She flew away, chirping with joy.'],
        [
          35.44,
          45.00,
          '"Thank you, brave little ant!" A hunter nearby was about to catch the dove with a net, but the ant saw him and quickly bit the hunter\'s foot.',
          true,
        ],
        [
          45.96,
          51.26,
          '"Ouch!" cried the hunter, and the net fell, and the dove flew away to safety.',
        ],
        [
          52.34,
          58.34,
          'From that day on, everyone in the garden learned that even the smallest friend can do the biggest kindness.',
        ],
      ]),
    ),
    Story(
      id: 'prophet_salih',
      title: 'Story of Prophet Salih',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/prophet_salih_symbolic.png',
      audioAsset: 'assets/audio/prophet_salih_story.mp3',
      category: StoryCategory.prophets,
      description: 'The miracle of the she-camel and a lesson in gratitude.',
      captions: _caps([
        [0.14, 1.04, 'Long, long ago,'],
        [
          1.62,
          5.64,
          'Allah sent a Prophet named Salih to a town called Thamud.',
        ],
        [
          6.84,
          15.70,
          'The people of Thamud were skilled builders who carved beautiful homes into the mountains, but many of them worshipped idols instead of Allah.',
        ],
        [
          16.94,
          21.98,
          'Prophet Salih told them, "O my people, worship Allah alone.',
        ],
        [
          22.74,
          28.56,
          'He created you and gave you everything." The people asked for a sign.',
        ],
        [
          29.60,
          34.92,
          'Allah caused a magnificent she-camel to come out of solid rock as a miracle!',
          true,
        ],
        [36.14, 40.02, 'Prophet Salih said, "This camel is a sign from Allah.'],
        [
          40.90,
          52.14,
          'Let her drink and graze freely, and never harm her." Most people were amazed, but a few proud men refused to listen and hurt the poor camel.',
        ],
        [
          53.32,
          60.94,
          'Prophet Salih warned them sadly, "You have only three days left to repent," but they did not listen.',
        ],
        [61.92, 64.78, 'And so the town learned an important lesson.'],
        [
          65.80,
          72.18,
          'Always be grateful for Allah\'s blessings, and never be too proud to listen to good advice.',
        ],
      ]),
    ),
    Story(
      id: 'bedtime_dua',
      title: "Bedtime Du'a Journey",
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/bedtime_dua_journey.png',
      audioAsset: 'assets/audio/bedtime_dua_journey.mp3',
      category: StoryCategory.bedtime,
      description: "A gentle bedtime du'a to help little ones drift to sleep.",
      captions: _caps([
        [
          0.10,
          3.66,
          'It is nighttime, and the stars are twinkling in the sky.',
        ],
        [
          4.36,
          9.46,
          'Before we close our eyes to sleep, let us remember our beautiful bedtime dua.',
        ],
        [
          10.24,
          14.98,
          'Place your right hand under your cheek, just like the little birds resting in their nest.',
        ],
        [
          15.82,
          25.74,
          'Now, softly say, "Bismika Allahumma amutu wa ahya." This means, "In Your name, O Allah,',
          true,
        ],
        [25.90, 26.56, 'O Allah,'],
        [
          26.98,
          33.20,
          'I die and I live." Allah is always watching over us, even in our dreams.',
        ],
        [
          33.54,
          38.44,
          'He keeps us safe through the dark night, and He will wake us up again with the morning light.',
        ],
        [
          39.44,
          44.66,
          'So close your eyes now, little one, and think of all the good things that happened today.',
        ],
        [
          45.40,
          49.88,
          'Thank Allah for your family, your toys, and your cozy bed.',
        ],
        [
          50.84,
          55.72,
          'Good night, sleep tight, and may your dreams be filled with light.',
        ],
      ]),
    ),
    Story(
      id: 'little_lamb',
      title: 'The Little Lamb Who Shared',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/little_lamb_shared.png',
      audioAsset: 'assets/audio/little_lamb_shared.mp3',
      category: StoryCategory.animals,
      description: 'Nur the lamb learns that sharing doubles the sweetness.',
      captions: _caps([
        [
          0.10,
          4.04,
          'On a sunny green hill, there lived a fluffy little lamb named Noor.',
        ],
        [5.00, 5.54, 'One morning,'],
        [5.72, 8.82, 'Noor found a big juicy orange carrot in the grass.'],
        [9.50, 10.14, '"Yummy!'],
        [10.38, 12.72, 'This is all mine," she said happily.'],
        [
          13.56,
          17.98,
          'But then she saw a small bunny nearby looking very hungry and sad.',
        ],
        [
          18.96,
          34.90,
          'Noor remembered what her mother always told her, "Sharing makes Allah happy, and it makes our hearts warm too." So Noor walked over to the bunny and said, "Would you like to share this carrot with me, my friend?" The bunny\'s eyes lit up with joy.',
          true,
        ],
        [35.62, 36.16, '"Really?'],
        [
          36.52,
          42.86,
          'Thank you so much." They sat together under the warm sun, munching happily on the carrot.',
        ],
        [43.28, 44.38, 'And from that day on,'],
        [
          44.70,
          47.84,
          'Noor and the little bunny became the very best of friends.',
        ],
        [48.86, 51.32, 'Sharing had made their day twice as sweet.'],
      ]),
    ),
    Story(
      id: 'ocean_whispers',
      title: 'Ocean Whispers',
      narrator: 'Imaan & Akhlaq',
      coverAsset: 'assets/covers/ocean_whispers.png',
      audioAsset: 'assets/audio/ocean_whispers.mp3',
      category: StoryCategory.nature,
      isStoryOfTheDay: true,
      description:
          'A calming ocean journey to relax little minds before sleep.',
      captions: _caps([
        [0.08, 4.66, 'Close your eyes and imagine the gentle ocean at sunset.'],
        [
          5.90,
          14.00,
          'Listen to the soft waves rolling onto the sandy shore again and again, like a slow and peaceful breath.',
        ],
        [
          15.36,
          22.44,
          'The sky glows in warm orange and soft pink colors, and a cool breeze carries the smell of the sea.',
        ],
        [
          23.48,
          28.76,
          'Somewhere far away, a seagull calls out gently before flying home for the night.',
        ],
        [
          29.66,
          33.40,
          'The water sparkles like tiny stars dancing on its surface.',
        ],
        [
          34.18,
          41.38,
          'With every wave, feel your body becoming calmer and softer, like the sand being smoothed by the water.',
          true,
        ],
        [
          42.50,
          54.52,
          'There is nothing to worry about here, only peace and the endless gentle rhythm of the ocean rocking you slowly, softly into a deep and restful sleep.',
        ],
      ]),
    ),
  ];

  static Story get storyOfTheDay => allStories.firstWhere(
    (s) => s.isStoryOfTheDay,
    orElse: () => allStories.first,
  );

  static List<Story> byCategory(StoryCategory category) =>
      allStories.where((s) => s.category == category).toList();

  static Story? byId(String id) {
    for (final s in allStories) {
      if (s.id == id) return s;
    }
    return null;
  }

  static List<Story> search(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];
    return allStories
        .where(
          (s) =>
              s.title.toLowerCase().contains(q) ||
              s.category.label.toLowerCase().contains(q) ||
              s.description.toLowerCase().contains(q),
        )
        .toList();
  }
}
