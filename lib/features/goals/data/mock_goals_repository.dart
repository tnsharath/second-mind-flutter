import '../domain/goal.dart';
import '../domain/goals_repository.dart';

/// Serves local dummy goals until the backend /goals endpoint exists.
class MockGoalsRepository implements GoalsRepository {
  static final List<Goal> _goals = [
    Goal(id: 'g1', title: 'Morning walk — 20 minutes', isCompleted: true),
    Goal(id: 'g2', title: 'Finish project proposal draft'),
    Goal(id: 'g3', title: 'Read 15 pages of current book'),
    Goal(id: 'g4', title: 'Call mom this evening'),
  ];

  @override
  Future<List<Goal>> getTodayGoals() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return List.unmodifiable(_goals);
  }

  @override
  Future<Goal> toggleGoal(Goal goal) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index >= 0) {
      _goals[index] = _goals[index].copyWith(isCompleted: !goal.isCompleted);
      return _goals[index];
    }
    return goal.copyWith(isCompleted: !goal.isCompleted);
  }
}
