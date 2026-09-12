import 'package:flutter/material.dart';

import 'storage_service.dart';

/// Holds the active [ThemeMode] and persists it via [StorageService].
class ThemeController extends ChangeNotifier {
  ThemeController() : _mode = StorageService.getThemeMode();

  ThemeMode _mode;
  ThemeMode get mode => _mode;

  /// Whether dark mode is effectively on for the given platform brightness.
  bool isDark(BuildContext context) {
    switch (_mode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    await StorageService.setThemeMode(mode);
  }

  /// Quick toggle used by the moon/sun button: switches between explicit
  /// light and dark (leaving "system" once the user expresses a preference).
  Future<void> toggle(BuildContext context) =>
      setMode(isDark(context) ? ThemeMode.light : ThemeMode.dark);
}
