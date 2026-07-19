import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Local notifications (morning briefing reminders, nudges).
///
/// TODO(backend): schedule the daily briefing notification — this needs the
/// timezone package and Android core-library desugaring, which is out of
/// scope for the Phase 1 scaffolding.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      );
      await _plugin.initialize(settings);
      _initialized = true;
    } catch (_) {
      // Platform channel unavailable (e.g. unsupported host) — stay silent.
    }
  }

  Future<void> showNow({required String title, required String body}) async {
    if (!_initialized) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'aura_general',
        'General',
        channelDescription: 'General AURA notifications',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );
    try {
      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
      );
    } catch (_) {
      // Ignore — notifications are best-effort in Phase 1.
    }
  }
}
