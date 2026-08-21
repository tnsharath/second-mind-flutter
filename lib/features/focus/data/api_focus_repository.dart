import 'package:intl/intl.dart';

import '../../../core/services/api_client.dart';
import '../domain/focus_repository.dart';
import '../domain/focus_session.dart';

/// Real backend implementation — used when USE_MOCK_API=false.
class ApiFocusRepository implements FocusRepository {
  ApiFocusRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<FocusSession>> getSessions({DateTime? date}) async {
    final response = await _client.get<List<dynamic>>(
      '/focus/sessions',
      query:
          date == null ? null : {'date': DateFormat('yyyy-MM-dd').format(date)},
    );
    final data = response.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((json) => FocusSession.fromJson(_normalizeId(json)))
        .toList();
  }

  @override
  Future<FocusSession> logSession({
    required int minutes,
    required DateTime startedAt,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/focus/sessions',
      body: {'minutes': minutes, 'startedAt': startedAt.toIso8601String()},
    );
    return FocusSession.fromJson(_normalizeId(response.data ?? const {}));
  }
}

/// Backend ids are integers; the Dart models use String ids.
Map<String, dynamic> _normalizeId(Map<String, dynamic> json) => {
      ...json,
      'id': json['id'].toString(),
    };
