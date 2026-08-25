import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/providers/providers.dart';
import '../data/api_calendar_repository.dart';
import '../data/device_calendar_repository.dart';
import '../data/mock_calendar_repository.dart';
import '../domain/calendar_event.dart';
import '../domain/calendar_repository.dart';

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  if (Env.useMockApi) return MockCalendarRepository();
  final api = ApiCalendarRepository(ref.watch(apiClientProvider));
  try {
    return DeviceCalendarRepository(api);
  } catch (_) {
    // device_calendar plugin unavailable on this host — backend events only.
    return api;
  }
});

final upcomingEventsProvider =
    AsyncNotifierProvider<CalendarEventsController, List<CalendarEvent>>(
  CalendarEventsController.new,
);

class CalendarEventsController extends AsyncNotifier<List<CalendarEvent>> {
  CalendarRepository get _repository => ref.read(calendarRepositoryProvider);

  @override
  Future<List<CalendarEvent>> build() => _repository.getUpcomingEvents();

  Future<CalendarEvent> create({
    required String title,
    required DateTime start,
    DateTime? end,
    String? location,
  }) async {
    final current = state.valueOrNull ?? const [];
    try {
      final created = await _repository.createEvent(
        title: title,
        start: start,
        end: end,
        location: location,
      );
      state = AsyncData([...current, created]);
      return created;
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }

  Future<void> updateEvent(CalendarEvent event) async {
    final current = state.valueOrNull ?? const [];
    try {
      final updated = await _repository.updateEvent(event);
      state = AsyncData([
        for (final e in current) if (e.id == updated.id) updated else e,
      ]);
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    final current = state.valueOrNull ?? const [];
    try {
      await _repository.deleteEvent(id);
      state = AsyncData([for (final e in current) if (e.id != id) e]);
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }
}

