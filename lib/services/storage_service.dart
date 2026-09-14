import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:hive_flutter/hive_flutter.dart';

import 'pin_service.dart';

/// Per-story playback progress persisted locally.
@immutable
class StoryProgress {
  final Duration position;
  final Duration duration;
  final bool completed;
  final DateTime updatedAt;
  final int playCount;

  const StoryProgress({
    required this.position,
    required this.duration,
    required this.completed,
    required this.updatedAt,
    this.playCount = 0,
  });

  /// 0.0 – 1.0 (0 when duration unknown).
  double get fraction {
    if (duration.inMilliseconds <= 0) return 0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  /// A story counts as "in progress" when the child listened to at least a
  /// few seconds and hasn't reached the end.
  bool get isResumable =>
      !completed &&
      position.inSeconds >= 5 &&
      (duration.inMilliseconds == 0 || fraction < 0.97);

  Map<String, dynamic> toMap() => {
    'pos': position.inMilliseconds,
    'dur': duration.inMilliseconds,
    'done': completed,
    'at': updatedAt.millisecondsSinceEpoch,
    'plays': playCount,
  };

  static StoryProgress? fromMap(dynamic raw) {
    if (raw is! Map) return null;
    final pos = raw['pos'];
    final dur = raw['dur'];
    final at = raw['at'];
    return StoryProgress(
      position: Duration(milliseconds: pos is int ? pos : 0),
      duration: Duration(milliseconds: dur is int ? dur : 0),
      completed: raw['done'] == true,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(at is int ? at : 0),
      playCount: raw['plays'] is int ? raw['plays'] as int : 0,
    );
  }
}

/// Hive-backed local storage:
/// - favorites / saved story ids
/// - parents PIN + child name
/// - theme mode (light / dark / system)
/// - per-story progress (position, duration, completed, play count)
class StorageService {
  StorageService._();

  static const String _settingsBox = 'settings_box';
  static const String _progressBox = 'progress_box';

  static const String _keyFavorites = 'favorites';

  /// Bookmarked story ids. The key still reads 'downloads' because that is
  /// what shipped; renaming it would mean migrating existing installs for
  /// no user-visible gain.
  static const String _keySaved = 'downloads';

  /// Plain-text PIN written by versions <= 1.1.0. Read once at startup so it
  /// can be hashed, then deleted.
  static const String _keyLegacyParentPin = 'parent_pin';

  static const String _keyPinHash = 'parent_pin_hash';
  static const String _keyPinSalt = 'parent_pin_salt';
  static const String _keyPinIterations = 'parent_pin_iterations';
  static const String _keyPinIsDefault = 'parent_pin_is_default';
  static const String _keyPinFailedAttempts = 'pin_failed_attempts';
  static const String _keyPinLockedUntil = 'pin_locked_until';

  static const String _keyChildName = 'child_name';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLastStoryId = 'last_story_id';
  static const String _keySleepTimerMinutes = 'sleep_timer_minutes';

  static const String defaultPin = '1234';
  static const String defaultChildName = 'Ali';

  static Box? _settings;
  static Box? _progress;

  static bool get isInitialized => _settings != null && _progress != null;

  /// [subDir] lets tests point Hive at a temp directory.
  static Future<void> init({String? subDir}) async {
    if (isInitialized) return;
    await Hive.initFlutter(subDir);
    _settings = await Hive.openBox(_settingsBox);
    _progress = await Hive.openBox(_progressBox);

    await _ensurePinCredential();
    if (_settings!.get(_keyChildName) == null) {
      await _settings!.put(_keyChildName, defaultChildName);
    }
  }

  /// Test helper – wipes and closes boxes.
  @visibleForTesting
  static Future<void> reset() async {
    await _settings?.clear();
    await _progress?.clear();
    await close();
  }

  /// Test helper – closes the boxes *without* wiping them, so a test can
  /// reopen them and exercise what happens across an app restart.
  @visibleForTesting
  static Future<void> close() async {
    await _settings?.close();
    await _progress?.close();
    _settings = null;
    _progress = null;
  }

  static Box get _s {
    assert(_settings != null, 'StorageService.init() must be called first');
    return _settings!;
  }

  static Box get _p {
    assert(_progress != null, 'StorageService.init() must be called first');
    return _progress!;
  }

  // ---------------- Listenables ----------------

  /// Fires when any setting (favorites, name, pin, theme, ...) changes.
  /// Pass [keys] to only rebuild for specific keys.
  static ValueListenable<Box> settingsListenable({List<String>? keys}) =>
      _s.listenable(keys: keys);

  static ValueListenable<Box> favoritesListenable() =>
      _s.listenable(keys: [_keyFavorites, _keySaved]);

  static ValueListenable<Box> childNameListenable() =>
      _s.listenable(keys: [_keyChildName]);

  static ValueListenable<Box> themeListenable() =>
      _s.listenable(keys: [_keyThemeMode]);

