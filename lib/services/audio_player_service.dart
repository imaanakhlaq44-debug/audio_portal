import 'dart:async';
import 'dart:ui' show Color;

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/story.dart';
import 'storage_service.dart';
import 'story_audio_handler.dart';

/// App-facing playback controller (a [ChangeNotifier] consumed via Provider).
///
/// Responsibilities:
/// - drives [StoryAudioHandler] (background audio + notification controls),
/// - auto-saves listening progress every few seconds and on every pause/seek/
///   stop so "Continue Listening" survives app kills,
/// - resumes a story from where the child left off,
/// - sleep timer with live countdown and gentle volume fade-out,
/// - exposes position/duration/caption helpers for the UI.
class AudioPlayerService extends ChangeNotifier {
  AudioPlayerService._internal();

  static final AudioPlayerService instance = AudioPlayerService._internal();

  /// How often progress is flushed to storage while playing.
  static const Duration progressSaveInterval = Duration(seconds: 5);

  /// Sleep-timer fade-out length (capped to half the timer for short timers).
  static const Duration sleepFadeDuration = Duration(seconds: 30);

  late StoryAudioHandler _handler;
  bool _initialized = false;
  bool get isInitialized => _initialized;

  // ---- Transport state ----
  Story? _currentStory;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasCompleted = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String? _errorMessage;

  // ---- Sleep timer ----
  Duration? _sleepTimerTotal;
  Duration _sleepRemaining = Duration.zero;
  Timer? _sleepTicker;
  double _volume = 1.0;

  // ---- Progress persistence ----
  Timer? _progressTimer;
  Duration _lastSavedPosition = Duration.zero;

  final List<StreamSubscription> _subs = [];

  // ---- Getters ----
  Story? get currentStory => _currentStory;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  bool get hasCompleted => _hasCompleted;
  bool get hasActiveStory => _currentStory != null;
  Duration get position => _position;
  Duration get duration => _duration;
  String? get errorMessage => _errorMessage;

  bool get isSleepTimerActive => _sleepTimerTotal != null;
  Duration? get sleepTimerDuration => _sleepTimerTotal;
  Duration get sleepTimerRemaining => _sleepRemaining;
  bool get isFadingOut =>
      isSleepTimerActive && _sleepRemaining <= _fadeLength && _volume < 1.0;

