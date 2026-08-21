import 'package:uuid/uuid.dart';

import '../domain/goal.dart';
import '../domain/goals_repository.dart';

/// Serves local dummy goals for offline/demo use.
class MockGoalsRepository implements GoalsRepository {
  static final List<Goal> _goals = [
    Goal(id: 'g1', title: 'Morning walk — 20 minutes', isCompleted: true),
    Goal(id: 'g2', title: 'Finish project proposal draft'),
    Goal(id: 'g3', title: 'Read 15 pages of current book'),
    Goal(id: 'g4', title: 'Call mom this evening'),
  ];

  final Uuid _uuid = const Uuid();

  @override
  Future<List<Goal>> getTodayGoals() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return List.unmodifiable(_goals);
  }

  @override
  Future<Goal> createGoal({
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final goal = Goal(
      id: _uuid.v4(),
      title: title,
      description: description,
      dueDate: dueDate,
    );
    _goals.add(goal);
    return goal;
  }

  @override
  Future<Goal> updateGoal(Goal goal) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index >= 0) {
      _goals[index] = goal;
      return goal;
    }
    return goal;
  }

  @override
  Future<void> deleteGoal(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _goals.removeWhere((g) => g.id == id);
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