  /// Fires when any story's progress changes.
  static ValueListenable<Box> progressListenable() => _p.listenable();

  // ---------------- Favorites ----------------
  static List<String> getFavorites() => _stringList(_s.get(_keyFavorites));

  static bool isFavorite(String storyId) => getFavorites().contains(storyId);

  static Future<void> toggleFavorite(String storyId) async {
    final favs = getFavorites();
    favs.contains(storyId) ? favs.remove(storyId) : favs.add(storyId);
    await _s.put(_keyFavorites, favs);
  }

  static Future<void> clearFavorites() => _s.put(_keyFavorites, <String>[]);

  // ---------------- Saved stories ----------------
  //
  // A bookmark, not a download: every story's audio already ships inside the
  // app, so there is nothing to fetch. The UI used to call this "Download",
  // which promised offline access it was not providing.

  static List<String> getSavedStories() => _stringList(_s.get(_keySaved));

  static bool isSaved(String storyId) => getSavedStories().contains(storyId);

  static Future<void> toggleSaved(String storyId) async {
    final list = getSavedStories();
    list.contains(storyId) ? list.remove(storyId) : list.add(storyId);
    await _s.put(_keySaved, list);
  }

  static Future<void> clearSavedStories() => _s.put(_keySaved, <String>[]);

  // ---------------- Parents Lock ----------------

  /// Failures allowed before the pad starts locking out.
  static const int freePinAttempts = 4;

  /// Lockout applied after each further failure; the last entry repeats.
  static const List<Duration> pinLockoutLadder = [
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 15),
    Duration(minutes: 30),
  ];

  static bool isFourDigitPin(String pin) =>
      pin.length == 4 && pin.codeUnits.every((u) => u >= 0x30 && u <= 0x39);

  /// Seeds the PIN on a fresh install, and upgrades installs still holding
  /// the pre-1.2 plain-text PIN.
  static Future<void> _ensurePinCredential() async {
    final legacy = _settings!.get(_keyLegacyParentPin);
    final hasHash = _settings!.get(_keyPinHash) is String;

    if (hasHash) {
      // Nothing to do beyond clearing a stale plain-text leftover.
      if (legacy != null) await _settings!.delete(_keyLegacyParentPin);
      return;
    }

    final pin = legacy is String && isFourDigitPin(legacy)
        ? legacy
        : defaultPin;
    await _writePinCredential(pin);
    if (legacy != null) await _settings!.delete(_keyLegacyParentPin);
  }

  static Future<void> _writePinCredential(String pin) async {
    final cred = await PinService.create(pin);
    await _settings!.putAll({
      _keyPinHash: cred.hashB64,
      _keyPinSalt: cred.saltB64,
      _keyPinIterations: cred.iterations,
      _keyPinIsDefault: pin == defaultPin,
    });
  }

  static PinCredential? _pinCredential() {
    final hash = _s.get(_keyPinHash);
    final salt = _s.get(_keyPinSalt);
    final iterations = _s.get(_keyPinIterations);
    if (hash is! String || salt is! String || iterations is! int) return null;
    try {
      return PinCredential(
        salt: Uint8List.fromList(base64Decode(salt)),
        hash: Uint8List.fromList(base64Decode(hash)),
        iterations: iterations,
      );
    } on FormatException {
      return null;
    }
  }

  static Future<void> setParentPin(String pin) => _writePinCredential(pin);

  /// True while the PIN is still the shipped default, so the dashboard can
  /// nudge the parent to change it.
  static bool isUsingDefaultPin() => _s.get(_keyPinIsDefault) == true;

  /// Checks [pin] against the stored credential. Deliberately async: the
  /// derivation is slow by design and runs off the UI isolate.
  static Future<bool> verifyPin(String pin) async {
    final cred = _pinCredential();
    if (cred == null) {
      // Storage was cleared or corrupted. Re-seed rather than lock the
      // parent out of their own app for good.
      await _writePinCredential(defaultPin);
      return pin == defaultPin;
    }
    return PinService.verify(pin, cred);
  }

  // ---------------- PIN lockout ----------------

  static int failedPinAttempts() {
    final v = _s.get(_keyPinFailedAttempts);
    return v is int && v > 0 ? v : 0;
  }

  /// How long the pad stays locked, or [Duration.zero] when it is open.
  static Duration pinLockRemaining() {
    final until = _s.get(_keyPinLockedUntil);
    if (until is! int) return Duration.zero;
    final left = DateTime.fromMillisecondsSinceEpoch(
      until,
    ).difference(DateTime.now());
    return left > Duration.zero ? left : Duration.zero;
  }

  static bool isPinLocked() => pinLockRemaining() > Duration.zero;

  /// Tries left before the next failure triggers a lockout.
  static int pinAttemptsBeforeLockout() {
    final left = freePinAttempts - failedPinAttempts();
    return left > 0 ? left : 0;
  }

