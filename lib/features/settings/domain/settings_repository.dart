import 'app_settings.dart';

abstract class SettingsRepository {
  AppSettings load();
  Future<void> save(AppSettings settings);
}
