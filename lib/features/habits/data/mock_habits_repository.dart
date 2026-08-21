import 'package:uuid/uuid.dart';

import '../domain/habit.dart';
import '../domain/habits_repository.dart';

/// Local dummy habits for offline/demo use.
class MockHabitsRepository implements HabitsRepository {
  static List<Habit>? _habits;
  static final Map<String, int> _completionsToday = {};

  final Uuid _uuid = const Uuid();

  static List<Habit> _seed() {
    return [
      Habit(
        id: 'h1',
        title: 'Morning walk',
        description: '20 minutes before breakfast',
        frequency: HabitFrequency.daily,
        targetCount: 1,
        completedToday: 0,
        color: '#4CAF50',
        icon: 'directions_walk',
      ),
      Habit(
        id: 'h2',
        title: 'Read',
        description: 'At least 15 pages',
        frequency: HabitFrequency.daily,
        targetCount: 1,
        completedToday: 0,
        color: '#2196F3',
        icon: 'menu_book',
      ),
      Habit(
        id: 'h3',
        title: 'Deep work block',
        description: 'One uninterrupted 45+ min session',
        frequency: HabitFrequency.daily,
        targetCount: 1,
        completedToday: 0,
        color: '#9C27B0',
        icon: 'center_focus_strong',
      ),
      Habit(
        id: 'h4',
        title: 'Weekly review',
        description: 'Plan the week and clear inboxes',
        frequency: HabitFrequency.weekly,
        targetCount: 1,
        completedToday: 0,
        color: '#FF9800',
        icon: 'event_note',
      ),
    ];
  }

  @override
  Future<List<Habit>> getHabits() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    _habits ??= _seed();
    return List.unmodifiable(
      _habits!.map((h) => h.copyWith(completedToday: _completionsToday[h.id] ?? 0)),
    );
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
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final habits = _habits ??= _seed();
    final habit = Habit(
      id: _uuid.v4(),
      title: title,
      description: description,
      frequency: frequency,
      targetCount: targetCount,
      completedToday: 0,
      color: color,
      icon: icon,
    );
    habits.add(habit);
    return habit;
  }

  @override
  Future<Habit> updateHabit(Habit habit) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final habits = _habits ??= _seed();
    final index = habits.indexWhere((h) => h.id == habit.id);
    if (index >= 0) {
      habits[index] = habit.copyWith(
        completedToday: _completionsToday[habit.id] ?? habit.completedToday,
      );
      return habits[index];
    }
    return habit;
  }

  @override
  Future<void> deleteHabit(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final habits = _habits ??= _seed();
    habits.removeWhere((h) => h.id == id);
    _completionsToday.remove(id);
  }

  @override
  Future<Habit> completeHabit(Habit habit) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final current = (_completionsToday[habit.id] ?? 0) + 1;
    _completionsToday[habit.id] = current;
    return habit.copyWith(completedToday: current);
  }

  @override
  Future<Habit> uncompleteHabit(Habit habit) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final current = (_completionsToday[habit.id] ?? 0);
    final next = current > 0 ? current - 1 : 0;
    _completionsToday[habit.id] = next;
    return habit.copyWith(completedToday: next);
  }
}
