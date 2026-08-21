import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/shared/widgets/aura_bottom_sheet.dart';
import '../../../../core/shared/widgets/aura_button.dart';
import '../../../../core/shared/widgets/aura_text_field.dart';
import '../../application/memory_providers.dart';
import '../../domain/memory_item.dart';

class MemoryDetailSheet extends HookConsumerWidget {
  const MemoryDetailSheet({super.key, required this.memory});

  final MemoryItem memory;

  static Future<void> show(BuildContext context, MemoryItem memory) async {
    await AuraBottomSheet.show<void>(
      context,
      title: 'Memory',
      child: MemoryDetailSheet(memory: memory),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = useState(false);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isEditing.value
          ? _EditForm(
              memory: memory,
              onDone: () => isEditing.value = false,
            )
          : _ViewBody(
              memory: memory,
              onEdit: () => isEditing.value = true,
            ),
    );
  }
}

class _ViewBody extends ConsumerWidget {
  const _ViewBody({required this.memory, required this.onEdit});

  final MemoryItem memory;
  final VoidCallback onEdit;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete memory?'),
        content: const Text('This memory will be removed permanently.'),
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
    if (confirmed == true) {
      await ref.read(memoriesProvider.notifier).delete(memory.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = _categoryColor(memory.category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_categoryIcon(memory.category), size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                memory.category.name.toUpperCase(),
                style: theme.textTheme.bodySmall,
              ),
            ),
            IconButton(
              icon: Icon(
                memory.isImportant ? Icons.star_rounded : Icons.star_outline_rounded,
                color: memory.isImportant ? theme.colorScheme.secondary : null,
              ),
              onPressed: () => ref
                  .read(memoriesProvider.notifier)
                  .togglePin(memory),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          memory.title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (memory.description.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            memory.description,
            style: theme.textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: AuraButton(
                label: 'Edit',
                icon: Icons.edit_outlined,
                variant: AuraButtonVariant.tonal,
                onPressed: onEdit,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AuraButton(
                label: 'Delete',
                icon: Icons.delete_outline_rounded,
                variant: AuraButtonVariant.ghost,
                onPressed: () => _confirmDelete(context, ref),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EditForm extends HookConsumerWidget {
  const _EditForm({required this.memory, required this.onDone});

  final MemoryItem memory;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = useTextEditingController(text: memory.title);
    final description = useTextEditingController(text: memory.description);
    final category = useState<MemoryCategory>(memory.category);
    final isImportant = useState<bool>(memory.isImportant);

    Future<void> save() async {
      final trimmedTitle = title.text.trim();
      if (trimmedTitle.isEmpty) return;
      await ref.read(memoriesProvider.notifier).update(
            memory.copyWith(
              title: trimmedTitle,
              description: description.text.trim(),
              category: category.value,
              isImportant: isImportant.value,
            ),
          );
      onDone();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuraTextField(
          controller: title,
          hint: 'Title',
          autofocus: true,
        ),
        const SizedBox(height: 12),
        AuraTextField(
          controller: description,
          hint: 'Description',
          minLines: 3,
          maxLines: 6,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
        const SizedBox(height: 12),
        _CategorySelector(
          value: category.value,
          onChanged: (value) => category.value = value,
        ),
        const SizedBox(height: 8),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Pinned'),
          value: isImportant.value,
          onChanged: (value) => isImportant.value = value,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AuraButton(
                label: 'Cancel',
                variant: AuraButtonVariant.ghost,
                onPressed: onDone,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AuraButton(
                label: 'Save',
                icon: Icons.check_rounded,
                onPressed: save,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({required this.value, required this.onChanged});

  final MemoryCategory value;
  final ValueChanged<MemoryCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (final category in MemoryCategory.values)
          ChoiceChip(
            label: Text(category.name),
            selected: value == category,
            onSelected: (_) => onChanged(category),
          ),
      ],
    );
  }
}

Color _categoryColor(MemoryCategory category) {
  return switch (category) {
    MemoryCategory.event => const Color(0xFF5B8CFF),
    MemoryCategory.goal => const Color(0xFF4ADE80),
    MemoryCategory.preference => const Color(0xFF6EE7F9),
    MemoryCategory.note => const Color(0xFFFBBF24),
    MemoryCategory.milestone => const Color(0xFFF472B6),
  };
}

IconData _categoryIcon(MemoryCategory category) {
  return switch (category) {
    MemoryCategory.event => Icons.event_outlined,
    MemoryCategory.goal => Icons.flag_outlined,
    MemoryCategory.preference => Icons.tune_rounded,
    MemoryCategory.note => Icons.notes_rounded,
    MemoryCategory.milestone => Icons.emoji_events_outlined,
  };
}
