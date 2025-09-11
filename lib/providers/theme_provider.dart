import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brand_store_app/services/storage_service.dart';

/// A [StateNotifier] to manage the ThemeMode state
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _load();
  }

  Future<void> _load() async {
    final stored = await StorageService.loadThemeMode();
    if (stored == 'dark') {
      state = ThemeMode.dark;
    } else if (stored == 'light') {
      state = ThemeMode.light;
    }
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await StorageService.saveThemeMode(state == ThemeMode.dark ? 'dark' : 'light');
  }

  /// Set a specific theme
  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await StorageService.saveThemeMode(mode == ThemeMode.dark ? 'dark' : 'light');
  }
}

/// The provider for [ThemeModeNotifier]
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);
