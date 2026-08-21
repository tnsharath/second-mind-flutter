import 'goal.dart';

abstract class GoalsRepository {
  /// GET /goals
  Future<List<Goal>> getTodayGoals();

  /// POST /goals
  Future<Goal> createGoal({
    required String title,
    String? description,
    DateTime? dueDate,
  });

  Future<Goal> updateGoal(Goal goal);

  Future<void> deleteGoal(String id);

  Future<Goal> toggleGoal(Goal goal);
}
