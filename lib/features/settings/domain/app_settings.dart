import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

enum AppThemeMode { system, light, dark }

@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(AppThemeMode.dark) AppThemeMode themeMode,
    @Default('AURA') String voiceName,
    @Default('en') String languageCode,
    @Default(true) bool notificationsEnabled,
    @Default(true) bool morningBriefingEnabled,
    @Default(false) bool developerMode,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
