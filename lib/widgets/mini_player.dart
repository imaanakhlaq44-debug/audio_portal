import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/story.dart';
import '../screens/now_playing_screen.dart';
import '../services/audio_player_service.dart';
import '../theme/app_theme.dart';

/// Opens the full-screen Now Playing view with a slide-up transition.
void openNowPlaying(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => const NowPlayingScreen(),
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        );
      },
    ),
  );
}

/// Start a story (if it isn't already the current one) and open Now Playing.
Future<void> openStory(BuildContext context, Story story) async {
  final player = AudioPlayerService.instance;
  if (player.currentStory?.id != story.id) {
    await player.playStory(story);
  }
  if (context.mounted) openNowPlaying(context);
}

/// If the tapped story is the current one toggle play/pause, else start it.
void togglePlayFor(Story story) {
  final player = AudioPlayerService.instance;
  if (player.currentStory?.id == story.id) {
    player.togglePlayPause();
  } else {
    player.playStory(story);
  }
}

/// Persistent mini-player bar shown above the bottom navigation bar
/// whenever a story is loaded (playing or paused).
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Consumer<AudioPlayerService>(
      builder: (context, player, _) {
        final story = player.currentStory;
        if (story == null) return const SizedBox.shrink();

        final String status;
        if (player.errorMessage != null) {
          status = 'Tap to retry';
        } else if (player.isLoading) {
          status = 'Loading…';
        } else if (player.hasCompleted) {
          status = 'Finished • tap play to replay';
        } else if (player.isPlaying) {
          status = player.isSleepTimerActive
              ? 'Sleep in ${_fmt(player.sleepTimerRemaining)}'
              : 'Playing now…';
        } else {
          status = 'Paused';
        }

        return Semantics(
          label: 'Now playing ${story.title}. $status',
          child: GestureDetector(
            onTap: () => openNowPlaying(context),
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              decoration: BoxDecoration(
                color: c.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: c.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              story.coverAsset,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  story.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  status,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: player.isPlaying ? 'Pause' : 'Play',
                            onPressed: player.isLoading
                                ? null
                                : () => player.togglePlayPause(),
                            icon: player.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    player.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                          ),
                          IconButton(
                            tooltip: 'Close',
                            onPressed: () => player.stopAndClose(),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Slim live progress line along the bottom edge.
                    LinearProgressIndicator(
                      value: player.progress(),
                      minHeight: 3,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      color: Colors.white,
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

  static String _fmt(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
