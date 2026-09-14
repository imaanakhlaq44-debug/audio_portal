import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/story.dart';
import '../models/story_category.dart';
import '../models/story_data.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mini_player.dart';
import '../widgets/story_progress_bar.dart';
import '../widgets/story_tile.dart';
import '../widgets/theme_toggle_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Story _storyOfTheDay = StoryData.storyOfTheDay;
  late final List<Story> _bedtimeStories = [
    ...StoryData.byCategory(StoryCategory.bedtime),
    ...StoryData.byCategory(StoryCategory.nature),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _TopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroCard(story: _storyOfTheDay),
                  const SizedBox(height: 28),

                  // ---- Continue Listening ----
                  ValueListenableBuilder(
                    valueListenable: StorageService.progressListenable(),
                    builder: (context, _, __) {
                      final resumable = StorageService.getResumable();
                      if (resumable.isEmpty) return const SizedBox.shrink();
                      final items = resumable
                          .map((e) => (StoryData.byId(e.key), e.value))
                          .where((t) => t.$1 != null)
                          .take(3)
                          .toList();
                      if (items.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionTitle(
                              'Continue Listening',
                              trailing: TextButton(
                                onPressed: () => _confirmClearProgress(context),
                                child: Text(
                                  'Clear',
                                  style: AppTheme.body(
                                    size: 13,
                                    weight: FontWeight.w600,
                                    color: c.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            for (final (story, progress) in items)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _QuickStoryRow(
                                  story: story!,
                                  subtitle:
                                      'Resume from ${StoryProgressLabel.fmt(progress.position)} • ${_remaining(progress)} left',
                                  onPlay: () => togglePlayFor(context, story),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),

                  // ---- Calm Bedtime Audio carousel ----
                  const _SectionTitle('Calm Bedtime Audio'),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 196,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _bedtimeStories.length,
                      itemBuilder: (context, index) {
                        final story = _bedtimeStories[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: _CarouselCard(story: story),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ---- All stories quick list ----
                  const _SectionTitle('All Stories'),
                  const SizedBox(height: 14),
                  for (final story in StoryData.allStories)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _QuickStoryRow(
                        story: story,
                        onPlay: () => togglePlayFor(context, story),
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

  static String _remaining(StoryProgress p) {
    final left = p.duration - p.position;
    if (left <= Duration.zero) return '0 min';
    final mins = (left.inSeconds / 60).ceil();
    return '$mins min';
  }

  Future<void> _confirmClearProgress(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear listening history?'),
        content: const Text(
          'This removes all "Continue Listening" positions. Favorites are kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Clear', style: TextStyle(color: ctx.colors.error)),
          ),
        ],
      ),
    );
    if (ok == true) await StorageService.clearAllProgress();
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ValueListenableBuilder(
      valueListenable: StorageService.childNameListenable(),
      builder: (context, _, __) {
        final childName = StorageService.getChildName();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: c.surfaceLowest,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: c.primary, width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/child_avatar.webp',
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
                  style: AppTheme.headline(size: 20, color: c.primaryDeep),
                ),
              ),
              const SizedBox(width: 8),
              const ThemeToggleButton(),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const _SectionTitle(this.text, {this.trailing});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: AppTheme.headline(size: 20, color: c.headline),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Story story;
  const _HeroCard({required this.story});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, player, _) {
        final isCurrent = player.currentStory?.id == story.id;
        return Semantics(
          button: true,
          label: 'Story of the day: ${story.title}',
          child: GestureDetector(
            onTap: () => openStory(context, story),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(story.coverAsset, fit: BoxFit.cover),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(100),
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
                                  story.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  story.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          PlayCircleButton(
                            size: 52,
                            isPlaying: isCurrent && player.isPlaying,
                            isLoading: isCurrent && player.isLoading,
                            onTap: () => togglePlayFor(context, story),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CarouselCard extends StatelessWidget {
  final Story story;
  const _CarouselCard({required this.story});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: story.title,
      child: GestureDetector(
        onTap: () => openStory(context, story),
        child: SizedBox(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    Image.asset(
                      story.coverAsset,
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: StoryProgressBar(storyId: story.id, height: 5),
                    ),
                  ],
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
                  color: c.onSurface,
                ),
              ),
              Text(
                '${story.durationLabel} • ${story.category.label}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.body(size: 12, color: c.onSurfaceVariant),
              ),
            ],
          ),
        ),
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
    final c = context.colors;
    return Consumer<AudioPlayerService>(
      builder: (context, player, _) {
        final isCurrent = player.currentStory?.id == story.id;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => openStory(context, story),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCurrent ? c.surfaceHigh : c.surfaceLowest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isCurrent
                      ? c.secondary.withValues(alpha: 0.5)
                      : c.outlineVariant.withValues(alpha: 0.15),
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
                            color: c.onSurface,
                          ),
                        ),
                        Text(
                          subtitle ??
                              '${story.category.label} • ${story.durationLabel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.body(
                            size: 12,
                            color: c.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 5),
                        StoryProgressBar(storyId: story.id, height: 3),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  PlayCircleButton(
                    size: 38,
                    isPlaying: isCurrent && player.isPlaying,
                    isLoading: isCurrent && player.isLoading,
                    onTap: onPlay,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
