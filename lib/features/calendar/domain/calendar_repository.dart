import 'calendar_event.dart';

abstract class CalendarRepository {
  /// GET /calendar
  Future<List<CalendarEvent>> getUpcomingEvents();

  /// POST /calendar
  Future<CalendarEvent> createEvent({
    required String title,
    required DateTime start,
    DateTime? end,
    String? location,
  });

  /// PATCH /calendar/{id}
  Future<CalendarEvent> updateEvent(CalendarEvent event);

  /// DELETE /calendar/{id}
  Future<void> deleteEvent(String id);
}

