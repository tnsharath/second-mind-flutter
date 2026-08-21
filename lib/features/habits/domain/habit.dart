import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit.freezed.dart';
part 'habit.g.dart';

enum HabitFrequency { daily, weekly }

@freezed
class Habit with _$Habit {
  const factory Habit({
    required String id,
    required String title,
    String? description,
    @Default(HabitFrequency.daily) HabitFrequency frequency,
    @Default(1) int targetCount,
    int completedToday,
    String? color,
    String? icon,
    @Default(false) bool archived,
    DateTime? createdAt,
  }) = _Habit;

  factory Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);
}

extension HabitProgress on Habit {
  bool get isCompletedToday => completedToday >= targetCount;
  double get progressRatio => targetCount == 0
      ? 0
      : (completedToday / targetCount).clamp(0, 1).toDouble();
}
