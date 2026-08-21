import 'habit.dart';

abstract class HabitsRepository {
  /// GET /habits
  Future<List<Habit>> getHabits();

  /// POST /habits
  Future<Habit> createHabit({
    required String title,
    String? description,
    HabitFrequency frequency,
    int targetCount,
    String? color,
    String? icon,
  });

  Future<Habit> updateHabit(Habit habit);

  Future<void> deleteHabit(String id);

  /// POST /habits/{id}/complete
  Future<Habit> completeHabit(Habit habit);

  /// POST /habits/{id}/uncomplete
  Future<Habit> uncompleteHabit(Habit habit);
}
