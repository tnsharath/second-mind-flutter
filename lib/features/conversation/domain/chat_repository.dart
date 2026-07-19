import 'conversation.dart';

abstract class ChatRepository {
  /// Streams assistant reply chunks for [text].
  ///
  /// TODO(backend): POST /chat — upgrade to SSE or the WebSocket channel
  /// once the FastAPI backend is live.
  Stream<String> sendMessage({
    required String conversationId,
    required String text,
  });

  /// TODO(backend): GET /context (recent conversation list)
  Future<List<Conversation>> getRecentConversations();
}
