import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/story.dart';
import 'storage_service.dart';

/// Global singleton audio player service that powers both the persistent
/// mini-player and the full Now Playing screen. Extends ChangeNotifier so
/// the whole app can listen for state changes via Provider.
class AudioPlayerService extends ChangeNotifier {
  AudioPlayerService._internal() {
    // Keep the source loaded after playback completes so the user can
    // replay / seek without the backend releasing the audio resource.
    _player.setReleaseMode(ReleaseMode.stop);

    _player.onPositionChanged.listen((pos) {
      // Guard against the web audio backend momentarily reporting a stale
      // position (often 0 or near-0) right after a seek() call, which was
      // causing skip-forward/backward and the progress slider to visually
      // "snap back to 00:00" before catching up. While a seek is pending,
      // ignore any incoming position that is clearly behind our target —
      // once the real position catches up (or the grace window expires)
      // we resume trusting the stream normally.
      if (_pendingSeekTarget != null) {
        final target = _pendingSeekTarget!;
        final elapsed = DateTime.now().difference(_pendingSeekAt!);
        final caughtUp =
            (pos - target).abs() < const Duration(milliseconds: 400);
        if (!caughtUp && elapsed < const Duration(milliseconds: 900)) {
          return; // ignore stale pre-seek position update
        }
        _pendingSeekTarget = null;
        _pendingSeekAt = null;
      }
      _position = pos;
      notifyListeners();
    });
    _player.onDurationChanged.listen((d) {
      _duration = d;
      notifyListeners();
    });
    _player.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
    _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _hasCompleted = true;
      _position = _duration;
      notifyListeners();
    });
  }

  static final AudioPlayerService instance = AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();

  Story? _currentStory;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Duration? _sleepTimerDuration;
  Timer? _sleepTimer;
  Duration? _pendingSeekTarget;
  DateTime? _pendingSeekAt;
  bool _hasCompleted = false;

  Story? get currentStory => _currentStory;
  bool get isPlaying => _isPlaying;
  bool get hasActiveStory => _currentStory != null;
  Duration get position => _position;
  Duration get duration => _duration;
  Duration? get sleepTimerDuration => _sleepTimerDuration;

  Future<void> playStory(Story story, {Duration? startAt}) async {
    final isSameStory = _currentStory?.id == story.id;
    _currentStory = story;

    if (!isSameStory) {
      // Reset transport state immediately so the UI doesn't briefly show the
      // previous story's position/duration on the new story.
      _position = startAt ?? Duration.zero;
      _duration = Duration.zero;
      _hasCompleted = false;
      _pendingSeekTarget = null;
      _pendingSeekAt = null;
      notifyListeners();

      await _player.stop();
      await _player.play(
        AssetSource(story.audioAsset.replaceFirst('assets/', '')),
      );
      if (startAt != null && startAt > Duration.zero) {
        await _player.seek(startAt);
      }
    } else {
      notifyListeners();
      await _resumeOrRestart();
    }
    _isPlaying = true;
    notifyListeners();
  }

  /// Resume playback; if the story already finished, restart from the top.
  Future<void> _resumeOrRestart() async {
    if (_hasCompleted) {
      _hasCompleted = false;
      _position = Duration.zero;
      notifyListeners();
      await _player.seek(Duration.zero);
    }
    await _player.resume();
  }

  Future<void> togglePlayPause() async {
    if (_currentStory == null) return;
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _resumeOrRestart();
    }
  }

  Future<void> seek(Duration position) async {
    // Optimistically update immediately so the UI (slider/time label)
    // reflects the new position without waiting for the platform stream,
    // and mark a pending-seek window so we can ignore any stale,
    // momentarily-reset position events the web audio backend may emit.
    _pendingSeekTarget = position;
    _pendingSeekAt = DateTime.now();
    _position = position;
    if (position < _duration) _hasCompleted = false;
    notifyListeners();
    await _player.seek(position);
  }

  Future<void> skipForward([Duration by = const Duration(seconds: 10)]) async {
    final newPos = _position + by;
    await seek(newPos > _duration ? _duration : newPos);
  }

  Future<void> skipBackward([Duration by = const Duration(seconds: 10)]) async {
    final newPos = _position - by;
    await seek(newPos < Duration.zero ? Duration.zero : newPos);
  }

  void setSleepTimer(Duration? duration) {
    // Always cancel any previously scheduled timer so an old one can't fire
    // early after the user re-arms the same duration.
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerDuration = duration;
    notifyListeners();
    if (duration != null) {
      _sleepTimer = Timer(duration, () {
        _player.pause();
        _sleepTimer = null;
        _sleepTimerDuration = null;
        notifyListeners();
      });
    }
  }

  Future<void> stopAndClose() async {
    if (_currentStory != null) {
      await StorageService.saveLastPlayed(_currentStory!.id, _position);
    }
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerDuration = null;
    await _player.stop();
    _currentStory = null;
    _isPlaying = false;
    _hasCompleted = false;
    _pendingSeekTarget = null;
    _pendingSeekAt = null;
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();
  }

  /// Minimize just hides the full player UI; playback continues.
  /// (No state change needed here — navigation handles the "minimize".)

  CaptionLine? currentCaption(Story story) {
    for (final c in story.captions) {
      if (_position >= c.start && _position < c.end) {
        return c;
      }
    }
    return null;
  }

  double progress() {
    if (_duration.inMilliseconds == 0) return 0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }
}
