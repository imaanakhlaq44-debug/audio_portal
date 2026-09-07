import 'package:hive_flutter/hive_flutter.dart';

/// Lightweight Hive-backed local storage for:
/// - favorites (story ids)
/// - downloaded/saved story ids
/// - parents lock PIN + unlock state
/// - continue-listening (last played story + position)
class StorageService {
  static const String _settingsBox = 'settings_box';

  static const String _keyFavorites = 'favorites';
  static const String _keyDownloads = 'downloads';
  static const String _keyParentPin = 'parent_pin';
  static const String _keyLastStoryId = 'last_story_id';
  static const String _keyLastPositionMs = 'last_position_ms';
  static const String _keyChildName = 'child_name';

  static Box? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_settingsBox);

    // Default PIN if not set: 1234 (parents can change later)
    if (_box!.get(_keyParentPin) == null) {
      await _box!.put(_keyParentPin, '1234');
    }
    if (_box!.get(_keyChildName) == null) {
      await _box!.put(_keyChildName, 'Ali');
    }
  }

  static Box get _b {
    return _box!;
  }

  // ---------------- Favorites ----------------
  static List<String> getFavorites() {
    final raw = _b.get(_keyFavorites, defaultValue: <String>[]);
    return List<String>.from(raw as List);
  }

  static bool isFavorite(String storyId) => getFavorites().contains(storyId);

  static Future<void> toggleFavorite(String storyId) async {
    final favs = getFavorites();
    if (favs.contains(storyId)) {
      favs.remove(storyId);
    } else {
      favs.add(storyId);
    }
    await _b.put(_keyFavorites, favs);
  }

  // ---------------- Downloads / Saved ----------------
  static List<String> getDownloads() {
    final raw = _b.get(_keyDownloads, defaultValue: <String>[]);
    return List<String>.from(raw as List);
  }

  static bool isDownloaded(String storyId) => getDownloads().contains(storyId);

  static Future<void> toggleDownload(String storyId) async {
    final list = getDownloads();
    if (list.contains(storyId)) {
      list.remove(storyId);
    } else {
      list.add(storyId);
    }
    await _b.put(_keyDownloads, list);
  }

  // ---------------- Parents Lock ----------------
  static String getParentPin() =>
      _b.get(_keyParentPin, defaultValue: '1234') as String;

  static Future<void> setParentPin(String pin) async {
    await _b.put(_keyParentPin, pin);
  }

  static bool verifyPin(String pin) => pin == getParentPin();

  // ---------------- Continue Listening ----------------
  static String? getLastStoryId() => _b.get(_keyLastStoryId) as String?;

  static Duration getLastPosition() {
    final ms = _b.get(_keyLastPositionMs, defaultValue: 0) as int;
    return Duration(milliseconds: ms);
  }

  static Future<void> saveLastPlayed(String storyId, Duration position) async {
    await _b.put(_keyLastStoryId, storyId);
    await _b.put(_keyLastPositionMs, position.inMilliseconds);
  }

  // ---------------- Child Profile ----------------
  static String getChildName() =>
      _b.get(_keyChildName, defaultValue: 'Ali') as String;

  static Future<void> setChildName(String name) async {
    await _b.put(_keyChildName, name);
  }
}
