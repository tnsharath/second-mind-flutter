import 'goal.dart';

abstract class GoalsRepository {
  /// TODO(backend): GET /goals
  Future<List<Goal>> getTodayGoals();

  /// TODO(backend): POST /goals/{id}/toggle
  Future<Goal> toggleGoal(Goal goal);
}
