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
  Future<Goal> createGoal({
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/goals',
      body: {
        'title': title,
        if (description != null) 'description': description,
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
      },
    );
    return Goal.fromJson(_normalizeId(response.data ?? const {}));
  }

  @override
  Future<Goal> updateGoal(Goal goal) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/goals/${goal.id}',
      body: {
        'title': goal.title,
        if (goal.description != null) 'description': goal.description,
        'isCompleted': goal.isCompleted,
        if (goal.dueDate != null) 'dueDate': goal.dueDate!.toIso8601String(),
      },
    );
    return Goal.fromJson(_normalizeId(response.data ?? const {}));
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _client.delete<void>('/goals/$id');
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
      'isCompleted': false,
      'progress': 0,
      ...json,
      'id': (json['id'] ?? json['_id'] ?? DateTime.now().millisecondsSinceEpoch).toString(),
      'title': json['title']?.toString() ?? 'Goal',
    };
