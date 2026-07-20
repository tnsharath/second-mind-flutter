import '../../../core/services/api_client.dart';
import '../domain/briefing_repository.dart';
import '../domain/daily_briefing.dart';

/// Real backend implementation — used when USE_MOCK_API=false.
class ApiBriefingRepository implements BriefingRepository {
  ApiBriefingRepository(this._client);

  final ApiClient _client;

  @override
  Future<DailyBriefing> getTodayBriefing() async {
    final response = await _client.get<Map<String, dynamic>>('/briefing');
    final json = Map<String, dynamic>.from(response.data ?? const {});
    // Nested meetings/goals carry integer backend ids; the Dart models
    // use String ids.
    for (final key in const ['meetings', 'goals']) {
      final items = json[key];
      if (items is List) {
        json[key] = [
          for (final item in items)
            if (item is Map<String, dynamic>) _normalizeId(item) else item,
        ];
      }
    }
    return DailyBriefing.fromJson(json);
  }
}

Map<String, dynamic> _normalizeId(Map<String, dynamic> json) => {
      ...json,
      'id': json['id'].toString(),
    };
