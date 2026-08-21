import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/calendar/application/calendar_providers.dart';
import '../../features/calendar/domain/calendar_event.dart';
import '../../features/settings/application/settings_controller.dart';
import '../providers/providers.dart';

/// Best-effort local reminders: a notification 10 minutes before each
/// upcoming event, the 08:00 morning briefing, and the 21:00 evening
/// reflection.
///
/// Scheduled notification ids are persisted so stale ones can be cancelled
/// before rescheduling. Never throws — notifications are a nicety, not a
/// requirement. No-op when notifications are disabled in settings.
class ReminderScheduler {
  const ReminderScheduler._();

  static const int morningBriefingId = 9001;
  static const int eveningReflectionId = 9002;
  static const int maxScheduled = 8;

  static const String _idsKey = 'aura_scheduled_reminder_ids';

  static Future<void> rescheduleAll(WidgetRef ref) async {
    try {
      final settings = ref.read(settingsProvider);
      if (!settings.notificationsEnabled) return;

      final notifications = ref.read(notificationServiceProvider);
      await notifications.requestPermission();

      // Cancel everything scheduled previously, then reschedule fresh.
      final prefs = ref.read(sharedPreferencesProvider);
      for (final id in _readIds(prefs)) {
        await notifications.cancel(id);
      }

      final planned = <_PlannedReminder>[];
      if (settings.morningBriefingEnabled) {
        planned.add(_PlannedReminder(
          id: morningBriefingId,
          at: _nextTime(8),
          title: 'Your morning briefing is ready',
          body: 'Start the day with AURA.',
        ));
      }
      planned.add(_PlannedReminder(
        id: eveningReflectionId,
        at: _nextTime(21),
        title: 'Evening reflection',
        body: 'How did today go?',
      ));

      final events = ref.read(upcomingEventsProvider).valueOrNull ??
          const <CalendarEvent>[];
      for (final event in events) {
        if (planned.length >= maxScheduled) break;
        final at = event.start.subtract(const Duration(minutes: 10));
        if (at.isBefore(DateTime.now())) continue;
        planned.add(_PlannedReminder(
          id: event.id.hashCode,
          at: at,
          title: 'Upcoming: ${event.title}',
          body: _eventBody(event),
        ));
      }

      final scheduled = planned.take(maxScheduled).toList();
      for (final reminder in scheduled) {
        await notifications.scheduleAt(
          id: reminder.id,
          at: reminder.at,
          title: reminder.title,
          body: reminder.body,
        );
      }
      await prefs.setStringList(
        _idsKey,
        scheduled.map((reminder) => reminder.id.toString()).toList(),
      );
    } catch (_) {
      // Best-effort only — scheduling failures must never break the UI.
    }
  }

  /// Today at [hour], or tomorrow when that time has already passed.
  static DateTime _nextTime(int hour) {
    final now = DateTime.now();
    var at = DateTime(now.year, now.month, now.day, hour);
    if (!at.isAfter(now)) at = at.add(const Duration(days: 1));
    return at;
  }

  static String _eventBody(CalendarEvent event) {
    final time = DateFormat('EEE, MMM d · h:mm a').format(event.start);
    final location = event.location;
    return location == null || location.isEmpty ? time : '$time · $location';
  }

  static List<int> _readIds(SharedPreferences prefs) => [
        for (final raw in prefs.getStringList(_idsKey) ?? const <String>[])
          if (int.tryParse(raw) case final id?) id,
      ];
}

class _PlannedReminder {
  const _PlannedReminder({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
  });

  final int id;
  final DateTime at;
  final String title;
  final String body;
}
