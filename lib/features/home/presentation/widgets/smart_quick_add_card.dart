import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/providers/providers.dart';
import '../../../../core/services/reminder_scheduler.dart';
import '../../../../core/shared/widgets/aura_button.dart';
import '../../../../core/shared/widgets/aura_card.dart';
import '../../../../core/shared/widgets/aura_text_field.dart';
import '../../../../routes/app_router.dart';
import '../../../calendar/application/calendar_providers.dart';
import '../../../goals/application/goals_providers.dart';
import '../../../memory/application/memory_providers.dart';
import '../../../notes/application/notes_providers.dart';


class SmartQuickAddCard extends HookConsumerWidget {
  const SmartQuickAddCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = useTextEditingController();
    final isSubmitting = useState(false);
    final statusMessage = useState<({String text, Color color})?>(null);
    final hasText = useListenable(controller).text.trim().isNotEmpty;

    Future<void> submit() async {
      final text = controller.text.trim();
      if (text.isEmpty || isSubmitting.value) return;

      isSubmitting.value = true;
      statusMessage.value = null;

      try {
        final client = ref.read(apiClientProvider);
        final res = await client.post<Map<String, dynamic>>(
          '/context/quick-add',
          body: {'text': text},
        );

        final data = res.data ?? {};
        final entityType = data['entityType'] as String? ?? 'note';
        final message = data['message'] as String? ?? 'Saved!';

        controller.clear();

        // Invalidate providers so UI instantly updates
        ref.invalidate(todayGoalsProvider);
        ref.invalidate(upcomingEventsProvider);
        ref.invalidate(memoriesProvider);
        ref.invalidate(notesProvider);

        if (entityType == 'event') {
          await ReminderScheduler.rescheduleAll(ref);
        }

        final color = switch (entityType) {
          'goal' => const Color(0xFF4ADE80),
          'event' => theme.colorScheme.primary,
          'journal' => const Color(0xFFFBBF24),
          'memory' => const Color(0xFFA78BFA),
          _ => theme.colorScheme.secondary,
        };

        statusMessage.value = (text: '✨ $message', color: color);
      } catch (e) {
        statusMessage.value = (
          text: 'Failed to process input. Saved locally.',
          color: theme.colorScheme.error,
        );
      } finally {
        isSubmitting.value = false;
      }
    }

    return AuraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Smart Quick Add',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Type anything (task, reminder, note, memory, reflection) — AURA will categorize it automatically.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AuraTextField(
                  controller: controller,
                  hint: 'e.g., Remind me to call Alex at 5pm...',
                  onSubmitted: (_) => submit(),
                ),
              ),
              const SizedBox(width: 8),
              if (hasText)
                AuraButton(
                  label: isSubmitting.value ? '...' : 'Add',
                  icon: Icons.send_rounded,
                  onPressed: isSubmitting.value ? null : submit,
                  expand: false,
                )
              else
                AuraButton(
                  label: 'Voice',
                  icon: Icons.mic_rounded,
                  variant: AuraButtonVariant.primary,
                  onPressed: () => context.push(AppRoutes.voice),
                  expand: false,
                ),
            ],
          ),
          if (statusMessage.value != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusMessage.value!.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: statusMessage.value!.color.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                statusMessage.value!.text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: statusMessage.value!.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
