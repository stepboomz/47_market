import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A [StateNotifier] to manage the ThemeMode state
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light); // Default value is light mode

  /// Toggle between light and dark theme
  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  /// Set a specific theme
  void setTheme(ThemeMode mode) {
    state = mode;
  }
}

/// The provider for [ThemeModeNotifier]
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);
