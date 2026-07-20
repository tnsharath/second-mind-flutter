import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/providers/providers.dart';
import '../data/api_calendar_repository.dart';
import '../data/mock_calendar_repository.dart';
import '../domain/calendar_event.dart';
import '../domain/calendar_repository.dart';

final calendarRepositoryProvider = Provider<CalendarRepository>(
  (ref) => Env.useMockApi
      ? MockCalendarRepository()
      : ApiCalendarRepository(ref.watch(apiClientProvider)),
);

final upcomingEventsProvider = FutureProvider<List<CalendarEvent>>(
  (ref) => ref.watch(calendarRepositoryProvider).getUpcomingEvents(),
);
