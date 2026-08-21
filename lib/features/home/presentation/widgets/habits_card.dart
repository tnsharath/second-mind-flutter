import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/shared/widgets/aura_card.dart';
import '../../../../core/shared/widgets/aura_loading.dart';
import '../../../../core/shared/widgets/section_header.dart';
import '../../../../routes/app_router.dart';
import '../../../habits/application/habits_providers.dart';
import '../../../habits/domain/habit.dart';

class HabitsCard extends HookConsumerWidget {
  const HabitsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(todayHabitsProvider);
    final theme = Theme.of(context);

    return AuraCard(
      onTap: () => context.push(AppRoutes.habits),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Habits',
            actionLabel: 'See all',
          ),
          const SizedBox(height: 10),
          habits.when(
            data: (list) {
              if (list.isEmpty) {
                return Text(
                  'No habits tracked yet.',
                  style: theme.textTheme.bodySmall,
                );
              }
              final daily = list.where((h) => h.frequency == HabitFrequency.daily).toList();
              final shown = daily.take(3).toList();
              return Column(
                children: [
                  for (final habit in shown) _HabitRow(habit: habit),
                  if (daily.length > shown.length)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '+${daily.length - shown.length} more',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
              );
            },
            loading: () => const Column(
              children: [
                AuraShimmerBox(),
                SizedBox(height: 8),
                AuraShimmerBox(width: 180),
              ],
            ),
            error: (_, __) => Text(
              'Habits unavailable right now.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitRow extends ConsumerWidget {
  const _HabitRow({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = _parseColor(habit.color) ?? theme.colorScheme.primary;
    final completed = habit.isCompletedToday;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if (completed) {
            ref.read(habitsProvider.notifier).uncomplete(habit);
          } else {
            ref.read(habitsProvider.notifier).complete(habit);
          }
        },
        child: Row(
          children: [
            Icon(
              completed ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 18,
              color: completed ? color : theme.colorScheme.outline,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                habit.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  decoration: completed ? TextDecoration.lineThrough : null,
                  color: completed ? theme.textTheme.bodySmall?.color : null,
                ),
              ),
            ),
            Text(
              '${habit.completedToday}/${habit.targetCount}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

Color? _parseColor(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  try {
    var value = hex.replaceFirst('#', '');
    if (value.length == 6) value = 'FF$value';
    return Color(int.parse(value, radix: 16));
  } catch (_) {
    return null;
  }
}
