import 'package:aura/features/calendar/data/mock_calendar_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockCalendarRepository repository;

  setUp(() {
    repository = MockCalendarRepository();
  });

  test('MockCalendarRepository seeds initial upcoming events', () async {
    final events = await repository.getUpcomingEvents();
    expect(events.length, 3);
    expect(events.first.title, 'Team standup');
  });

  test('MockCalendarRepository createEvent appends new event', () async {
    final now = DateTime.now();
    final created = await repository.createEvent(
      title: 'New Test Event',
      start: now,
      location: 'Room B',
    );

    expect(created.title, 'New Test Event');
    expect(created.location, 'Room B');

    final list = await repository.getUpcomingEvents();
    expect(list.length, 4);
    expect(list.any((e) => e.id == created.id), true);
  });

  test('MockCalendarRepository updateEvent modifies event details', () async {
    final list = await repository.getUpcomingEvents();
    final first = list.first;
    final updated = await repository.updateEvent(
      first.copyWith(title: 'Updated Standup Title', location: 'Zoom'),
    );

    expect(updated.title, 'Updated Standup Title');
    expect(updated.location, 'Zoom');

    final newList = await repository.getUpcomingEvents();
    final found = newList.firstWhere((e) => e.id == first.id);
    expect(found.title, 'Updated Standup Title');
  });

  test('MockCalendarRepository deleteEvent removes event', () async {
    final list = await repository.getUpcomingEvents();
    final idToRemove = list.first.id;

    await repository.deleteEvent(idToRemove);

    final newList = await repository.getUpcomingEvents();
    expect(newList.any((e) => e.id == idToRemove), false);
    expect(newList.length, 2);
  });
}
