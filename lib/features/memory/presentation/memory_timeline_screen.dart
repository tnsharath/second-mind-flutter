import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/shared/widgets/aura_card.dart';
import '../../../core/shared/widgets/aura_empty_view.dart';
import '../../../core/shared/widgets/aura_error_view.dart';
import '../../../core/shared/widgets/aura_loading.dart';
import '../../../core/shared/widgets/aura_text_field.dart';
import '../../../core/utils/time_format.dart';
import '../application/memory_providers.dart';
import '../domain/memory_item.dart';
import 'widgets/memory_detail_sheet.dart';

import '../../../core/shared/widgets/aura_bottom_sheet.dart';
import '../../../core/shared/widgets/aura_button.dart';

class MemoryTimelineScreen extends HookConsumerWidget {
  const MemoryTimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memories = ref.watch(filteredMemoriesProvider);
    final search = useTextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Memory timeline')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMemorySheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add memory'),
      ),
      body: Column(

        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: AuraTextField(
              controller: search,
              hint: 'Search memories…',
              prefixIcon: Icons.search_rounded,
              onChanged: (value) =>
                  ref.read(memorySearchProvider.notifier).state = value,
            ),
          ),
          Expanded(
            child: memories.when(
              loading: () => const AuraLoading(),
              error: (_, __) => AuraErrorView(
                message: 'Memories could not be loaded.',
                onRetry: () => ref.invalidate(memoriesProvider),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return const AuraEmptyView(
                    title: 'No memories found',
                    message: 'AURA will start remembering as you talk.',
                  );
                }
                final today = list.where((m) => isToday(m.timestamp)).toList();
                final earlier =
                    list.where((m) => !isToday(m.timestamp)).toList();
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(memoriesProvider),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    children: [
                      if (today.isNotEmpty) ...[
                        const _DayHeader(label: 'Today'),
                        for (final m in today) _MemoryTile(memory: m),
                      ],
                      if (earlier.isNotEmpty) ...[
                        const _DayHeader(label: 'Earlier'),
                        for (final m in earlier) _MemoryTile(memory: m),
                      ],
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

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _MemoryTile extends StatelessWidget {
  const _MemoryTile({required this.memory});

  final MemoryItem memory;

  static const Map<MemoryCategory, (IconData, Color)> _styles = {
    MemoryCategory.event: (Icons.event_outlined, Color(0xFF5B8CFF)),
    MemoryCategory.goal: (Icons.flag_outlined, Color(0xFF4ADE80)),
    MemoryCategory.preference: (Icons.tune_rounded, Color(0xFF6EE7F9)),
    MemoryCategory.note: (Icons.notes_rounded, Color(0xFFFBBF24)),
    MemoryCategory.milestone: (Icons.emoji_events_outlined, Color(0xFFF472B6)),
    MemoryCategory.reflection: (Icons.self_improvement_rounded, Color(0xFFA78BFA)),
  };


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = _styles[memory.category]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AuraCard(
        padding: const EdgeInsets.all(14),
        onTap: () => MemoryDetailSheet.show(context, memory),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          memory.title,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (memory.isImportant)
                        Icon(Icons.star_rounded,
                            size: 16, color: theme.colorScheme.secondary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(memory.description, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Text(
                    '${memory.category.name} · ${formatRelative(memory.timestamp)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showAddMemorySheet(BuildContext context, WidgetRef ref) async {
  final result = await AuraBottomSheet.show<
      ({String title, String description, MemoryCategory category, bool isImportant})>(
    context,
    title: 'New Memory',
    child: const _AddMemoryForm(),
  );
  if (result == null || result.title.trim().isEmpty) return;

  await ref.read(memoriesProvider.notifier).create(
        title: result.title.trim(),
        description: result.description.trim(),
        category: result.category,
        isImportant: result.isImportant,
      );
}

class _AddMemoryForm extends HookWidget {
  const _AddMemoryForm();

  @override
  Widget build(BuildContext context) {
    final title = useTextEditingController();
    final description = useTextEditingController();
    final category = useState<MemoryCategory>(MemoryCategory.note);
    final isImportant = useState<bool>(false);

    void submit() {
      final t = title.text.trim();
      if (t.isEmpty) return;
      Navigator.of(context).pop((
        title: t,
        description: description.text.trim(),
        category: category.value,
        isImportant: isImportant.value,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuraTextField(
          controller: title,
          hint: 'Memory title',
          autofocus: true,
        ),
        const SizedBox(height: 12),
        AuraTextField(
          controller: description,
          hint: 'Details (optional)',
          minLines: 3,
          maxLines: 5,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<MemoryCategory>(
          value: category.value,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final cat in MemoryCategory.values)
              DropdownMenuItem(
                value: cat,
                child: Text(cat.name.toUpperCase()),
              ),
          ],
          onChanged: (val) {
            if (val != null) category.value = val;
          },
        ),
        const SizedBox(height: 10),
        CheckboxListTile(
          title: const Text('Mark as important / star'),
          value: isImportant.value,
          onChanged: (val) => isImportant.value = val ?? false,
        ),
        const SizedBox(height: 16),
        AuraButton(label: 'Save memory', onPressed: submit),
      ],
    );
  }
}

