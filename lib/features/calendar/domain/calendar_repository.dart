import 'calendar_event.dart';

abstract class CalendarRepository {
  /// GET /calendar
  Future<List<CalendarEvent>> getUpcomingEvents();
}
