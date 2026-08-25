import 'package:device_calendar/device_calendar.dart';

import '../domain/calendar_event.dart';
import '../domain/calendar_repository.dart';

/// Merges on-device calendar events (now → +3 days) with backend events.
///
/// Device access is best-effort: any plugin error (denied permission,
/// unsupported host) yields backend events only.
class DeviceCalendarRepository implements CalendarRepository {
  DeviceCalendarRepository(this._backend, {DeviceCalendarPlugin? plugin})
      : _plugin = plugin ?? DeviceCalendarPlugin();

  final CalendarRepository _backend;
  final DeviceCalendarPlugin _plugin;

  static const Duration _window = Duration(days: 3);

  @override
  Future<List<CalendarEvent>> getUpcomingEvents() async {
    final results = await Future.wait([
      _loadDeviceEvents(),
      _loadBackendEvents(),
    ]);
    return _merge(results[0], results[1]);
  }

  @override
  Future<CalendarEvent> createEvent({
    required String title,
    required DateTime start,
    DateTime? end,
    String? location,
  }) async {
    return _backend.createEvent(
      title: title,
      start: start,
      end: end,
      location: location,
    );
  }

  @override
  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    return _backend.updateEvent(event);
  }

  @override
  Future<void> deleteEvent(String id) async {
    await _backend.deleteEvent(id);
  }


  Future<List<CalendarEvent>> _loadBackendEvents() async {
    try {
      return await _backend.getUpcomingEvents();
    } catch (_) {
      return const [];
    }
  }

  Future<List<CalendarEvent>> _loadDeviceEvents() async {
    try {
      final permissions = await _plugin.requestPermissions();
      if (!permissions.isSuccess || permissions.data != true) {
        return const [];
      }
      final calendars = await _plugin.retrieveCalendars();
      if (!calendars.isSuccess) return const [];

      final now = DateTime.now();
      final params = RetrieveEventsParams(
        startDate: now,
        endDate: now.add(_window),
      );
      final events = <CalendarEvent>[];
      for (final calendar in calendars.data ?? const <Calendar>[]) {
        final calendarId = calendar.id;
        if (calendarId == null) continue;
        final result = await _plugin.retrieveEvents(calendarId, params);
        if (!result.isSuccess) continue;
        for (final event in result.data ?? const <Event>[]) {
          events.add(_mapEvent(event));
        }
      }
      return events;
    } catch (_) {
      return const [];
    }
  }

  CalendarEvent _mapEvent(Event event) {
    final title = event.title;
    return CalendarEvent(
      id: event.eventId ??
          'device-${title ?? 'event'}-${event.start?.millisecondsSinceEpoch ?? 0}',
      title: title != null && title.isNotEmpty ? title : 'Untitled event',
      start: _toLocal(event.start),
      end: event.end == null ? null : _toLocal(event.end),
      location: event.location,
    );
  }

  /// device_calendar 4.x returns TZDateTimes; rebuild plain local DateTimes.
  static DateTime _toLocal(DateTime? value) {
    if (value == null) return DateTime.now();
    return DateTime.fromMillisecondsSinceEpoch(value.millisecondsSinceEpoch);
  }

  /// Device + backend events, deduped by title+start, sorted by start.
  static List<CalendarEvent> _merge(
    List<CalendarEvent> device,
    List<CalendarEvent> backend,
  ) {
    final seen = <String>{};
    final merged = <CalendarEvent>[];
    for (final event in [...device, ...backend]) {
      final key = '${event.title}|${event.start.millisecondsSinceEpoch}';
      if (seen.add(key)) merged.add(event);
    }
    merged.sort((a, b) => a.start.compareTo(b.start));
    return merged;
  }
}
