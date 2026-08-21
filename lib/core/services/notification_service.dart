import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Local notifications (reminders, morning briefing nudges).
///
/// Scheduled notifications use the `timezone` package; [initialize] loads
/// the tz database once so [scheduleAt] can convert wall-clock times into
/// [tz.TZDateTime]s. Everything here is best-effort: any platform failure
/// is swallowed so a missing channel never breaks a user flow.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      // No device-timezone lookup package is available yet, so scheduled
      // times resolve in tz.local as configured by initializeTimeZones().
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
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
      // Ignore — notifications are best-effort.
    }
  }

  /// Schedules a one-shot local notification at [at]. Past times are
  /// ignored. When [alarm] is true the high-importance 'aura_reminders'
  /// channel (with sound) is used; otherwise the quiet 'aura_general' one.
  Future<void> scheduleAt({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    bool alarm = false,
  }) async {
    if (!_initialized) return;
    if (!at.isAfter(DateTime.now())) return;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        alarm ? 'aura_reminders' : 'aura_general',
        alarm ? 'Reminders' : 'General',
        channelDescription: alarm
            ? 'Note and reminder alarms'
            : 'General AURA notifications',
        importance: alarm ? Importance.max : Importance.defaultImportance,
        priority: alarm ? Priority.high : Priority.defaultPriority,
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(presentSound: true),
    );
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(at, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      // Ignore — scheduling is best-effort (e.g. exact alarms not allowed).
    }
  }

  Future<void> cancel(int id) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(id);
    } catch (_) {
      // Ignore — cancellation is best-effort.
    }
  }

  /// Asks the OS for notification permission (Android 13+ / iOS).
  /// Returns false when the platform is unsupported or the user declines.
  Future<bool> requestPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        if (granted != null) return granted;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final granted = await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (_) {
      // Platform channel unavailable — report as not granted.
    }
    return false;
  }
}
