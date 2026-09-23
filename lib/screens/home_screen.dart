import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/series.dart';
import '../models/story.dart';
import '../models/story_category.dart';
import '../models/story_data.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/child_avatar.dart';
import '../widgets/language_toggle.dart';
import '../widgets/mini_player.dart';
import '../widgets/series_card.dart';
import '../widgets/story_progress_bar.dart';
import '../widgets/story_tile.dart';
import '../widgets/theme_toggle_button.dart';
import 'series_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: StorageService.languageListenable(),
    builder: (context, _, __) => _build(context, StorageService.getLanguage()),
  );

  Widget _build(BuildContext context, StoryLanguage language) {
    final c = context.colors;
    final featured = StoryData.featuredOn(DateTime.now(), language: language);
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
                  _HeroCard(series: featured),
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

                  // ---- One row of series per category ----
                  for (final category in StoryCategory.values)
                    if (StoryData.seriesIn(category, language: language)
                        case final series when series.isNotEmpty) ...[
                      _SectionTitle(category.label),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 206,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: series.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 14),
                          itemBuilder: (context, i) =>
                              SeriesCard(series: series[i]),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
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
      builder: (context, _, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        color: c.surfaceLowest,
        child: Row(
          children: [
            const ChildAvatar(),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                StorageService.getChildName(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.headline(size: 20, color: c.primaryDeep),
              ),
            ),
            const SizedBox(width: 10),
            const LanguageToggle(),
            const SizedBox(width: 8),
            const ThemeToggleButton(),
          ],
        ),
      ),
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
  final Series series;
  const _HeroCard({required this.series});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, player, _) {
        final current = player.currentStory;
        final isCurrent =
            current != null && series.tracks.any((t) => t.id == current.id);
        return Semantics(
          button: true,
          label: 'Featured series: ${series.title}',
          child: GestureDetector(
            onTap: () => openSeries(context, series),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(series.coverAsset, fit: BoxFit.cover),
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
                                    'FEATURED SERIES',
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
                                  series.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${series.description} '
                                  '${series.episodeCountLabel} • '
                                  '${series.language.label}',
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
                            onTap: () => isCurrent
                                ? player.togglePlayPause()
                                : player.playStory(resumeTrackOf(series)),
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
