import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/shared/widgets/aura_bottom_sheet.dart';
import '../../../core/shared/widgets/aura_button.dart';
import '../../../core/shared/widgets/aura_card.dart';
import '../../../core/shared/widgets/aura_empty_view.dart';
import '../../../core/shared/widgets/aura_error_view.dart';
import '../../../core/shared/widgets/aura_loading.dart';
import '../../../core/shared/widgets/aura_text_field.dart';
import '../../../core/utils/time_format.dart';
import '../application/goals_providers.dart';
import '../domain/goal.dart';

class GoalsScreen extends HookConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(todayGoalsProvider);
    final filter = useState<_GoalFilter>(_GoalFilter.active);

    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGoalFormSheet(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: SegmentedButton<_GoalFilter>(
              segments: const [
                ButtonSegment(value: _GoalFilter.active, label: Text('Active')),
                ButtonSegment(value: _GoalFilter.completed, label: Text('Done')),
                ButtonSegment(value: _GoalFilter.all, label: Text('All')),
              ],
              selected: {filter.value},
              onSelectionChanged: (selected) => filter.value = selected.first,
            ),
          ),
          Expanded(
            child: goals.when(
              loading: () => const AuraLoading(),
              error: (_, __) => AuraErrorView(
                message: 'Goals could not be loaded.',
                onRetry: () => ref.invalidate(todayGoalsProvider),
              ),
              data: (list) {
                final filtered = list.where((g) {
                  return switch (filter.value) {
                    _GoalFilter.active => !g.isCompleted,
                    _GoalFilter.completed => g.isCompleted,
                    _GoalFilter.all => true,
                  };
                }).toList();

                if (filtered.isEmpty) {
                  return const AuraEmptyView(
                    title: 'No goals found',
                    message: 'Tap + to add something AURA can help you finish.',
                    icon: Icons.flag_outlined,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(todayGoalsProvider),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
                    children: [
                      for (final goal in filtered) _GoalTile(goal: goal),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum _GoalFilter { active, completed, all }


Future<void> _showGoalFormSheet(
  BuildContext context,
  WidgetRef ref, {
  Goal? goal,
}) async {
  final result = await AuraBottomSheet.show<GoalFormResult>(
    context,
    title: goal == null ? 'New goal' : 'Edit goal',
    child: _GoalForm(
      initialTitle: goal?.title ?? '',
      initialDescription: goal?.description ?? '',
      initialDueDate: goal?.dueDate,
    ),
  );
  if (result == null) return;

  if (goal == null) {
    await ref.read(todayGoalsProvider.notifier).create(
          title: result.title,
          description: result.description,
          dueDate: result.dueDate,
        );
  } else {
    await ref.read(todayGoalsProvider.notifier).updateGoal(
          goal.copyWith(
            title: result.title,
            description: result.description,
            dueDate: result.dueDate,
          ),
        );
  }
}

typedef GoalFormResult = ({String title, String? description, DateTime? dueDate});

class _GoalForm extends HookConsumerWidget {
  const _GoalForm({
    required this.initialTitle,
    required this.initialDescription,
    this.initialDueDate,
  });

  final String initialTitle;
  final String initialDescription;
  final DateTime? initialDueDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = useTextEditingController(text: initialTitle);
    final description = useTextEditingController(text: initialDescription);
    final dueDate = useState<DateTime?>(initialDueDate);

    void submit() {
      final trimmed = title.text.trim();
      if (trimmed.isEmpty) return;
      final desc = description.text.trim();
      Navigator.of(context).pop((
        title: trimmed,
        description: desc.isEmpty ? null : desc,
        dueDate: dueDate.value,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuraTextField(
          controller: title,
          hint: 'What do you want to achieve?',
          autofocus: true,
          onSubmitted: (_) => submit(),
        ),
        const SizedBox(height: 12),
        AuraTextField(
          controller: description,
          hint: 'Description (optional)',
          minLines: 3,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
        const SizedBox(height: 12),
        _DueDatePicker(
          dueDate: dueDate.value,
          onChanged: (value) => dueDate.value = value,
        ),
        const SizedBox(height: 16),
        AuraButton(label: 'Save goal', onPressed: submit),
      ],
    );
  }
}

class _DueDatePicker extends StatelessWidget {
  const _DueDatePicker({required this.dueDate, required this.onChanged});

  final DateTime? dueDate;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = dueDate == null
        ? 'Add due date'
        : 'Due ${DateFormat('EEE, MMM d').format(dueDate!)}';

    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: dueDate ?? now,
          firstDate: now,
          lastDate: now.add(const Duration(days: 365 * 2)),
        );
        onChanged(picked);
      },
      borderRadius: BorderRadius.circular(14),
      child: AuraCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              Icons.event_outlined,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            if (dueDate != null)
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () => onChanged(null),
              ),
          ],
        ),
      ),
    );
  }
}

class _GoalTile extends ConsumerWidget {
  const _GoalTile({required this.goal});

  final Goal goal;

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete goal?'),
        content: Text('"${goal.title}" will be removed.'),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey(goal.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.delete_outline_rounded,
              color: theme.colorScheme.error),
        ),
        confirmDismiss: (_) => _confirmDelete(context),
        onDismissed: (_) => ref.read(todayGoalsProvider.notifier).delete(goal),
        child: AuraCard(
          padding: const EdgeInsets.all(14),
          onTap: () => _showGoalFormSheet(context, ref, goal: goal),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                iconSize: 22,
                icon: Icon(
                  goal.isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: goal.isCompleted
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.outline,
                ),
                onPressed: () =>
                    ref.read(todayGoalsProvider.notifier).toggle(goal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: goal.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: goal.isCompleted
                            ? theme.textTheme.bodySmall?.color
                            : null,
                      ),
                    ),
                    if (goal.description != null &&
                        goal.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        goal.description!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (goal.progress.clamp(0, 100)) / 100,
                              minHeight: 6,
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                goal.isCompleted
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${goal.progress}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (goal.dueDate != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Due ${formatRelative(goal.dueDate!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
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
