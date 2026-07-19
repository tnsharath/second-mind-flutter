import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/aura_text_field.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.enabled,
    required this.canSend,
    required this.onSend,
    required this.onVoice,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool canSend;
  final VoidCallback onSend;
  final VoidCallback onVoice;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.mic_none_rounded),
            color: scheme.onSurfaceVariant,
            onPressed: onVoice,
          ),
          Expanded(
            child: AuraTextField(
              controller: controller,
              hint: 'Talk to AURA…',
              enabled: enabled,
              onSubmitted: canSend ? (_) => onSend() : null,
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            icon: const Icon(Icons.arrow_upward_rounded, size: 20),
            onPressed: canSend && enabled ? onSend : null,
          ),
        ],
      ),
    );
  }
}
