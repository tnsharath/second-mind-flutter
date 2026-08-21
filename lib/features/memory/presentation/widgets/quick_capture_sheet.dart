import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/shared/widgets/aura_bottom_sheet.dart';
import '../../../../core/shared/widgets/aura_button.dart';
import '../../../../core/shared/widgets/aura_text_field.dart';
import '../../../../features/notes/application/notes_providers.dart';
import '../../../../features/notes/domain/note.dart';
import '../../application/memory_providers.dart';
import '../../domain/memory_item.dart';

class QuickCaptureSheet extends HookConsumerWidget {
  const QuickCaptureSheet({super.key});

  static Future<void> show(BuildContext context) async {
    await AuraBottomSheet.show<void>(
      context,
      title: 'Quick capture',
      child: const QuickCaptureSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = useTextEditingController();
    final kind = useState<_CaptureKind>(_CaptureKind.memory);
    final category = useState<MemoryCategory>(MemoryCategory.note);

    Future<void> submit() async {
      final value = text.text.trim();
      if (value.isEmpty) return;

      if (kind.value == _CaptureKind.note) {
        await ref.read(notesProvider.notifier).add(
              text: value,
              kind: NoteKind.note,
            );
      } else {
        await ref.read(memoriesProvider.notifier).create(
              title: value.length <= 60 ? value : '${value.substring(0, 59)}…',
              description: value,
              category: category.value,
            );
      }
      if (context.mounted) Navigator.of(context).pop();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _KindSelector(
          value: kind.value,
          onChanged: (value) => kind.value = value,
        ),
        const SizedBox(height: 12),
        if (kind.value == _CaptureKind.memory) ...[
          _CategorySelector(
            value: category.value,
            onChanged: (value) => category.value = value,
          ),
          const SizedBox(height: 12),
        ],
        AuraTextField(
          controller: text,
          hint: kind.value == _CaptureKind.note
              ? 'Jot a note…'
              : 'Something to remember…',
          autofocus: true,
          minLines: 3,
          maxLines: 6,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
        const SizedBox(height: 16),
        AuraButton(
          label: 'Save',
          icon: Icons.check_rounded,
          onPressed: submit,
        ),
      ],
    );
  }
}

enum _CaptureKind { note, memory }

class _KindSelector extends StatelessWidget {
  const _KindSelector({required this.value, required this.onChanged});

  final _CaptureKind value;
  final ValueChanged<_CaptureKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_CaptureKind>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
          value: _CaptureKind.note,
          label: Text('Note'),
          icon: Icon(Icons.notes_rounded, size: 16),
        ),
        ButtonSegment(
          value: _CaptureKind.memory,
          label: Text('Memory'),
          icon: Icon(Icons.psychology_outlined, size: 16),
        ),
      ],
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
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
