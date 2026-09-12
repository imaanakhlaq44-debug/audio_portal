import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/story.dart';
import '../models/story_category.dart';
import '../models/story_data.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mini_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Story _storyOfTheDay;
  late List<Story> _bedtimeStories;

  @override
  void initState() {
    super.initState();
    _storyOfTheDay = StoryData.storyOfTheDay;
    _bedtimeStories = [
      ...StoryData.byCategory(StoryCategory.bedtime),
      ...StoryData.byCategory(StoryCategory.nature),
    ];
  }

  void _playStory(Story story) {
    AudioPlayerService.instance.playStory(story);
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// If the tapped story is the one currently loaded, toggle play/pause
  /// (the row shows a pause icon in that state); otherwise start it.
  void _togglePlay(Story story) {
    final player = AudioPlayerService.instance;
    if (player.currentStory?.id == story.id) {
      player.togglePlayPause();
    } else {
      player.playStory(story);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Rebuilds when the child's name is changed from Parents Dashboard.
          // ---- Top App Bar ----
          ValueListenableBuilder(
            valueListenable: StorageService.listenable(),
            builder: (context, _, __) {
              final childName = StorageService.getChildName();
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                color: AppTheme.surfaceContainerLowest,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryPink,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/child_avatar.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Salam, $childName!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.headline(
                          size: 20,
                          color: AppTheme.primaryPinkDeep,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.verified,
                      color: AppTheme.tertiaryBlue,
                      size: 26,
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Hero: Story of the Day ----
                  GestureDetector(
                    onTap: () => _playStory(_storyOfTheDay),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              _storyOfTheDay.coverAsset,
                              fit: BoxFit.cover,
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.65),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(
                                                  alpha: 0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                              ),
                                              child: const Text(
                                                'STORY OF THE DAY',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              _storyOfTheDay.title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _storyOfTheDay.description,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.9,
                                                ),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.secondaryOrange,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ---- Continue Listening (saved position from last close) ----
                  ValueListenableBuilder(
                    valueListenable: StorageService.listenable(),
                    builder: (context, _, __) {
                      final lastId = StorageService.getLastStoryId();
                      final last = lastId == null
                          ? null
                          : StoryData.byId(lastId);
                      final pos = StorageService.getLastPosition();
                      if (last == null || pos.inSeconds < 5) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Continue Listening',
                              style: AppTheme.headline(size: 20),
                            ),
                            const SizedBox(height: 14),
                            _QuickStoryRow(
                              story: last,
                              subtitle:
                                  'Resume from ${_fmt(pos)} • ${last.category.label}',
                              onPlay: () => AudioPlayerService.instance
                                  .playStory(last, startAt: pos),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // ---- Calm Bedtime Audio carousel ----
                  Text(
                    'Calm Bedtime Audio',
                    style: AppTheme.headline(size: 20),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 190,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _bedtimeStories.length,
                      itemBuilder: (context, index) {
                        final story = _bedtimeStories[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: GestureDetector(
                            onTap: () => _playStory(story),
                            child: SizedBox(
                              width: 140,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.asset(
                                      story.coverAsset,
                                      width: 140,
                                      height: 140,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    story.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.body(
                                      size: 14,
                                      weight: FontWeight.w600,
                                      color: AppTheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    '${story.durationLabel} • ${story.category.label}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.body(
                                      size: 12,
                                      color: AppTheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ---- All stories quick list ----
                  Text('All Stories', style: AppTheme.headline(size: 20)),
                  const SizedBox(height: 14),
                  ...StoryData.allStories.map(
                    (story) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _QuickStoryRow(
                        story: story,
                        onPlay: () => _togglePlay(story),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStoryRow extends StatelessWidget {
  final Story story;
  final VoidCallback onPlay;
  final String? subtitle;
  const _QuickStoryRow({
    required this.story,
    required this.onPlay,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, player, _) {
        final isCurrent = player.currentStory?.id == story.id;
        return InkWell(
          // Tapping the row: start the story (if not loaded) and open the
          // full Now Playing screen; the round button only toggles playback.
          onTap: () async {
            if (!isCurrent) await player.playStory(story);
            if (context.mounted) openNowPlaying(context);
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppTheme.surfaceContainerHigh
                  : AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppTheme.outlineVariant.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    story.coverAsset,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.body(
                          size: 14,
                          weight: FontWeight.w600,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      Text(
                        subtitle ??
                            '${story.category.label} • ${story.durationLabel}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.body(
                          size: 12,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: onPlay,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppTheme.secondaryOrange,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCurrent && player.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
