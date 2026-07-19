import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._prefs);

  static const String _key = 'aura_settings';

  final SharedPreferences _prefs;

  @override
  AppSettings load() {
    final json = _prefs.getString(_key);
    if (json == null) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  @override
  Future<void> save(AppSettings settings) async {
    await _prefs.setString(_key, jsonEncode(settings.toJson()));
  }
}
