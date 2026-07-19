import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../data/settings_repository_impl.dart';
import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(sharedPreferencesProvider)),
);

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

class SettingsController extends Notifier<AppSettings> {
  SettingsRepository get _repository => ref.read(settingsRepositoryProvider);

  @override
  AppSettings build() => _repository.load();

  void _update(AppSettings next) {
    state = next;
    _repository.save(next);
  }

  void setThemeMode(AppThemeMode mode) =>
      _update(state.copyWith(themeMode: mode));

  void setVoiceName(String voice) => _update(state.copyWith(voiceName: voice));

  void setLanguageCode(String code) =>
      _update(state.copyWith(languageCode: code));

  void setNotificationsEnabled(bool enabled) =>
      _update(state.copyWith(notificationsEnabled: enabled));

  void setMorningBriefingEnabled(bool enabled) =>
      _update(state.copyWith(morningBriefingEnabled: enabled));

  void setDeveloperMode(bool enabled) =>
      _update(state.copyWith(developerMode: enabled));
}
