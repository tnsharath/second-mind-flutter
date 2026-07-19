import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/chat_message.dart';
import 'typing_indicator.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isUser = message.isUser;
    final isThinking =
        message.status == MessageStatus.streaming && message.content.isEmpty;

    final bubbleColor = isUser
        ? scheme.primary
        : message.status == MessageStatus.error
            ? scheme.error.withValues(alpha: 0.12)
            : scheme.surfaceContainerLow;

    final textColor = isUser ? Colors.white : scheme.onSurface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppSpacing.radiusLg),
            topRight: const Radius.circular(AppSpacing.radiusLg),
            bottomLeft: Radius.circular(isUser ? AppSpacing.radiusLg : 6),
            bottomRight: Radius.circular(isUser ? 6 : AppSpacing.radiusLg),
          ),
          border: isUser
              ? null
              : Border.all(color: scheme.outline.withValues(alpha: 0.6)),
        ),
        child: isThinking
            ? const TypingIndicator()
            : isUser
                ? SelectableText(
                    message.content,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: textColor),
                  )
                : MarkdownBody(
                    data: message.content,
                    selectable: true,
                    styleSheet:
                        MarkdownStyleSheet.fromTheme(theme).copyWith(
                      p: theme.textTheme.bodyMedium
                          ?.copyWith(color: textColor, height: 1.45),
                      code: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: AppColors.accent,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                    ),
                  ),
      ),
    );
  }
}
