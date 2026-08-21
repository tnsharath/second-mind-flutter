import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/providers/providers.dart';
import '../data/api_habits_repository.dart';
import '../data/mock_habits_repository.dart';
import '../domain/habit.dart';
import '../domain/habits_repository.dart';

final habitsRepositoryProvider = Provider<HabitsRepository>(
  (ref) => Env.useMockApi
      ? MockHabitsRepository()
      : ApiHabitsRepository(ref.watch(apiClientProvider)),
);

final habitsProvider = AsyncNotifierProvider<HabitsController, List<Habit>>(
  HabitsController.new,
);

class HabitsController extends AsyncNotifier<List<Habit>> {
  HabitsRepository get _repository => ref.read(habitsRepositoryProvider);

  @override
  Future<List<Habit>> build() => _repository.getHabits();

  Future<Habit> create({
    required String title,
    String? description,
    HabitFrequency frequency = HabitFrequency.daily,
    int targetCount = 1,
    String? color,
    String? icon,
  }) async {
    final current = state.valueOrNull ?? const <Habit>[];
    try {
      final created = await _repository.createHabit(
        title: title,
        description: description,
        frequency: frequency,
        targetCount: targetCount,
        color: color,
        icon: icon,
      );
      state = AsyncData([...current, created]);
      return created;
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }

  /// Optimistic update with rollback on failure.
  Future<void> updateHabit(Habit habit) async {
    final current = state.valueOrNull ?? const <Habit>[];
    state = AsyncData([
      for (final h in current) if (h.id == habit.id) habit else h,
    ]);
    try {
      final updated = await _repository.updateHabit(habit);
      state = AsyncData([
        for (final h in state.valueOrNull ?? current)
          if (h.id == updated.id) updated else h,
      ]);
    } catch (_) {
      state = AsyncData(current);
    }
  }

  /// Optimistic delete with rollback on failure.
  Future<void> delete(Habit habit) async {
    final current = state.valueOrNull ?? const <Habit>[];
    state = AsyncData(current.where((h) => h.id != habit.id).toList());
    try {
      await _repository.deleteHabit(habit.id);
    } catch (_) {
      state = AsyncData(current);
    }
  }

  /// Optimistic completion with rollback on failure.
  Future<void> complete(Habit habit) async {
    final current = state.valueOrNull ?? const <Habit>[];
    state = AsyncData([
      for (final h in current)
        if (h.id == habit.id)
          h.copyWith(completedToday: h.completedToday + 1)
        else
          h,
    ]);
    try {
      await _repository.completeHabit(habit);
    } catch (_) {
      state = AsyncData(current);
    }
  }

  /// Optimistic uncompletion with rollback on failure.
  Future<void> uncomplete(Habit habit) async {
    final current = state.valueOrNull ?? const <Habit>[];
    state = AsyncData([
      for (final h in current)
        if (h.id == habit.id)
          h.copyWith(completedToday: h.completedToday > 0 ? h.completedToday - 1 : 0)
        else
          h,
    ]);
    try {
      await _repository.uncompleteHabit(habit);
    } catch (_) {
      state = AsyncData(current);
    }
  }
}

/// Today's active habits surfaced on the home dashboard.
final todayHabitsProvider = Provider<AsyncValue<List<Habit>>>((ref) {
  return ref.watch(habitsProvider).whenData(
        (habits) => habits.where((h) => !h.archived).toList(),
      );
});
