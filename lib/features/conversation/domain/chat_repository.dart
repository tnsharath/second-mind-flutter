import 'captured_item.dart';
import 'conversation.dart';

class ChatStreamChunk {
  const ChatStreamChunk({
    this.delta = '',
    this.capturedItems,
  });

  final String delta;
  final List<CapturedItem>? capturedItems;
}

abstract class ChatRepository {
  /// Streams assistant reply chunks for [text] via POST /chat/stream.
  Stream<String> sendMessage({
    required String conversationId,
    required String text,
  });

  /// Detailed SSE stream supporting text deltas and auto-captured metadata.
  Stream<ChatStreamChunk> streamMessage({
    required String conversationId,
    required String text,
  });

  /// GET /context
  Future<List<Conversation>> getRecentConversations();
}

