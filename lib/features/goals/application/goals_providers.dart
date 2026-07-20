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
