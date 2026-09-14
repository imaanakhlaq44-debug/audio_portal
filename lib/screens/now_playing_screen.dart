import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/story.dart';
import '../models/story_category.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  bool _showFullStory = false;
  bool _popScheduled = false;

  static String fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  void _showSleepTimerSheet(BuildContext context) {
    final player = context.read<AudioPlayerService>();
    final lastUsed = StorageService.getLastSleepTimerMinutes();
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final c = ctx.colors;
        const options = [5, 10, 15, 20, 30, 45, 60];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bedtime_rounded, color: c.secondary),
                    const SizedBox(width: 10),
                    Text(
                      'Sleep Timer',
                      style: AppTheme.headline(size: 20, color: c.headline),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Audio fades out gently before it stops.',
                  style: AppTheme.body(size: 13, color: c.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: options.map((m) {
                    final active =
                        player.isSleepTimerActive &&
                        player.sleepTimerDuration?.inMinutes == m;
                    final isLast = !active && lastUsed == m;
                    return ChoiceChip(
                      label: Text('$m min'),
                      selected: active,
                      avatar: isLast
                          ? Icon(Icons.history, size: 16, color: c.outline)
                          : null,
                      selectedColor: c.secondary,
                      backgroundColor: c.surface,
                      labelStyle: AppTheme.body(
                        size: 14,
                        weight: FontWeight.w600,
                        color: active ? Colors.white : c.onSurface,
                      ),
                      side: BorderSide(
                        color: c.outlineVariant.withValues(alpha: 0.3),
                      ),
                      onSelected: (_) {
                        player.setSleepTimer(Duration(minutes: m));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Sleep timer set for $m minutes'),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                if (player.isSleepTimerActive)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.timer_off_outlined, color: c.error),
                    title: Text(
                      'Turn off timer (${fmt(player.sleepTimerRemaining)} left)',
                      style: AppTheme.body(size: 15, color: c.onSurface),
                    ),
                    onTap: () {
                      player.setSleepTimer(null);
                      Navigator.pop(ctx);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Consumer<AudioPlayerService>(
      builder: (context, player, _) {
        final story = player.currentStory;
        if (story == null) {
          if (!_popScheduled) {
            _popScheduled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && Navigator.canPop(context)) Navigator.pop(context);
            });
          }
          return Scaffold(backgroundColor: c.background);
        }

        return Scaffold(
          backgroundColor: c.background,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    // ---- Top bar ----
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: Row(
                        children: [
                          _RoundIconButton(
                            icon: Icons.keyboard_arrow_down,
                            tooltip: 'Minimize',
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                          Text(
                            'Now Playing',
                            style: AppTheme.body(
                              size: 14,
                              weight: FontWeight.w700,
                              color: c.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          _RoundIconButton(
                            icon: Icons.close,
                            tooltip: 'Stop and close',
                            onTap: () {
                              _popScheduled = true;
                              Navigator.of(context).pop();
                              player.stopAndClose();
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        child: Column(
                          children: [
                            // ---- Album art ----
                            Hero(
                              tag: 'cover_${story.id}',
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: c.shadow.withValues(
                                        alpha: c.isDark ? 0.5 : 0.18,
                                      ),
                                      blurRadius: 30,
                                      offset: const Offset(0, 14),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.asset(
                                    story.coverAsset,
                                    width: 260,
                                    height: 260,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ---- Track info ----
                            Text(
                              story.category.label.toUpperCase(),
                              style: AppTheme.body(
                                size: 12,
                                weight: FontWeight.w700,
                                color: c.secondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              story.title,
                              textAlign: TextAlign.center,
                              style: AppTheme.headline(
                                size: 26,
                                color: c.headline,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              story.narrator,
                              style: AppTheme.body(
                                size: 15,
                                color: c.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ---- Sleep timer banner ----
                            if (player.isSleepTimerActive)
                              _SleepTimerBanner(
                                player: player,
                                onTap: () => _showSleepTimerSheet(context),
                              ),

                            // ---- Error banner ----
                            if (player.errorMessage != null)
                              _ErrorBanner(
                                message: player.errorMessage!,
                                onRetry: () =>
                                    player.playStory(story, fromStart: false),
                              ),

                            // ---- Progress ----
                            _ProgressSection(player: player),
                            const SizedBox(height: 16),

                            // ---- Caption card ----
                            _CaptionCard(
                              story: story,
                              player: player,
                              onTap: () =>
                                  setState(() => _showFullStory = true),
                            ),
                            const SizedBox(height: 24),

                            // ---- Primary controls ----
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  tooltip: 'Restart story',
                                  onPressed: () => player.restart(),
                                  icon: Icon(
                                    Icons.restart_alt_rounded,
                                    size: 26,
                                    color: c.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  tooltip: 'Back 10 seconds',
                                  onPressed: () => player.skipBackward(),
                                  icon: Icon(
                                    Icons.replay_10,
                                    size: 32,
                                    color: c.tertiary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _PlayPauseButton(player: player),
                                const SizedBox(width: 12),
                                IconButton(
                                  tooltip: 'Forward 10 seconds',
                                  onPressed: () => player.skipForward(),
                                  icon: Icon(
                                    Icons.forward_10,
                                    size: 32,
                                    color: c.tertiary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // Symmetric spacer so play stays centred.
                                const SizedBox(width: 48),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // ---- Secondary controls ----
                            ValueListenableBuilder(
                              valueListenable:
                                  StorageService.favoritesListenable(),
                              builder: (context, _, __) {
                                final fav = StorageService.isFavorite(story.id);
                                final saved = StorageService.isSaved(story.id);
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _SecondaryAction(
                                      icon: player.isSleepTimerActive
                                          ? Icons.bedtime
                                          : Icons.bedtime_outlined,
                                      label: player.isSleepTimerActive
                                          ? fmt(player.sleepTimerRemaining)
                                          : 'Timer',
                                      active: player.isSleepTimerActive,
                                      onTap: () =>
                                          _showSleepTimerSheet(context),
                                    ),
                                    const SizedBox(width: 36),
                                    _SecondaryAction(
                                      icon: fav
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      label: 'Favorite',
                                      active: fav,
                                      onTap: () =>
                                          StorageService.toggleFavorite(
                                            story.id,
                                          ),
                                    ),
                                    const SizedBox(width: 36),
                                    _SecondaryAction(
                                      // A bookmark, not a download - the
                                      // audio is already in the app.
                                      icon: saved
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      label: saved ? 'Saved' : 'Save',
                                      active: saved,
                                      onTap: () =>
                                          StorageService.toggleSaved(story.id),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                if (_showFullStory)
                  _FullStoryModal(
                    story: story,
                    player: player,
                    onClose: () => setState(() => _showFullStory = false),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _PlayPauseButton extends StatelessWidget {
  final AudioPlayerService player;
  const _PlayPauseButton({required this.player});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final IconData icon;
    if (player.hasCompleted) {
      icon = Icons.replay_rounded;
    } else if (player.isPlaying) {
      icon = Icons.pause;
    } else {
      icon = Icons.play_arrow;
    }
    return Semantics(
      button: true,
      label: player.hasCompleted
          ? 'Replay'
          : player.isPlaying
          ? 'Pause'
          : 'Play',
      child: GestureDetector(
        onTap: player.isLoading ? null : () => player.togglePlayPause(),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: c.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: c.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: player.isLoading
                ? const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                : Icon(icon, color: Colors.white, size: 40),
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: c.surfaceLowest,
        shape: const CircleBorder(),
        elevation: c.isDark ? 0 : 2,
        shadowColor: c.shadow.withValues(alpha: 0.15),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: c.onSurface),
          ),
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _SecondaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = active ? c.primary : c.onSurfaceVariant;
    return Semantics(
      button: true,
      toggled: active,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTheme.body(
                  size: 11,
                  weight: active ? FontWeight.w700 : FontWeight.w400,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SleepTimerBanner extends StatelessWidget {
  final AudioPlayerService player;
  final VoidCallback onTap;
  const _SleepTimerBanner({required this.player, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final total = player.sleepTimerDuration!;
    final remaining = player.sleepTimerRemaining;
    final frac = total.inMilliseconds == 0
        ? 0.0
        : (remaining.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
    final fading = player.isFadingOut;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: c.secondaryFixed,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                fading ? Icons.volume_down_rounded : Icons.bedtime_rounded,
                color: c.secondaryDeep,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fading
                          ? 'Fading out… sleeping in ${_NowPlayingScreenState.fmt(remaining)}'
                          : 'Sleeping in ${_NowPlayingScreenState.fmt(remaining)}',
                      style: AppTheme.body(
                        size: 13,
                        weight: FontWeight.w600,
                        color: c.isDark ? c.onSurface : c.secondaryDeep,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: frac,
                        minHeight: 4,
                        backgroundColor: c.secondaryDeep.withValues(
                          alpha: 0.15,
                        ),
                        color: c.secondaryDeep,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, color: c.secondaryDeep, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: c.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: c.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTheme.body(size: 13, color: c.onSurface),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _ProgressSection extends StatefulWidget {
  final AudioPlayerService player;
  const _ProgressSection({required this.player});

  @override
  State<_ProgressSection> createState() => _ProgressSectionState();
}

class _ProgressSectionState extends State<_ProgressSection> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final player = widget.player;
    final hasDuration = player.duration.inMilliseconds > 0;
    final progress = _dragValue ?? player.progress();
    final shownPosition = _dragValue == null
        ? player.position
        : Duration(
            milliseconds: (player.duration.inMilliseconds * _dragValue!)
                .round(),
          );
    final remaining = player.duration - shownPosition;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: SliderComponentShape.noOverlay,
            activeTrackColor: c.secondary,
            inactiveTrackColor: c.surfaceVariant,
            thumbColor: c.secondary,
            disabledActiveTrackColor: c.secondary.withValues(alpha: 0.4),
            disabledInactiveTrackColor: c.surfaceVariant,
            disabledThumbColor: c.outlineVariant,
          ),
          child: Semantics(
            slider: true,
            label: 'Playback position',
            value: _NowPlayingScreenState.fmt(shownPosition),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChangeStart: hasDuration
                  ? (v) => setState(() => _dragValue = v)
                  : null,
              onChanged: hasDuration
                  ? (v) => setState(() => _dragValue = v)
                  : null,
              onChangeEnd: hasDuration
                  ? (v) {
                      final newPos = Duration(
                        milliseconds: (player.duration.inMilliseconds * v)
                            .round(),
                      );
                      setState(() => _dragValue = null);
                      player.seek(newPos);
                    }
                  : null,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _NowPlayingScreenState.fmt(shownPosition),
                style: AppTheme.body(size: 12, color: c.onSurfaceVariant),
              ),
              Text(
                hasDuration
                    ? '-${_NowPlayingScreenState.fmt(remaining < Duration.zero ? Duration.zero : remaining)}'
                    : '--:--',
                style: AppTheme.body(size: 12, color: c.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CaptionCard extends StatelessWidget {
  final Story story;
  final AudioPlayerService player;
  final VoidCallback onTap;

  const _CaptionCard({
    required this.story,
    required this.player,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final caption = player.currentCaption(story);
    final text =
        caption?.text ??
        (story.captions.isNotEmpty ? story.captions.first.text : '');

    return Semantics(
      button: true,
      label: 'Read the full story',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.primary.withValues(alpha: 0.15)),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.open_in_full,
                  size: 16,
                  color: c.secondary.withValues(alpha: 0.7),
                ),
              ),
              Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      '"$text"',
                      key: ValueKey(text),
                      textAlign: TextAlign.center,
                      style: AppTheme.headline(
                        size: 16,
                        weight: FontWeight.w600,
                        color: c.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap to read the full story',
                    style: AppTheme.body(size: 12, color: c.secondaryDeep),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullStoryModal extends StatefulWidget {
  final Story story;
  final AudioPlayerService player;
  final VoidCallback onClose;

  const _FullStoryModal({
    required this.story,
    required this.player,
    required this.onClose,
  });

  @override
  State<_FullStoryModal> createState() => _FullStoryModalState();
}

class _FullStoryModalState extends State<_FullStoryModal> {
  final ScrollController _scroll = ScrollController();
  final Map<int, GlobalKey> _keys = {};
  int? _lastActiveIndex;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Auto-scroll so the active line stays in view while listening.
  void _ensureVisible(int index) {
    if (_lastActiveIndex == index) return;
    _lastActiveIndex = index;
    final ctx = _keys[index]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.3,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final activeCaption = widget.player.currentCaption(widget.story);
    final captions = widget.story.captions;
    final activeIndex = activeCaption == null
        ? -1
        : captions.indexWhere(
            (l) => l.start == activeCaption.start && l.end == activeCaption.end,
          );
    if (activeIndex >= 0) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _ensureVisible(activeIndex),
      );
    }

    return Positioned.fill(
      child: Container(
        color: c.background.withValues(alpha: 0.98),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Full Story',
                        style: AppTheme.headline(size: 20, color: c.headline),
                      ),
                    ),
                    _RoundIconButton(
                      icon: Icons.close,
                      tooltip: 'Close',
                      onTap: widget.onClose,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(20),
                  itemCount: captions.length,
                  itemBuilder: (context, i) {
                    final line = captions[i];
                    final isActive = i == activeIndex;
                    final key = _keys.putIfAbsent(i, GlobalKey.new);
                    return Padding(
                      key: key,
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () => widget.player.seek(line.start),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: line.isHighlight || isActive
                              ? const EdgeInsets.all(14)
                              : EdgeInsets.zero,
                          decoration: (line.isHighlight || isActive)
                              ? BoxDecoration(
                                  color: c.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: isActive
                                      ? Border.all(
                                          color: c.secondary,
                                          width: 1.5,
                                        )
                                      : null,
                                )
                              : null,
                          child: Text(
                            line.text,
                            style: AppTheme.headline(
                              size: 18,
                              weight: line.isHighlight
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isActive
                                  ? c.secondaryDeep
                                  : c.onSurface.withValues(
                                      alpha: line.isHighlight ? 1 : 0.65,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
