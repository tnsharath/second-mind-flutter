import '../../../core/services/api_client.dart';
import '../domain/habit.dart';
import '../domain/habits_repository.dart';

/// Real backend implementation — used when USE_MOCK_API=false.
class ApiHabitsRepository implements HabitsRepository {
  ApiHabitsRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Habit>> getHabits() async {
    final response = await _client.get<List<dynamic>>('/habits');
    final data = response.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((json) => Habit.fromJson(_normalizeId(json)))
        .toList();
  }

  @override
  Future<Habit> createHabit({
    required String title,
    String? description,
    HabitFrequency frequency = HabitFrequency.daily,
    int targetCount = 1,
    String? color,
    String? icon,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/habits',
      body: {
        'title': title,
        if (description != null) 'description': description,
        'frequency': frequency.name,
        'targetCount': targetCount,
        if (color != null) 'color': color,
        if (icon != null) 'icon': icon,
      },
    );
    return Habit.fromJson(_normalizeId(response.data ?? const {}));
  }

  @override
  Future<Habit> updateHabit(Habit habit) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/habits/${habit.id}',
      body: {
        'title': habit.title,
        if (habit.description != null) 'description': habit.description,
        'frequency': habit.frequency.name,
        'targetCount': habit.targetCount,
        if (habit.color != null) 'color': habit.color,
        if (habit.icon != null) 'icon': habit.icon,
        'archived': habit.archived,
      },
    );
    return Habit.fromJson(_normalizeId(response.data ?? const {}));
  }

  @override
  Future<void> deleteHabit(String id) async {
    await _client.delete<void>('/habits/$id');
  }

  @override
  Future<Habit> completeHabit(Habit habit) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/habits/${habit.id}/complete',
    );
    return Habit.fromJson(_normalizeId(response.data ?? const {}));
  }

  @override
  Future<Habit> uncompleteHabit(Habit habit) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/habits/${habit.id}/uncomplete',
    );
    return Habit.fromJson(_normalizeId(response.data ?? const {}));
  }
}

/// Backend ids are integers; the Dart models use String ids.
Map<String, dynamic> _normalizeId(Map<String, dynamic> json) => {
      ...json,
      'id': json['id'].toString(),
    };
