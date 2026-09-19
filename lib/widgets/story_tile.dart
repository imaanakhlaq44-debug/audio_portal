import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/story.dart';
import '../models/story_category.dart';
import '../services/audio_player_service.dart';
import '../services/premium_service.dart';
import '../theme/app_theme.dart';
import '../theme/text_direction.dart';
import 'story_progress_bar.dart';

/// A single row entry used in Library, categories and search results.
///
/// Shows cover, title, category/duration, saved progress bar, and a play /
/// pause button that reflects the live player state for this story. Without
/// Premium, a locked episode shows a lock and the free one a "Free preview"
/// badge.
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
    final premium = context.watch<PremiumService>();
    final locked = premium.isLocked(story);
    final preview = !premium.isPremium && premium.isPreview(story);
    return Consumer<AudioPlayerService>(
      builder: (context, player, _) {
        final isCurrent = player.currentStory?.id == story.id;
        final showPause = isCurrent && player.isPlaying;
        final loading = isCurrent && player.isLoading;

        return Semantics(
          button: true,
          label:
              '${story.title}, ${story.category.label}'
              '${locked ? ', Premium' : (preview ? ', free preview' : '')}',
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
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            story.coverAsset,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            // Dimmed while locked.
                            color: locked
                                ? Colors.black.withValues(alpha: 0.35)
                                : null,
                            colorBlendMode: locked ? BlendMode.darken : null,
                          ),
                        ),
                        if (locked)
                          const Positioned.fill(
                            child: Center(
                              child: Icon(
                                Icons.lock_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.title,
                            textDirection: textDirectionOf(story.title),
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
                          if (preview) ...[
                            const SizedBox(height: 6),
                            const _Badge(label: 'FREE PREVIEW'),
                          ],
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
                      locked: locked,
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

/// Small pill that marks the free preview episode.
class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: c.success.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: AppTheme.body(
          size: 10,
          weight: FontWeight.w700,
          color: c.success,
        ).copyWith(letterSpacing: 0.6),
      ),
    );
  }
}

/// Round orange play/pause button reused across tiles and the hero card.
/// When [locked] it shows a lock on the brand pink instead.
class PlayCircleButton extends StatelessWidget {
  final double size;
  final bool isPlaying;
  final bool isLoading;
  final bool locked;
  final VoidCallback onTap;

  const PlayCircleButton({
    super.key,
    required this.size,
    required this.isPlaying,
    required this.onTap,
    this.isLoading = false,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: locked ? 'Unlock with Premium' : (isPlaying ? 'Pause' : 'Play'),
      child: Material(
        color: locked ? c.primary : c.secondary,
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
                      locked
                          ? Icons.lock_rounded
                          : (isPlaying ? Icons.pause : Icons.play_arrow),
                      color: Colors.white,
                      size: size * (locked ? 0.45 : 0.55),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