  /// Records a wrong PIN and returns the lockout it triggered
  /// ([Duration.zero] while the parent still has free tries).
  ///
  /// Both the counter and the deadline are persisted, so force-quitting the
  /// app does not hand out a fresh set of guesses.
  static Future<Duration> registerFailedPinAttempt() async {
    final attempts = failedPinAttempts() + 1;
    await _s.put(_keyPinFailedAttempts, attempts);

    if (attempts <= freePinAttempts) return Duration.zero;

    final step = attempts - freePinAttempts - 1;
    final lockout =
        pinLockoutLadder[step.clamp(0, pinLockoutLadder.length - 1)];
    await _s.put(
      _keyPinLockedUntil,
      DateTime.now().add(lockout).millisecondsSinceEpoch,
    );
    return lockout;
  }

  /// Called after a correct PIN: the ladder starts over.
  static Future<void> clearPinFailures() async {
    await _s.delete(_keyPinFailedAttempts);
    await _s.delete(_keyPinLockedUntil);
  }

  /// Fires while a lockout is armed or cleared, so the pad can redraw.
  static ValueListenable<Box> pinLockListenable() =>
      _s.listenable(keys: [_keyPinFailedAttempts, _keyPinLockedUntil]);

  // ---------------- Child Profile ----------------
  static String getChildName() {
    final v = _s.get(_keyChildName);
    return v is String && v.trim().isNotEmpty ? v : defaultChildName;
  }

  static Future<void> setChildName(String name) =>
      _s.put(_keyChildName, name.trim());

  // ---------------- Theme ----------------
  static ThemeMode getThemeMode() {
    switch (_s.get(_keyThemeMode)) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) =>
      _s.put(_keyThemeMode, mode.name);

  // ---------------- Sleep timer preference ----------------
  static int? getLastSleepTimerMinutes() {
    final v = _s.get(_keySleepTimerMinutes);
    return v is int ? v : null;
  }

  static Future<void> setLastSleepTimerMinutes(int minutes) =>
      _s.put(_keySleepTimerMinutes, minutes);

  // ---------------- Progress ----------------
  static StoryProgress? getProgress(String storyId) =>
      StoryProgress.fromMap(_p.get(storyId));

  static Map<String, StoryProgress> getAllProgress() {
    final out = <String, StoryProgress>{};
    for (final key in _p.keys) {
      final p = StoryProgress.fromMap(_p.get(key));
      if (p != null) out[key.toString()] = p;
    }
    return out;
  }

  /// Save the current playback position. Called periodically while playing
  /// and on pause/stop, so progress survives app kills.
  static Future<void> saveProgress(
    String storyId, {
    required Duration position,
    required Duration duration,
    bool? completed,
  }) async {
    final prev = getProgress(storyId);
    final isDone = completed ?? prev?.completed ?? false;
    await _p.put(
      storyId,
      StoryProgress(
        position: position,
        duration: duration.inMilliseconds > 0
            ? duration
            : (prev?.duration ?? Duration.zero),
        completed: isDone,
        updatedAt: DateTime.now(),
        playCount: prev?.playCount ?? 0,
      ).toMap(),
    );
    await _s.put(_keyLastStoryId, storyId);
  }

  /// Mark a story finished: position reset to 0 so the next play starts
  /// fresh, `completed` flag kept for the "✓ finished" badge & stats.
  static Future<void> markCompleted(String storyId) async {
    final prev = getProgress(storyId);
    await _p.put(
      storyId,
      StoryProgress(
        position: Duration.zero,
        duration: prev?.duration ?? Duration.zero,
        completed: true,
        updatedAt: DateTime.now(),
        playCount: (prev?.playCount ?? 0) + 1,
      ).toMap(),
    );
  }

  static Future<void> clearProgress(String storyId) async {
    await _p.delete(storyId);
    if (_s.get(_keyLastStoryId) == storyId) {
      await _s.delete(_keyLastStoryId);
    }
  }

  static Future<void> clearAllProgress() async {
    await _p.clear();
    await _s.delete(_keyLastStoryId);
  }

  /// Id of the most recently played story (regardless of progress).
  static String? getLastStoryId() {
    final v = _s.get(_keyLastStoryId);
    return v is String ? v : null;
  }

  /// Stories the child can resume, most recent first.
  static List<MapEntry<String, StoryProgress>> getResumable() {
    final entries = getAllProgress().entries
        .where((e) => e.value.isResumable)
        .toList();
    entries.sort((a, b) => b.value.updatedAt.compareTo(a.value.updatedAt));
    return entries;
  }

  /// Total completed listens across all stories (for parents stats).
  static int totalPlays() =>
      getAllProgress().values.fold(0, (sum, p) => sum + p.playCount);

  static int completedCount() =>
      getAllProgress().values.where((p) => p.completed).length;

  // ---------------- helpers ----------------
  static List<String> _stringList(dynamic raw) {
    if (raw is List) return raw.whereType<String>().toList();
    return <String>[];
  }
}
