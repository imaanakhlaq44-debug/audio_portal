import 'package:flutter/foundation.dart';
import 'package:imaan_akhlaq/models/story.dart';
import 'package:imaan_akhlaq/services/audio_player_service.dart';

/// A playback controller a test can steer.
///
/// The real service talks to `audio_service` and `just_audio`, neither of
/// which exists under `flutter_test`. Screens take the service from Provider,
/// so substituting this one exercises the actual widget code — what it draws
/// for a given playback state, and what it asks the player to do — without a
/// platform channel in sight.
///
/// State is writable; every command is recorded in [calls].
class FakePlayer extends AudioPlayerService {
  FakePlayer() : super.forTesting();

  /// Names of the transport methods the UI invoked, in order.
  final List<String> calls = [];

  Story? story;
  bool playing = false;
  bool loading = false;
  bool completed = false;
  Duration at = Duration.zero;
  Duration length = const Duration(minutes: 5);
  String? error;
  Duration? sleepTimer;
  Duration sleepLeft = Duration.zero;
  CaptionLine? caption;

  // ---- State the screens read ----

  @override
  Story? get currentStory => story;

  @override
  bool get isPlaying => playing;

  @override
  bool get isLoading => loading;

  @override
  bool get hasCompleted => completed;

  @override
  bool get hasActiveStory => story != null;

  @override
  Duration get position => at;

  @override
  Duration get duration => length;

  @override
  String? get errorMessage => error;

  @override
  bool get isSleepTimerActive => sleepTimer != null;

  @override
  Duration? get sleepTimerDuration => sleepTimer;

  @override
  Duration get sleepTimerRemaining => sleepLeft;

  @override
  bool get isFadingOut => false;

  @override
  CaptionLine? currentCaption(Story story) => caption;

  @override
  double progress() => length.inMilliseconds == 0
      ? 0
      : (at.inMilliseconds / length.inMilliseconds).clamp(0.0, 1.0);

  // ---- Commands the screens send ----

  @override
  Future<void> playStory(
    Story story, {
    Duration? startAt,
    bool fromStart = false,
  }) async {
    calls.add('playStory(${story.id}, fromStart: $fromStart)');
    this.story = story;
    playing = true;
    notifyListeners();
  }

  @override
  Future<void> togglePlayPause() async {
    calls.add('togglePlayPause');
    playing = !playing;
    notifyListeners();
  }

  @override
  Future<void> pause() async {
    calls.add('pause');
    playing = false;
    notifyListeners();
  }

  @override
  Future<void> seek(Duration target) async {
    calls.add('seek(${target.inSeconds}s)');
    at = target;
    notifyListeners();
  }

  @override
  Future<void> skipForward([Duration by = const Duration(seconds: 10)]) async {
    calls.add('skipForward');
    notifyListeners();
  }

  @override
  Future<void> skipBackward([Duration by = const Duration(seconds: 10)]) async {
    calls.add('skipBackward');
    notifyListeners();
  }

  @override
  Future<void> restart() async {
    calls.add('restart');
    at = Duration.zero;
    completed = false;
    notifyListeners();
  }

  @override
  Future<void> stopAndClose() async {
    calls.add('stopAndClose');
    story = null;
    playing = false;
    notifyListeners();
  }

  @override
  void setSleepTimer(Duration? duration) {
    calls.add('setSleepTimer(${duration?.inMinutes})');
    sleepTimer = duration;
    sleepLeft = duration ?? Duration.zero;
    notifyListeners();
  }

  @override
  void cancelSleepTimer({bool restoreVolume = true}) {
    calls.add('cancelSleepTimer');
    sleepTimer = null;
    sleepLeft = Duration.zero;
    notifyListeners();
  }

  /// Rewrites state and rebuilds listeners in one go.
  void emit(VoidCallback change) {
    change();
    notifyListeners();
  }
}
