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
}

/// Backend ids are integers; the Dart models use String ids.
Map<String, dynamic> _normalizeId(Map<String, dynamic> json) => {
      ...json,
      'id': json['id'].toString(),
    };