  /// Must be called once before `runApp`.
  Future<void> init() async {
    if (_initialized) return;
    try {
      _handler = await AudioService.init<StoryAudioHandler>(
        builder: StoryAudioHandler.new,
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.imaanakhlaq.stories.audio',
          androidNotificationChannelName: 'Story playback',
          androidNotificationChannelDescription:
              'Controls for the story that is currently playing',
          androidNotificationIcon: 'drawable/ic_stat_notification',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
          androidShowNotificationBadge: false,
          notificationColor: Color(0xFFCA2962),
          fastForwardInterval: Duration(seconds: 10),
          rewindInterval: Duration(seconds: 10),
        ),
      );
    } catch (e, st) {
      // If the platform service can't be registered (rare; e.g. an unusual
      // web embedding) fall back to a bare handler so playback still works.
      if (kDebugMode) debugPrint('AudioService.init failed: $e\n$st');
      _handler = StoryAudioHandler();
    }
    _bindStreams();
    _initialized = true;
  }

  void _bindStreams() {
    final player = _handler.player;

    _subs.add(
      player
          .createPositionStream(
            minPeriod: const Duration(milliseconds: 200),
            maxPeriod: const Duration(milliseconds: 500),
          )
          .listen((pos) {
            // Ignore position events for a story we've already unloaded.
            if (_currentStory == null) return;
            _position = pos;
            if (_duration > Duration.zero && _position > _duration) {
              _position = _duration;
            }
            notifyListeners();
          }),
    );

    _subs.add(
      player.durationStream.listen((d) {
        if (d != null && d != _duration) {
          _duration = d;
          notifyListeners();
        }
      }),
    );

    _subs.add(
      player.playerStateStream.listen((state) {
        final wasPlaying = _isPlaying;
        _isPlaying = state.playing &&
            state.processingState != ProcessingState.completed &&
            state.processingState != ProcessingState.idle;
        _isLoading = state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering;

        if (_isPlaying && !wasPlaying) {
          _hasCompleted = false;
          _startProgressTimer();
        } else if (!_isPlaying && wasPlaying) {
          _stopProgressTimer();
          _saveProgress(force: true);
        }
        notifyListeners();
      }),
    );

    _subs.add(_handler.completedStream.listen((_) => _onCompleted()));

    _subs.add(
      _handler.playbackState.listen((s) {
        final err = s.processingState == AudioProcessingState.error
            ? (s.errorMessage ?? 'Playback error')
            : null;
        if (err != _errorMessage) {
          _errorMessage = err;
          notifyListeners();
        }
      }),
    );
  }

  // ------------------------------------------------------------------
  // Playback
  // ------------------------------------------------------------------

  /// Start (or resume) a story.
  ///
  /// - Same story already loaded → toggles to playing (restarts if finished).
  /// - New story → loads it, resuming from saved progress unless
  ///   [fromStart] is true or an explicit [startAt] is given.
  Future<void> playStory(
    Story story, {
    Duration? startAt,
    bool fromStart = false,
  }) async {
    assert(_initialized, 'AudioPlayerService.init() must be called first');
    final isSameStory = _currentStory?.id == story.id;

    if (isSameStory) {
      await _handler.play();
      return;
    }

    // Persist progress of the story we're leaving.
    if (_currentStory != null) await _saveProgress(force: true);

    Duration? resumeAt = startAt;
    if (resumeAt == null && !fromStart) {
      final saved = StorageService.getProgress(story.id);
      if (saved != null && saved.isResumable) resumeAt = saved.position;
    }

    _currentStory = story;
    _position = resumeAt ?? Duration.zero;
    _lastSavedPosition = _position;
    _duration = StorageService.getProgress(story.id)?.duration ?? Duration.zero;
    _hasCompleted = false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final d = await _handler.loadStory(story, initialPosition: resumeAt);
      if (d != null) _duration = d;
      // The user may have switched stories while this one was loading.
      if (_currentStory?.id != story.id) return;
      await _handler.play();
    } catch (e, st) {
      if (kDebugMode) debugPrint('Failed to load ${story.id}: $e\n$st');
      _errorMessage = 'Could not play this story. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_currentStory == null) return;
    if (_isPlaying) {
      await _handler.pause();
    } else {
      await _handler.play();
    }
  }

  Future<void> pause() async {
    if (_currentStory == null) return;
    await _handler.pause();
  }

  Future<void> seek(Duration target) async {
    if (_currentStory == null) return;
    var pos = target;
    if (pos < Duration.zero) pos = Duration.zero;
    if (_duration > Duration.zero && pos > _duration) pos = _duration;

    // Optimistic UI update.
    _position = pos;
    if (_duration == Duration.zero || pos < _duration) _hasCompleted = false;
    notifyListeners();

    await _handler.seek(pos);
    await _saveProgress(force: true);
  }

  Future<void> skipForward([Duration by = const Duration(seconds: 10)]) =>
      seek(_position + by);

  Future<void> skipBackward([Duration by = const Duration(seconds: 10)]) =>
      seek(_position - by);

  /// Restart the current story from the beginning.
  Future<void> restart() async {
    if (_currentStory == null) return;
    await seek(Duration.zero);
    if (!_isPlaying) await _handler.play();
  }

  /// Stop playback, persist progress and clear the mini-player.
  Future<void> stopAndClose() async {
    if (_currentStory == null) return;
    await _saveProgress(force: true);
    _stopProgressTimer();
    cancelSleepTimer(restoreVolume: true);

    final story = _currentStory;
    _currentStory = null;
    _isPlaying = false;
    _isLoading = false;
    _hasCompleted = false;
    _position = Duration.zero;
    _duration = Duration.zero;
    _errorMessage = null;
    notifyListeners();

    try {
      await _handler.stop();
    } catch (e) {
      if (kDebugMode) debugPrint('stop() failed for ${story?.id}: $e');
    }
  }

  Future<void> _onCompleted() async {
    final story = _currentStory;
    if (story == null) return;
    _stopProgressTimer();
    _isPlaying = false;
    _hasCompleted = true;
    _position = _duration;
    notifyListeners();
    await StorageService.markCompleted(story.id);
    _lastSavedPosition = Duration.zero;

    // A finished story shouldn't keep a pending sleep timer alive.
    if (isSleepTimerActive) cancelSleepTimer(restoreVolume: true);
  }

  // ------------------------------------------------------------------
  // Progress persistence
  // ------------------------------------------------------------------

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(progressSaveInterval, (_) {
      _saveProgress();
    });
  }

  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  Future<void> _saveProgress({bool force = false}) async {
    final story = _currentStory;
    if (story == null || _hasCompleted) return;
    // Skip redundant writes when nothing moved (e.g. paused for a while).
    if (!force && (_position - _lastSavedPosition).abs().inSeconds < 1) return;
    _lastSavedPosition = _position;
    try {
      await StorageService.saveProgress(
        story.id,
        position: _position,
        duration: _duration,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('saveProgress failed: $e');
    }
  }

  // ------------------------------------------------------------------
  // Sleep timer (with fade-out)
  // ------------------------------------------------------------------

  Duration get _fadeLength {
    final total = _sleepTimerTotal;
    if (total == null) return Duration.zero;
    final half = Duration(milliseconds: total.inMilliseconds ~/ 2);
    return sleepFadeDuration < half ? sleepFadeDuration : half;
  }

  /// Arm the sleep timer. Passing `null` turns it off.
  void setSleepTimer(Duration? duration) {
    cancelSleepTimer(restoreVolume: true);
    if (duration == null || duration <= Duration.zero) {
      notifyListeners();
      return;
    }
    _sleepTimerTotal = duration;
    _sleepRemaining = duration;
    StorageService.setLastSleepTimerMinutes(duration.inMinutes);
    notifyListeners();

    _sleepTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      _sleepRemaining -= const Duration(seconds: 1);
      if (_sleepRemaining <= Duration.zero) {
        _sleepRemaining = Duration.zero;
        _finishSleepTimer();
        return;
      }
      // Fade: linearly lower volume over the last [_fadeLength] seconds so
      // the audio never cuts abruptly and startles a drifting-off child.
      final fade = _fadeLength;
      if (fade > Duration.zero && _sleepRemaining <= fade) {
        final v = _sleepRemaining.inMilliseconds / fade.inMilliseconds;
        _applyVolume(v.clamp(0.05, 1.0));
      }
      notifyListeners();
    });
  }

  Future<void> _finishSleepTimer() async {
    _sleepTicker?.cancel();
    _sleepTicker = null;
    _sleepTimerTotal = null;
    _sleepRemaining = Duration.zero;
    await _handler.pause();
    await _saveProgress(force: true);
    // Restore volume so the next play isn't silent.
    _applyVolume(1.0);
    notifyListeners();
  }

  void cancelSleepTimer({bool restoreVolume = true}) {
    _sleepTicker?.cancel();
    _sleepTicker = null;
    _sleepTimerTotal = null;
    _sleepRemaining = Duration.zero;
    if (restoreVolume) _applyVolume(1.0);
  }

  void _applyVolume(double v) {
    if ((_volume - v).abs() < 0.001) return;
    _volume = v;
    _handler.setVolume(v);
  }

  // ------------------------------------------------------------------
  // Helpers for UI
  // ------------------------------------------------------------------

  CaptionLine? currentCaption(Story story) {
    for (final c in story.captions) {
      if (_position >= c.start && _position < c.end) return c;
    }
    return null;
  }

  double progress() {
    if (_duration.inMilliseconds == 0) return 0;
    return (_position.inMilliseconds / _duration.inMilliseconds).clamp(
      0.0,
      1.0,
    );
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _stopProgressTimer();
    cancelSleepTimer(restoreVolume: false);
    super.dispose();
  }
}
