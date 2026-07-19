import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_calendar_repository.dart';
import '../domain/calendar_event.dart';
import '../domain/calendar_repository.dart';

final calendarRepositoryProvider = Provider<CalendarRepository>(
  (ref) => MockCalendarRepository(),
);

final upcomingEventsProvider = FutureProvider<List<CalendarEvent>>(
  (ref) => ref.watch(calendarRepositoryProvider).getUpcomingEvents(),
);
