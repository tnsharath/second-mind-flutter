import '../domain/calendar_event.dart';
import '../domain/calendar_repository.dart';

/// Serves local dummy events until the backend /calendar endpoint exists.
class MockCalendarRepository implements CalendarRepository {
  final List<CalendarEvent> _items = [];

  MockCalendarRepository() {
    final now = DateTime.now();
    _items.addAll([
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
    ]);
  }

  @override
  Future<List<CalendarEvent>> getUpcomingEvents() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_items);
  }

  @override
  Future<CalendarEvent> createEvent({
    required String title,
    required DateTime start,
    DateTime? end,
    String? location,
  }) async {
    final event = CalendarEvent(
      id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      start: start,
      end: end,
      location: location,
    );
    _items.add(event);
    return event;
  }

  @override
  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    final idx = _items.indexWhere((e) => e.id == event.id);
    if (idx != -1) {
      _items[idx] = event;
    }
    return event;
  }

  @override
  Future<void> deleteEvent(String id) async {
    _items.removeWhere((e) => e.id == id);
  }
}

