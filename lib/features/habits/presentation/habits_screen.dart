import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/shared/widgets/aura_bottom_sheet.dart';
import '../../../core/shared/widgets/aura_button.dart';
import '../../../core/shared/widgets/aura_card.dart';
import '../../../core/shared/widgets/aura_empty_view.dart';
import '../../../core/shared/widgets/aura_error_view.dart';
import '../../../core/shared/widgets/aura_loading.dart';
import '../../../core/shared/widgets/aura_text_field.dart';
import '../application/habits_providers.dart';
import '../domain/habit.dart';
import 'widgets/habit_list_tile.dart';

class HabitsScreen extends HookConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showHabitFormSheet(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: habits.when(
        loading: () => const AuraLoading(),
        error: (_, __) => AuraErrorView(
          message: 'Habits could not be loaded.',
          onRetry: () => ref.invalidate(habitsProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const AuraEmptyView(
              title: 'No habits yet',
              message: 'Tap + to add a habit AURA can help you track.',
              icon: Icons.repeat_rounded,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(habitsProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
              children: [
                for (final habit in list) HabitListTile(habit: habit),
              ],
            ),
          );
        },
      ),
    );
  }
}

Future<void> _showHabitFormSheet(
  BuildContext context,
  WidgetRef ref, {
  Habit? habit,
}) async {
  final result = await AuraBottomSheet.show<HabitFormResult>(
    context,
    title: habit == null ? 'New habit' : 'Edit habit',
    child: _HabitForm(
      initialTitle: habit?.title ?? '',
      initialDescription: habit?.description ?? '',
      initialFrequency: habit?.frequency ?? HabitFrequency.daily,
      initialTargetCount: habit?.targetCount ?? 1,
    ),
  );
  if (result == null) return;

  if (habit == null) {
    await ref.read(habitsProvider.notifier).create(
          title: result.title,
          description: result.description,
          frequency: result.frequency,
          targetCount: result.targetCount,
        );
  } else {
    await ref.read(habitsProvider.notifier).updateHabit(
          habit.copyWith(
            title: result.title,
            description: result.description,
            frequency: result.frequency,
            targetCount: result.targetCount,
          ),
        );
  }
}

typedef HabitFormResult = ({
  String title,
  String? description,
  HabitFrequency frequency,
  int targetCount,
});

class _HabitForm extends HookConsumerWidget {
  const _HabitForm({
    required this.initialTitle,
    required this.initialDescription,
    required this.initialFrequency,
    required this.initialTargetCount,
  });

  final String initialTitle;
  final String initialDescription;
  final HabitFrequency initialFrequency;
  final int initialTargetCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = useTextEditingController(text: initialTitle);
    final description = useTextEditingController(text: initialDescription);
    final frequency = useState<HabitFrequency>(initialFrequency);
    final targetCount = useState<int>(initialTargetCount);

    void submit() {
      final trimmed = title.text.trim();
      if (trimmed.isEmpty) return;
      final desc = description.text.trim();
      Navigator.of(context).pop((
        title: trimmed,
        description: desc.isEmpty ? null : desc,
        frequency: frequency.value,
        targetCount: targetCount.value.clamp(1, 99),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AuraTextField(
          controller: title,
          hint: 'What habit do you want to build?',
          autofocus: true,
          onSubmitted: (_) => submit(),
        ),
        const SizedBox(height: 12),
        AuraTextField(
          controller: description,
          hint: 'Description (optional)',
          minLines: 2,
          maxLines: 4,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
        const SizedBox(height: 12),
        _FrequencySelector(
          value: frequency.value,
          onChanged: (value) => frequency.value = value,
        ),
        const SizedBox(height: 12),
        _TargetCountSelector(
          value: targetCount.value,
          onChanged: (value) => targetCount.value = value,
        ),
        const SizedBox(height: 16),
        AuraButton(label: 'Save habit', onPressed: submit),
      ],
    );
  }
}

class _FrequencySelector extends StatelessWidget {
  const _FrequencySelector({required this.value, required this.onChanged});

  final HabitFrequency value;
  final ValueChanged<HabitFrequency> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AuraCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Frequency', style: theme.textTheme.bodyMedium),
          ),
          SegmentedButton<HabitFrequency>(
            segments: const [
              ButtonSegment(
                value: HabitFrequency.daily,
                label: Text('Daily'),
              ),
              ButtonSegment(
                value: HabitFrequency.weekly,
                label: Text('Weekly'),
              ),
            ],
            selected: {value},
            onSelectionChanged: (selected) {
              if (selected.isNotEmpty) onChanged(selected.first);
            },
            showSelectedIcon: false,
          ),
        ],
      ),
    );
  }
}

class _TargetCountSelector extends StatelessWidget {
  const _TargetCountSelector({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AuraCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.format_list_numbered_outlined,
              size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Target per day', style: theme.textTheme.bodyMedium),
          ),
          IconButton(
            icon: const Icon(Icons.remove_rounded),
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
          ),
          Text(value.toString(), style: theme.textTheme.titleMedium),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: value < 99 ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}
