import '../../../core/services/api_client.dart';
import '../domain/goal.dart';
import '../domain/goals_repository.dart';

/// Real backend implementation — used when USE_MOCK_API=false.
class ApiGoalsRepository implements GoalsRepository {
  ApiGoalsRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Goal>> getTodayGoals() async {
    final response = await _client.get<List<dynamic>>('/goals');
    final data = response.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((json) => Goal.fromJson(_normalizeId(json)))
        .toList();
  }

  @override
  Future<Goal> toggleGoal(Goal goal) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/goals/${goal.id}/toggle',
    );
    return Goal.fromJson(_normalizeId(response.data ?? const {}));
  }
}

/// Backend ids are integers; the Dart models use String ids.
Map<String, dynamic> _normalizeId(Map<String, dynamic> json) => {
      ...json,
      'id': json['id'].toString(),
    };
