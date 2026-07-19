import 'calendar_event.dart';

abstract class CalendarRepository {
  /// TODO(backend): GET /calendar
  Future<List<CalendarEvent>> getUpcomingEvents();
}
