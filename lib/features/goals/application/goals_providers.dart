import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/providers/providers.dart';
import '../data/api_goals_repository.dart';
import '../data/mock_goals_repository.dart';
import '../domain/goal.dart';
import '../domain/goals_repository.dart';

final goalsRepositoryProvider = Provider<GoalsRepository>(
  (ref) => Env.useMockApi
      ? MockGoalsRepository()
      : ApiGoalsRepository(ref.watch(apiClientProvider)),
);

final todayGoalsProvider = AsyncNotifierProvider<GoalsController, List<Goal>>(
  GoalsController.new,
);

class GoalsController extends AsyncNotifier<List<Goal>> {
  GoalsRepository get _repository => ref.read(goalsRepositoryProvider);

  @override
  Future<List<Goal>> build() => _repository.getTodayGoals();

  Future<void> create({
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    final current = state.valueOrNull ?? const <Goal>[];
    try {
      final created = await _repository.createGoal(
        title: title,
        description: description,
        dueDate: dueDate,
      );
      state = AsyncData([...current, created]);
    } catch (_) {
      state = AsyncData(current);
    }
  }

  Future<void> updateGoal(Goal goal) async {
    final current = state.valueOrNull ?? const <Goal>[];
    state = AsyncData([
      for (final g in current) if (g.id == goal.id) goal else g,
    ]);
    try {
      final updated = await _repository.updateGoal(goal);
      state = AsyncData([
        for (final g in state.valueOrNull ?? current)
          if (g.id == updated.id) updated else g,
      ]);
    } catch (_) {
      state = AsyncData(current);
    }
  }

  /// Optimistic delete with rollback on failure.
  Future<void> delete(Goal goal) async {
    final current = state.valueOrNull ?? const <Goal>[];
    state = AsyncData(current.where((g) => g.id != goal.id).toList());
    try {
      await _repository.deleteGoal(goal.id);
    } catch (_) {
      state = AsyncData(current);
    }
  }

  /// Optimistic toggle with rollback on failure.
  Future<void> toggle(Goal goal) async {
    final current = state.valueOrNull ?? const <Goal>[];
    state = AsyncData([
      for (final g in current)
        if (g.id == goal.id) g.copyWith(isCompleted: !g.isCompleted) else g,
    ]);
    try {
      await _repository.toggleGoal(goal);
    } catch (_) {
      state = AsyncData(current);
    }
  }
}
