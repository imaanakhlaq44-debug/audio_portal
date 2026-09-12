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

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showSleepTimerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final options = [5, 10, 15, 30, 60];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sleep Timer', style: AppTheme.headline(size: 20)),
                const SizedBox(height: 16),
                ...options.map(
                  (m) => ListTile(
                    leading: const Icon(
                      Icons.bedtime_outlined,
                      color: AppTheme.secondaryOrange,
                    ),
                    title: Text(
                      '$m minutes',
                      style: AppTheme.body(size: 16, color: AppTheme.onSurface),
                    ),
                    onTap: () {
                      AudioPlayerService.instance.setSleepTimer(
                        Duration(minutes: m),
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sleep timer set for $m minutes'),
                        ),
                      );
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.close, color: AppTheme.error),
                  title: Text(
                    'Turn off',
                    style: AppTheme.body(size: 16, color: AppTheme.onSurface),
                  ),
                  onTap: () {
                    AudioPlayerService.instance.setSleepTimer(null);
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
    return Consumer<AudioPlayerService>(
      builder: (context, player, _) {
        final story = player.currentStory;
        if (story == null) {
          // Nothing playing (e.g. closed from mini-player) — close this screen
          // exactly once. Guarded so a rebuild can't trigger a second pop.
          if (!_popScheduled) {
            _popScheduled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && Navigator.canPop(context)) Navigator.pop(context);
            });
          }
          return const Scaffold(backgroundColor: AppTheme.background);
        }

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    // ---- Top bar: minimize + close ----
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: Row(
                        children: [
                          _RoundIconButton(
                            icon: Icons.keyboard_arrow_down,
                            onTap: () =>
                                Navigator.of(context).pop(), // Minimize
                          ),
                          const Spacer(),
                          Text(
                            'Now Playing',
                            style: AppTheme.body(
                              size: 14,
                              weight: FontWeight.w700,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          _RoundIconButton(
                            icon: Icons.close,
                            onTap: () {
                              // Pop first, then stop. Doing it the other way
                              // round made the Consumer above auto-pop AND
                              // this handler pop -> popped the MainScreen too
                              // and left a blank screen.
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
                            // ---- Album Art ----
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.asset(
                                story.coverAsset,
                                width: 260,
                                height: 260,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ---- Track info ----
                            Text(
                              story.category.label.toUpperCase(),
                              style: AppTheme.body(
                                size: 12,
                                weight: FontWeight.w700,
                                color: AppTheme.secondaryOrange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              story.title,
                              textAlign: TextAlign.center,
                              style: AppTheme.headline(size: 26),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              story.narrator,
                              style: AppTheme.body(
                                size: 15,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ---- Progress bar ----
                            _ProgressSection(
                              story: story,
                              player: player,
                              formatDuration: _formatDuration,
                            ),
                            const SizedBox(height: 20),

                            // ---- Synced Caption / subtitle card ----
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
                                  onPressed: () => player.skipBackward(),
                                  icon: const Icon(
                                    Icons.replay_10,
                                    size: 32,
                                    color: AppTheme.tertiaryBlue,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                GestureDetector(
                                  onTap: () => player.togglePlayPause(),
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryPink,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryPink
                                              .withValues(alpha: 0.35),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      player.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                IconButton(
                                  onPressed: () => player.skipForward(),
                                  icon: const Icon(
                                    Icons.forward_10,
                                    size: 32,
                                    color: AppTheme.tertiaryBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // ---- Secondary controls ----
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _SecondaryAction(
                                  icon: Icons.bedtime_outlined,
                                  label: player.sleepTimerDuration != null
                                      ? 'Timer On'
                                      : 'Timer',
                                  active: player.sleepTimerDuration != null,
                                  onTap: () => _showSleepTimerSheet(context),
                                ),
                                const SizedBox(width: 36),
                                _SecondaryAction(
                                  icon: StorageService.isFavorite(story.id)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  label: 'Favorite',
                                  active: StorageService.isFavorite(story.id),
                                  onTap: () async {
                                    await StorageService.toggleFavorite(
                                      story.id,
                                    );
                                    setState(() {});
                                  },
                                ),
                                const SizedBox(width: 36),
                                _SecondaryAction(
                                  icon: StorageService.isDownloaded(story.id)
                                      ? Icons.download_done
                                      : Icons.download_outlined,
                                  label: 'Save',
                                  active: StorageService.isDownloaded(story.id),
                                  onTap: () async {
                                    await StorageService.toggleDownload(
                                      story.id,
                                    );
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ---- Full story read-along overlay ----
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

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.navy.withValues(alpha: 0.08),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: AppTheme.onSurface),
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
    final color = active ? AppTheme.primaryPink : AppTheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: AppTheme.body(size: 11, color: color)),
        ],
      ),
    );
  }
}

class _ProgressSection extends StatefulWidget {
  final Story story;
  final AudioPlayerService player;
  final String Function(Duration) formatDuration;

  const _ProgressSection({
    required this.story,
    required this.player,
    required this.formatDuration,
  });

  @override
  State<_ProgressSection> createState() => _ProgressSectionState();
}

class _ProgressSectionState extends State<_ProgressSection> {
  /// While the user is dragging we show the drag value instead of the live
  /// playback position, and only issue ONE seek on release (instead of one
  /// seek per pixel, which stuttered the web audio backend).
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    final hasDuration = player.duration.inMilliseconds > 0;
    final progress = _dragValue ?? player.progress().clamp(0.0, 1.0);
    final shownPosition = _dragValue == null
        ? player.position
        : Duration(
            milliseconds: (player.duration.inMilliseconds * _dragValue!)
                .round(),
          );

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: SliderComponentShape.noOverlay,
            activeTrackColor: AppTheme.secondaryOrange,
            inactiveTrackColor: AppTheme.surfaceVariant,
            thumbColor: AppTheme.secondaryOrange,
          ),
          child: Slider(
            value: progress,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.formatDuration(shownPosition),
                style: AppTheme.body(
                  size: 12,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              Text(
                widget.formatDuration(player.duration),
                style: AppTheme.body(
                  size: 12,
                  color: AppTheme.onSurfaceVariant,
                ),
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
    final caption = player.currentCaption(story);
    final text =
        caption?.text ??
        (story.captions.isNotEmpty ? story.captions.first.text : '');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryPink.withValues(alpha: 0.15),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Icon(
                Icons.open_in_full,
                size: 16,
                color: AppTheme.secondaryOrange.withValues(alpha: 0.6),
              ),
            ),
            Column(
              children: [
                Text(
                  '"$text"',
                  textAlign: TextAlign.center,
                  style: AppTheme.headline(
                    size: 16,
                    weight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap to read the full story',
                  style: AppTheme.body(
                    size: 12,
                    color: AppTheme.secondaryOrangeDeep,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FullStoryModal extends StatelessWidget {
  final Story story;
  final AudioPlayerService player;
  final VoidCallback onClose;

  const _FullStoryModal({
    required this.story,
    required this.player,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final activeCaption = player.currentCaption(story);
    return Positioned.fill(
      child: Container(
        color: AppTheme.background.withValues(alpha: 0.97),
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
                        style: AppTheme.headline(size: 20),
                      ),
                    ),
                    _RoundIconButton(icon: Icons.close, onTap: onClose),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: story.captions.length,
                  itemBuilder: (context, i) {
                    final line = story.captions[i];
                    final isActive =
                        activeCaption != null &&
                        line.start == activeCaption.start &&
                        line.end == activeCaption.end;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () => player.seek(line.start),
                        child: Container(
                          padding: line.isHighlight || isActive
                              ? const EdgeInsets.all(14)
                              : EdgeInsets.zero,
                          decoration: (line.isHighlight || isActive)
                              ? BoxDecoration(
                                  color: AppTheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(16),
                                  border: isActive
                                      ? Border.all(
                                          color: AppTheme.secondaryOrange,
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
                                  ? AppTheme.secondaryOrangeDeep
                                  : AppTheme.onSurface.withValues(
                                      alpha: line.isHighlight ? 1 : 0.6,
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
