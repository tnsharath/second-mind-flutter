import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/env.dart';
import '../../../core/providers/providers.dart';
import '../../../core/services/memory_capture_service.dart';
import '../../calendar/application/calendar_providers.dart';
import '../../goals/application/goals_providers.dart';
import '../../journal/application/journal_providers.dart';
import '../../memory/application/memory_providers.dart';
import '../../notes/application/notes_providers.dart';
import '../data/mock_chat_repository.dart';
import '../data/sse_chat_repository.dart';
import '../domain/captured_item.dart';
import '../domain/chat_message.dart';
import '../domain/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => Env.useMockApi
      ? MockChatRepository()
      : SseChatRepository(ref.watch(apiClientProvider)),
);

final memoryCaptureServiceProvider = Provider<MemoryCaptureService>(
  (ref) => MemoryCaptureService.withRef(ref),
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
  final Uuid _uuid = const Uuid();

  /// Per-session conversation id so server-side history is scoped to
  /// this app session.
  late final String _conversationId = _uuid.v4();

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
    final capturedList = <CapturedItem>[];

    try {
      await for (final chunk in ref.read(chatRepositoryProvider).streamMessage(
        conversationId: _conversationId,
        text: text,
      )) {
        if (chunk.delta.isNotEmpty) {
          buffer.write(chunk.delta);
          _updateAssistant(
            assistantMessage.id,
            buffer.toString(),
            MessageStatus.streaming,
            capturedItems: capturedList,
          );
        }
        if (chunk.capturedItems != null && chunk.capturedItems!.isNotEmpty) {
          capturedList.addAll(chunk.capturedItems!);
          _invalidateSectionProviders(chunk.capturedItems!);
          _updateAssistant(
            assistantMessage.id,
            buffer.toString(),
            MessageStatus.streaming,
            capturedItems: capturedList,
          );
        }
      }
      _updateAssistant(
        assistantMessage.id,
        buffer.toString(),
        MessageStatus.sent,
        capturedItems: capturedList,
      );
    } catch (_) {
      final msg = buffer.isNotEmpty
          ? '${buffer.toString()}\n[Stream disconnected]'
          : 'Something went wrong while reaching AURA. Please try again.';
      _updateAssistant(
        assistantMessage.id,
        msg,
        MessageStatus.error,
        capturedItems: capturedList,
      );
    } finally {
      state = state.copyWith(isResponding: false);
      unawaited(_maybeCaptureMemory(text));
    }
  }

  Future<void> _maybeCaptureMemory(String text) async {
    final capture = ref.read(memoryCaptureServiceProvider);
    if (capture.shouldCapture(text)) {
      await capture.capture(text);
    }
  }

  void _invalidateSectionProviders(List<CapturedItem> items) {
    for (final item in items) {
      switch (item.category) {
        case 'gratitude':
        case 'journal':
          ref.invalidate(journalProvider);
          ref.invalidate(notesProvider);
          break;
        case 'todo':
        case 'reminder':
          ref.invalidate(notesProvider);
          break;
        case 'schedule':
          ref.invalidate(upcomingEventsProvider);
          break;
        case 'goal':
          ref.invalidate(todayGoalsProvider);
          break;

        case 'memory':
          ref.invalidate(memoriesProvider);
          break;
      }
    }
  }

  void _updateAssistant(
    String id,
    String content,
    MessageStatus status, {
    List<CapturedItem>? capturedItems,
  }) {
    state = state.copyWith(
      messages: [
        for (final message in state.messages)
          if (message.id == id)
            message.copyWith(
              content: content,
              status: status,
              capturedItems: capturedItems ?? message.capturedItems,
            )
          else
            message,
      ],
    );
  }


  void clear() {
    state = const ChatState();
  }
}
