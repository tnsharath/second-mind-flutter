import '../domain/calendar_event.dart';
import '../domain/calendar_repository.dart';

/// Serves local dummy events until the backend /calendar endpoint exists.
class MockCalendarRepository implements CalendarRepository {
  @override
  Future<List<CalendarEvent>> getUpcomingEvents() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return [
      CalendarEvent(
        id: 'e1',
        title: 'Team standup',
        start: DateTime(now.year, now.month, now.day, 10, 30),
        end: DateTime(now.year, now.month, now.day, 10, 45),
        location: 'Google Meet',
      ),
      CalendarEvent(
        id: 'e2',
        title: 'Design review — AURA mobile',
        start: DateTime(now.year, now.month, now.day, 14, 0),
        end: DateTime(now.year, now.month, now.day, 15, 0),
        location: 'Studio room 2',
      ),
      CalendarEvent(
        id: 'e3',
        title: 'Gym — strength session',
        start: DateTime(now.year, now.month, now.day, 18, 30),
      ),
    ];
  }
}
