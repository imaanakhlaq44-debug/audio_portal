import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../models/story.dart';
import '../models/story_category.dart';

/// Bridges [just_audio] with [audio_service] so playback:
/// - continues when the screen is locked / app is backgrounded,
/// - shows a media notification with cover art + play/pause/skip controls,
/// - responds to headphone buttons / Bluetooth / Android Auto,
/// - pauses on phone calls & ducks for short interruptions,
/// - pauses when headphones are unplugged ("becoming noisy").
class StoryAudioHandler extends BaseAudioHandler with SeekHandler {
  StoryAudioHandler() {
    _init();
  }

  final AudioPlayer player = AudioPlayer();

  /// Asset path + id of the currently loaded story ('' when none).
  String _loadedStoryId = '';
  String get loadedStoryId => _loadedStoryId;

  /// Emits when the current item finishes (used by AudioPlayerService).
  final StreamController<void> _completedController =
      StreamController<void>.broadcast();
  Stream<void> get completedStream => _completedController.stream;

  bool _pausedByInterruption = false;

  Future<void> _init() async {
    // Configure OS audio session for spoken-word/music playback.
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());

      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              player.setVolume(0.3);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              if (player.playing) {
                _pausedByInterruption = true;
                player.pause();
              }
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              player.setVolume(1.0);
              break;
            case AudioInterruptionType.pause:
              if (_pausedByInterruption) {
                _pausedByInterruption = false;
                player.play();
              }
              break;
            case AudioInterruptionType.unknown:
              _pausedByInterruption = false;
              break;
          }
        }
      });

      // Headphones unplugged -> pause (don't blast a sleeping child's room).
      session.becomingNoisyEventStream.listen((_) {
        if (player.playing) player.pause();
      });
    } catch (e, st) {
      // audio_session isn't available on every platform (e.g. web). Playback
      // still works; we just lose interruption handling.
      if (kDebugMode) debugPrint('AudioSession unavailable: $e\n$st');
    }

    // Map just_audio state -> audio_service PlaybackState (drives the
    // notification / lock screen UI).
    player.playbackEventStream.listen(
      _broadcastState,
      onError: (Object e, StackTrace st) {
        if (kDebugMode) debugPrint('Playback error: $e');
        playbackState.add(
          playbackState.value.copyWith(
            processingState: AudioProcessingState.error,
            errorMessage: e.toString(),
          ),
        );
      },
    );

    player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _completedController.add(null);
      }
    });

    // Keep mediaItem duration in sync once the real duration is known.
    player.durationStream.listen((d) {
      final item = mediaItem.value;
      if (d != null && item != null && item.duration != d) {
        mediaItem.add(item.copyWith(duration: d));
      }
    });
  }

  void _broadcastState(PlaybackEvent event) {
    final playing = player.playing;
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.rewind,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.fastForward,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        // Indices into `controls` shown in the compact notification.
        androidCompactActionIndices: const [0, 1, 2],
        processingState: switch (player.processingState) {
          ProcessingState.idle => AudioProcessingState.idle,
          ProcessingState.loading => AudioProcessingState.loading,
          ProcessingState.buffering => AudioProcessingState.buffering,
          ProcessingState.ready => AudioProcessingState.ready,
          ProcessingState.completed => AudioProcessingState.completed,
        },
        playing: playing,
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        speed: player.speed,
        queueIndex: event.currentIndex,
      ),
    );
  }

  /// Load a story into the player and publish it as the current media item.
  /// Returns the loaded duration (may be null on some web backends until
  /// playback starts).
  Future<Duration?> loadStory(Story story, {Duration? initialPosition}) async {
    _loadedStoryId = story.id;
    _pausedByInterruption = false;

    mediaItem.add(
      MediaItem(
        id: story.id,
        title: story.title,
        artist: story.narrator,
        album: story.category.label,
        // Cover art shown on the lock screen / notification. Asset URIs are
        // supported by audio_service's Android art loader.
        artUri: Uri.parse('asset:///${story.coverAsset}'),
        displayDescription: story.description,
      ),
    );

    final duration = await player.setAudioSource(
      await _sourceFor(story),
      initialPosition: initialPosition,
      preload: true,
    );
    if (duration != null) {
      mediaItem.add(mediaItem.value?.copyWith(duration: duration));
    }
    return duration;
  }

  /// Audio is streamed from [Story.audioUrl] and saved to disk while it
  /// plays, so a story heard once plays again offline and costs no more
  /// data. The cache lives in app support storage (not the temp dir) so the
  /// OS doesn't purge it. It is keyed by the server path, so a re-recorded
  /// episode must be uploaded under a new file name to reach devices.
  Future<AudioSource> _sourceFor(Story story) async {
    // The caching proxy isn't available on web; stream directly there.
    if (kIsWeb) return AudioSource.uri(story.audioUrl);
    final dir = await getApplicationSupportDirectory();
    // Marked experimental, but it has been just_audio's caching source for
    // years; revisit if a just_audio upgrade changes it.
    // ignore: experimental_member_use
    return LockCachingAudioSource(
      story.audioUrl,
      cacheFile: File('${dir.path}/audio_cache/${story.audioKey}'),
    );
  }

  // ---- Transport controls (called by UI *and* by the OS notification) ----

  @override
  Future<void> play() async {
    _pausedByInterruption = false;
    // If we're at the very end, restart from the top instead of no-op.
    if (player.processingState == ProcessingState.completed) {
      await player.seek(Duration.zero);
    }
    await player.play();
  }

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> stop() async {
    await player.stop();
    _loadedStoryId = '';
    mediaItem.add(null);
    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
        updatePosition: Duration.zero,
      ),
    );
    await super.stop();
  }

  /// 10-second skips, matching the on-screen controls.
  @override
  Future<void> fastForward() => _skipBy(const Duration(seconds: 10));

  @override
  Future<void> rewind() => _skipBy(const Duration(seconds: -10));

  Future<void> _skipBy(Duration by) async {
    final total = player.duration ?? Duration.zero;
    var target = player.position + by;
    if (target < Duration.zero) target = Duration.zero;
    if (total > Duration.zero && target > total) target = total;
    await player.seek(target);
  }

  @override
  Future<void> setSpeed(double speed) => player.setSpeed(speed);

  /// Smoothly ramp volume (used by the sleep-timer fade-out).
  Future<void> setVolume(double volume) =>
      player.setVolume(volume.clamp(0.0, 1.0));

  @override
  Future<void> onTaskRemoved() async {
    // User swiped the app away from recents: stop the service so we don't
    // linger as a zombie notification.
    await stop();
    await super.onTaskRemoved();
  }

  Future<void> dispose() async {
    await _completedController.close();
    await player.dispose();
  }
}
