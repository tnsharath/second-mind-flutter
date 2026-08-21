import 'conversation.dart';

abstract class ChatRepository {
  /// Streams assistant reply chunks for [text] via POST /chat/stream.
  Stream<String> sendMessage({
    required String conversationId,
    required String text,
  });

  /// GET /context
  Future<List<Conversation>> getRecentConversations();
}
