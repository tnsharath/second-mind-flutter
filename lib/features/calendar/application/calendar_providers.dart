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

final upcomingEventsProvider = FutureProvider<List<CalendarEvent>>(
  (ref) => ref.watch(calendarRepositoryProvider).getUpcomingEvents(),
);
