import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/services/reflection_prompt_service.dart';
import '../../../../core/shared/widgets/aura_button.dart';
import '../../../../core/shared/widgets/aura_card.dart';
import '../../../../core/shared/widgets/aura_text_field.dart';
import '../../../memory/application/memory_providers.dart';
import '../../../memory/domain/memory_item.dart';

class ReflectionPromptCard extends HookConsumerWidget {
  const ReflectionPromptCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final prompt = ReflectionPromptService.forToday();
    final isExpanded = useState(false);

    return AuraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.self_improvement_outlined,
                size: 20,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Daily reflection',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(prompt, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          if (isExpanded.value)
            _ReflectionInput(
              prompt: prompt,
              onSaved: () => isExpanded.value = false,
            )
          else
            AuraButton(
              label: 'Reflect',
              variant: AuraButtonVariant.tonal,
              onPressed: () => isExpanded.value = true,
            ),
        ],
      ),
    );
  }
}

class _ReflectionInput extends HookConsumerWidget {
  const _ReflectionInput({required this.prompt, required this.onSaved});

  final String prompt;
  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final isSaving = useState(false);

    Future<void> save() async {
      final text = controller.text.trim();
      if (text.isEmpty) return;
      isSaving.value = true;
      try {
        await ref.read(memoriesProvider.notifier).create(
              title: 'Reflection: $prompt',
              description: text,
              category: MemoryCategory.reflection,
            );
        onSaved();
      } finally {
        isSaving.value = false;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuraTextField(
          controller: controller,
          hint: 'Write a few sentences...',
          minLines: 3,
          maxLines: 6,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AuraButton(
                label: 'Cancel',
                variant: AuraButtonVariant.ghost,
                onPressed: onSaved,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AuraButton(
                label: isSaving.value ? 'Saving...' : 'Save reflection',
                onPressed: isSaving.value ? null : save,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
