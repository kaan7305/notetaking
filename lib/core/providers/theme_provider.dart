import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_notebook/core/storage/database_helper.dart';
import 'package:study_notebook/core/storage/preferences_dao.dart';

/// Key used to persist the theme mode in the [preferences] table.
const _kThemeModeKey = 'theme_mode';

/// Manages and persists the user's preferred [ThemeMode].
///
/// Initialises to [ThemeMode.system] on first launch. The chosen value is
/// stored in the local SQLite [preferences] table so it survives app restarts.
class ThemeSettingNotifier extends StateNotifier<ThemeMode> {
  final PreferencesDao _dao;

  ThemeSettingNotifier(this._dao) : super(ThemeMode.system) {
    _load();
  }

  /// Reads the persisted theme from SQLite and updates state.
  Future<void> _load() async {
    final raw = await _dao.get(_kThemeModeKey, defaultValue: 'system');
    if (!mounted) return;
    state = _parse(raw);
  }

  /// Changes the active theme mode and persists the new value.
  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await _dao.set(_kThemeModeKey, _encode(mode));
  }

  static ThemeMode _parse(String raw) => switch (raw) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static String _encode(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
}

final themeSettingProvider =
    StateNotifierProvider<ThemeSettingNotifier, ThemeMode>((ref) {
  final dao = PreferencesDao(DatabaseHelper.instance);
  return ThemeSettingNotifier(dao);
});
