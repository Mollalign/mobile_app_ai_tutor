import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Theme mode state notifier that persists user preference.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _storageKey = 'theme_mode';
  final _storage = const FlutterSecureStorage();

  @override
  ThemeMode build() {
    // Load saved preference on initialization
    _loadSavedTheme();
    return ThemeMode.system; // Default to system
  }

  /// Load the saved theme preference from storage.
  Future<void> _loadSavedTheme() async {
    try {
      final saved = await _storage.read(key: _storageKey);
      if (saved != null) {
        state = ThemeMode.values.firstWhere(
          (mode) => mode.name == saved,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (_) {
      // Ignore errors, use default
    }
  }

  /// Set the theme mode and persist it.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      await _storage.write(key: _storageKey, value: mode.name);
    } catch (_) {
      // Ignore storage errors
    }
  }

  /// Toggle between light and dark mode.
  /// If currently system, switches to the opposite of current brightness.
  Future<void> toggleTheme(BuildContext context) async {
    if (state == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (state == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      // System mode - switch to opposite of current system brightness
      final brightness = MediaQuery.of(context).platformBrightness;
      if (brightness == Brightness.dark) {
        await setThemeMode(ThemeMode.light);
      } else {
        await setThemeMode(ThemeMode.dark);
      }
    }
  }

  /// Cycle through: System → Light → Dark → System
  Future<void> cycleThemeMode() async {
    switch (state) {
      case ThemeMode.system:
        await setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.system);
        break;
    }
  }
}

/// Provider for theme mode.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

/// Helper extension for ThemeMode display.
extension ThemeModeExtension on ThemeMode {
  String get displayName {
    switch (this) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  IconData get icon {
    switch (this) {
      case ThemeMode.system:
        return LucideIcons.monitor;
      case ThemeMode.light:
        return LucideIcons.sun;
      case ThemeMode.dark:
        return LucideIcons.moon;
    }
  }
}
