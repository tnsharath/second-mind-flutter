import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/shared/widgets/aura_card.dart';
import '../../../../core/shared/widgets/section_header.dart';
import '../../../goals/application/goals_providers.dart';
import '../../../habits/application/habits_providers.dart';
import '../../../memory/application/memory_providers.dart';

class WeeklyReviewCard extends HookConsumerWidget {
  const WeeklyReviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final goals = ref.watch(todayGoalsProvider);
    final habits = ref.watch(todayHabitsProvider);
    final memories = ref.watch(memoriesProvider);

    final completedGoals = goals.valueOrNull?.where((g) => g.isCompleted).length ?? 0;
    final totalGoals = goals.valueOrNull?.length ?? 0;
    final totalHabits = habits.valueOrNull?.length ?? 0;
    final completedHabitInstances = habits.valueOrNull
            ?.fold<int>(0, (sum, h) => sum + h.completedToday) ??
        0;
    final memoryCount = memories.valueOrNull?.length ?? 0;

    return AuraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'This week at a glance'),
          const SizedBox(height: 10),
          Row(
            children: [
              _StatItem(
                value: '$completedGoals/$totalGoals',
                label: 'goals done',
                icon: Icons.flag_outlined,
              ),
              _StatItem(
                value: completedHabitInstances.toString(),
                label: 'habit checks',
                icon: Icons.repeat_rounded,
              ),
              _StatItem(
                value: memoryCount.toString(),
                label: 'memories',
                icon: Icons.psychology_outlined,
              ),
            ],
          ),
          if (completedGoals == 0 && completedHabitInstances == 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Small steps add up — capture one thing or check off a habit.',
                style: theme.textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 22, color: theme.colorScheme.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
