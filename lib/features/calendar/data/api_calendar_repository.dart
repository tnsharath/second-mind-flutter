import '../../../core/services/api_client.dart';
import '../domain/calendar_event.dart';
import '../domain/calendar_repository.dart';

/// Real backend implementation — used when USE_MOCK_API=false.
class ApiCalendarRepository implements CalendarRepository {
  ApiCalendarRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<CalendarEvent>> getUpcomingEvents() async {
    final response = await _client.get<List<dynamic>>('/calendar');
    final data = response.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((json) => CalendarEvent.fromJson(_normalizeId(json)))
        .toList();
  }

  @override
  Future<CalendarEvent> createEvent({
    required String title,
    required DateTime start,
    DateTime? end,
    String? location,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/calendar',
      body: {
        'title': title,
        'start': start.toIso8601String(),
        if (end != null) 'end': end.toIso8601String(),
        if (location != null) 'location': location,
      },
    );
    return CalendarEvent.fromJson(_normalizeId(response.data!));
  }

  @override
  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/calendar/${event.id}',
      body: {
        'title': event.title,
        'start': event.start.toIso8601String(),
        if (event.end != null) 'end': event.end!.toIso8601String(),
        'location': event.location,
      },
    );
    return CalendarEvent.fromJson(_normalizeId(response.data!));
  }

  @override
  Future<void> deleteEvent(String id) async {
    await _client.delete<void>('/calendar/$id');
  }
}

/// Backend ids are integers; the Dart models use String ids.
Map<String, dynamic> _normalizeId(Map<String, dynamic> json) => {
      ...json,
      'id': json['id'].toString(),
    };

