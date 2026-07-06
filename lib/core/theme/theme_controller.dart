import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the app's [ThemeMode] and persists the user's choice.
///
/// A simple [ChangeNotifier] so it can drive `MaterialApp.router` via a
/// [ListenableBuilder] without pulling in extra state-management for a single
/// value. Registered as a lazy singleton in the DI container.
class ThemeController extends ChangeNotifier {
  static const _prefsKey = 'theme_mode';

  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;

  /// Loads the saved preference (falls back to dark). Call once at startup.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      _mode = _fromString(saved);
      notifyListeners();
    } catch (_) {
      // Ignore storage errors — keep the default.
    }
  }

  /// Switches to [mode] and persists it.
  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, _toString(mode));
    } catch (_) {
      // Ignore storage errors — the in-memory choice still applies.
    }
  }

  /// Flips between light and dark (treats "system" as its resolved brightness).
  Future<void> toggle(BuildContext context) {
    final effectivelyDark = _mode == ThemeMode.dark ||
        (_mode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    return setMode(effectivelyDark ? ThemeMode.light : ThemeMode.dark);
  }

  static ThemeMode _fromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      case 'dark':
      default:
        return ThemeMode.dark;
    }
  }

  static String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.dark:
        return 'dark';
    }
  }
}
