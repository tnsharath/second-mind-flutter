import 'package:aura/features/goals/data/mock_goals_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Note: MockGoalsRepository uses a static list, so order of tests matters.
  // Each test starts from the seeded state and mutates it.
  group('MockGoalsRepository', () {
    late MockGoalsRepository repository;

    setUp(() {
      repository = MockGoalsRepository();
    });

    test('seeds four goals', () async {
      final goals = await repository.getTodayGoals();
      expect(goals, hasLength(4));
    });

    test('createGoal appends a new goal', () async {
      final before = await repository.getTodayGoals();
      final created = await repository.createGoal(title: 'New test goal');

      expect(created.title, 'New test goal');
      expect(created.isCompleted, isFalse);

      final after = await repository.getTodayGoals();
      expect(after, hasLength(before.length + 1));
      expect(after.last.id, created.id);
    });

    test('updateGoal modifies title and description', () async {
      final goals = await repository.getTodayGoals();
      final original = goals.first;
      final updated = await repository.updateGoal(
        original.copyWith(
          title: 'Updated title',
          description: 'Updated description',
        ),
      );

      expect(updated.title, 'Updated title');
      expect(updated.description, 'Updated description');

      final fetched = await repository.getTodayGoals();
      final match = fetched.firstWhere((g) => g.id == original.id);
      expect(match.title, 'Updated title');
    });

    test('deleteGoal removes the goal', () async {
      final before = await repository.getTodayGoals();
      final target = before.first;
      await repository.deleteGoal(target.id);

      final after = await repository.getTodayGoals();
      expect(after, hasLength(before.length - 1));
      expect(after.any((g) => g.id == target.id), isFalse);
    });

    test('toggleGoal flips completion', () async {
      final goals = await repository.getTodayGoals();
      final target = goals.firstWhere((g) => !g.isCompleted);
      final toggled = await repository.toggleGoal(target);

      expect(toggled.isCompleted, !target.isCompleted);
    });
  });
}
