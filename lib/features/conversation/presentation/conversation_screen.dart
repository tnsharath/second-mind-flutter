import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../routes/app_router.dart';
import '../application/chat_controller.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/message_bubble.dart';

class ConversationScreen extends HookConsumerWidget {
  const ConversationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chat = ref.watch(chatControllerProvider);
    final controller = ref.read(chatControllerProvider.notifier);
    final input = useTextEditingController();
    final scroll = useScrollController();
    final canSend = useState(false);

    useEffect(() {
      void listener() => canSend.value = input.text.trim().isNotEmpty;
      input.addListener(listener);
      return () => input.removeListener(listener);
    }, [input]);

    final scrollTrigger = chat.messages.isEmpty
        ? 0
        : chat.messages.length + chat.messages.last.content.length;
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scroll.hasClients) scroll.jumpTo(0);
      });
      return null;
    }, [scrollTrigger]);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AURA', style: theme.textTheme.titleLarge),
            Text(
              chat.isResponding ? 'Thinking…' : 'Always with you',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chat.messages.isEmpty
                ? Center(
                    child: Text(
                      'Say something — AURA is listening.',
                      style: theme.textTheme.bodySmall,
                    ),
                  )
                : ListView.builder(
                    controller: scroll,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    itemCount: chat.messages.length,
                    itemBuilder: (context, index) {
                      final message =
                          chat.messages[chat.messages.length - 1 - index];
                      return MessageBubble(message: message);
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: ChatInputBar(
              controller: input,
              enabled: !chat.isResponding,
              canSend: canSend.value,
              onSend: () {
                controller.send(input.text);
                input.clear();
              },
              onVoice: () => context.push(AppRoutes.voice),
            ),
          ),
        ],
      ),
    );
  }
}
