import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/story.dart';
import '../models/story_category.dart';
import '../services/audio_player_service.dart';
import '../theme/app_theme.dart';
import 'story_progress_bar.dart';

/// A single row entry used in Library, categories and search results.
///
/// Shows cover, title, category/duration, saved progress bar, and a play /
/// pause button that reflects the live player state for this story.
class StoryTile extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;
  final VoidCallback onPlay;

  const StoryTile({
    super.key,
    required this.story,
    required this.onTap,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Consumer<AudioPlayerService>(
      builder: (context, player, _) {
        final isCurrent = player.currentStory?.id == story.id;
        final showPause = isCurrent && player.isPlaying;
        final loading = isCurrent && player.isLoading;

        return Semantics(
          button: true,
          label: '${story.title}, ${story.category.label}',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCurrent ? c.surfaceHigh : c.surfaceLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCurrent
                        ? c.secondary.withValues(alpha: 0.5)
                        : c.outlineVariant.withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: c.shadow.withValues(alpha: c.isDark ? 0.25 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        story.coverAsset,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.body(
                              size: 16,
                              weight: FontWeight.w600,
                              color: c.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '${story.category.label} • ${story.durationLabel}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.body(
                                    size: 13,
                                    color: c.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              StoryProgressLabel(
                                storyId: story.id,
                                style: AppTheme.body(
                                  size: 12,
                                  weight: FontWeight.w600,
                                  color: c.secondaryDeep,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          StoryProgressBar(storyId: story.id),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    PlayCircleButton(
                      size: 44,
                      isPlaying: showPause,
                      isLoading: loading,
                      onTap: onPlay,
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

/// Round orange play/pause button reused across tiles and the hero card.
class PlayCircleButton extends StatelessWidget {
  final double size;
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onTap;

  const PlayCircleButton({
    super.key,
    required this.size,
    required this.isPlaying,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: isPlaying ? 'Pause' : 'Play',
      child: Material(
        color: c.secondary,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: size * 0.45,
                      height: size * 0.45,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: size * 0.55,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
