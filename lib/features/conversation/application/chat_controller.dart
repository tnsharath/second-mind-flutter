import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/env.dart';
import '../../../core/providers/providers.dart';
import '../data/api_chat_repository.dart';
import '../data/mock_chat_repository.dart';
import '../domain/chat_message.dart';
import '../domain/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => Env.useMockApi
      ? MockChatRepository()
      : ApiChatRepository(ref.watch(apiClientProvider)),
);

class ChatState {
  const ChatState({
    this.messages = const [],
    this.isResponding = false,
  });

  final List<ChatMessage> messages;
  final bool isResponding;

  ChatState copyWith({List<ChatMessage>? messages, bool? isResponding}) {
    return ChatState(
      messages: messages ?? this.messages,
      isResponding: isResponding ?? this.isResponding,
    );
  }
}

final chatControllerProvider = NotifierProvider<ChatController, ChatState>(
  ChatController.new,
);

class ChatController extends Notifier<ChatState> {
  static const String _localConversationId = 'local';
  final Uuid _uuid = const Uuid();

  @override
  ChatState build() => const ChatState();

  Future<void> send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || state.isResponding) return;

    final now = DateTime.now();
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.user,
      content: text,
      createdAt: now,
    );
    final assistantMessage = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.assistant,
      content: '',
      createdAt: now,
      status: MessageStatus.streaming,
    );
    state = state.copyWith(
      messages: [...state.messages, userMessage, assistantMessage],
      isResponding: true,
    );

    final buffer = StringBuffer();
    try {
      await for (final chunk in ref.read(chatRepositoryProvider).sendMessage(
        conversationId: _localConversationId,
        text: text,
      )) {
        buffer.write(chunk);
        _updateAssistant(
          assistantMessage.id,
          buffer.toString(),
          MessageStatus.streaming,
        );
      }
      _updateAssistant(assistantMessage.id, buffer.toString(), MessageStatus.sent);
    } catch (_) {
      _updateAssistant(
        assistantMessage.id,
        'Something went wrong while reaching AURA. Please try again.',
        MessageStatus.error,
      );
    } finally {
      state = state.copyWith(isResponding: false);
    }
  }

  void _updateAssistant(String id, String content, MessageStatus status) {
    state = state.copyWith(
      messages: [
        for (final message in state.messages)
          if (message.id == id)
            message.copyWith(content: content, status: status)
          else
            message,
      ],
    );
  }

  void clear() {
    state = const ChatState();
  }
}
