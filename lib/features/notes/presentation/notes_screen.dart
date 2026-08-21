import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/shared/widgets/aura_card.dart';
import '../../../core/shared/widgets/aura_dialog.dart';
import '../../../core/shared/widgets/aura_empty_view.dart';
import '../../../core/shared/widgets/aura_error_view.dart';
import '../../../core/shared/widgets/aura_loading.dart';
import '../../../core/shared/widgets/aura_text_field.dart';
import '../../../core/utils/time_format.dart';
import '../application/notes_providers.dart';
import '../domain/note.dart';

class NotesScreen extends HookConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final input = useTextEditingController();
    final kind = useState(NoteKind.note);

    void submit() {
      final text = input.text.trim();
      if (text.isEmpty) return;
      ref.read(notesProvider.notifier).add(text: text, kind: kind.value);
      input.clear();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Column(
              children: [
                AuraTextField(
                  controller: input,
                  hint: 'Capture a note or idea…',
                  prefixIcon: Icons.edit_note_rounded,
                  onSubmitted: (_) => submit(),
                  suffix: IconButton(
                    icon: const Icon(Icons.arrow_upward_rounded, size: 20),
                    onPressed: submit,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (final k in NoteKind.values) ...[
                      ChoiceChip(
                        label: Text(k.name),
                        selected: kind.value == k,
                        onSelected: (_) => kind.value = k,
                      ),
                      if (k != NoteKind.values.last) const SizedBox(width: 8),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: notes.when(
              loading: () => const AuraLoading(),
              error: (_, __) => AuraErrorView(
                message: 'Notes could not be loaded.',
                onRetry: () => ref.invalidate(notesProvider),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return const AuraEmptyView(
                    title: 'No notes yet',
                    message: 'Jot something down above — notes and ideas live here.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  itemCount: list.length,
                  itemBuilder: (context, index) =>
                      _NoteCard(note: list[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends ConsumerWidget {
  const _NoteCard({required this.note});

  final Note note;

  Future<void> _pickReminder(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: note.remindAt ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(note.remindAt ?? now),
    );
    if (time == null) return;
    final at = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    ref.read(notesProvider.notifier).update(note.copyWith(remindAt: at));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = ref.read(notesProvider.notifier);
    final isIdea = note.kind == NoteKind.idea;
    final color = isIdea ? const Color(0xFFFBBF24) : const Color(0xFF5B8CFF);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey(note.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: theme.colorScheme.error,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.delete_outline_rounded,
              color: theme.colorScheme.onError),
        ),
        confirmDismiss: (_) => AuraDialog.showConfirm(
          context,
          title: 'Delete note?',
          message: 'This note will be removed permanently.',
          confirmLabel: 'Delete',
          destructive: true,
        ),
        onDismissed: (_) => controller.delete(note),
        child: AuraCard(
          padding: const EdgeInsets.all(14),
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
                child: Icon(
                  isIdea ? Icons.lightbulb_outline_rounded : Icons.notes_rounded,
                  size: 18,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration:
                            note.done ? TextDecoration.lineThrough : null,
                        color: note.done
                            ? theme.textTheme.bodySmall?.color
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${note.kind.name} · ${formatRelative(note.createdAt)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (note.remindAt != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.alarm_rounded,
                              size: 14, color: theme.colorScheme.secondary),
                          const SizedBox(width: 4),
                          Text(
                            _formatReminder(note.remindAt!),
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.secondary),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => controller
                                .update(note.copyWith(remindAt: null)),
                            child: Icon(Icons.close_rounded,
                                size: 14, color: theme.colorScheme.outline),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.alarm_add_rounded, size: 20),
                tooltip: 'Set reminder',
                onPressed: () => _pickReminder(context, ref),
              ),
              Checkbox(
                value: note.done,
                onChanged: (_) => controller.toggleDone(note),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Human-friendly reminder time ("in 30 min", "in 2 h", "Mar 5, 14:00").
String _formatReminder(DateTime time) {
  final diff = time.difference(DateTime.now());
  if (diff.isNegative) return 'overdue · ${formatRelative(time)}';
  if (diff.inMinutes < 1) return 'in a moment';
  if (diff.inMinutes < 60) return 'in ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'in ${diff.inHours} h';
  return DateFormat('MMM d, HH:mm').format(time);
}
