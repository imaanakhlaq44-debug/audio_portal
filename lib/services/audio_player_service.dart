import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/story.dart';
import 'storage_service.dart';

/// Global singleton audio player service that powers both the persistent
/// mini-player and the full Now Playing screen. Extends ChangeNotifier so
/// the whole app can listen for state changes via Provider.
class AudioPlayerService extends ChangeNotifier {
  AudioPlayerService._internal() {
    _player.onPositionChanged.listen((pos) {
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

  Story? get currentStory => _currentStory;
  bool get isPlaying => _isPlaying;
  bool get hasActiveStory => _currentStory != null;
  Duration get position => _position;
  Duration get duration => _duration;
  Duration? get sleepTimerDuration => _sleepTimerDuration;

  Future<void> playStory(Story story, {Duration? startAt}) async {
    final isSameStory = _currentStory?.id == story.id;
    _currentStory = story;
    notifyListeners();

    if (!isSameStory) {
      await _player.stop();
      await _player.play(
        AssetSource(story.audioAsset.replaceFirst('assets/', '')),
      );
      if (startAt != null && startAt > Duration.zero) {
        await _player.seek(startAt);
      }
    } else {
      await _player.resume();
    }
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_currentStory == null) return;
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    _position = position;
    notifyListeners();
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
    _sleepTimerDuration = duration;
    notifyListeners();
    if (duration != null) {
      Future.delayed(duration, () {
        if (_sleepTimerDuration == duration) {
          _player.pause();
          _sleepTimerDuration = null;
          notifyListeners();
        }
      });
    }
  }

  Future<void> stopAndClose() async {
    if (_currentStory != null) {
      await StorageService.saveLastPlayed(_currentStory!.id, _position);
    }
    await _player.stop();
    _currentStory = null;
    _isPlaying = false;
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
