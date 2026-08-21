import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/shared/widgets/aura_card.dart';
import '../../application/habits_providers.dart';
import '../../domain/habit.dart';

class HabitListTile extends ConsumerWidget {
  const HabitListTile({super.key, required this.habit});

  final Habit habit;

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete habit?'),
        content: Text('"${habit.title}" will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = _parseColor(habit.color) ?? theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey(habit.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
        ),
        confirmDismiss: (_) => _confirmDelete(context),
        onDismissed: (_) => ref.read(habitsProvider.notifier).delete(habit),
        child: AuraCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HabitCheckButton(habit: habit, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration:
                            habit.isCompletedToday ? TextDecoration.lineThrough : null,
                        color: habit.isCompletedToday
                            ? theme.textTheme.bodySmall?.color
                            : null,
                      ),
                    ),
                    if (habit.description != null && habit.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(habit.description!, style: theme.textTheme.bodySmall),
                    ],
                    const SizedBox(height: 6),
                    _HabitProgressBar(habit: habit, color: color),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HabitCheckButton extends ConsumerWidget {
  const _HabitCheckButton({required this.habit, required this.color});

  final Habit habit;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = habit.isCompletedToday;
    return IconButton(
      constraints: const BoxConstraints(),
      padding: EdgeInsets.zero,
      iconSize: 26,
      icon: Icon(
        completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
        color: completed ? color : Theme.of(context).colorScheme.outline,
      ),
      onPressed: () {
        if (completed) {
          ref.read(habitsProvider.notifier).uncomplete(habit);
        } else {
          ref.read(habitsProvider.notifier).complete(habit);
        }
      },
    );
  }
}

class _HabitProgressBar extends StatelessWidget {
  const _HabitProgressBar({required this.habit, required this.color});

  final Habit habit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: habit.progressRatio,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${habit.completedToday}/${habit.targetCount} today',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
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
