import '../../../core/services/api_client.dart';
import '../domain/chat_repository.dart';
import '../domain/conversation.dart';

/// Real backend implementation — used when USE_MOCK_API=false.
///
/// TODO(backend): replace the single-shot POST with streaming (SSE/WS)
/// once the FastAPI /chat endpoint supports it.
class ApiChatRepository implements ChatRepository {
  ApiChatRepository(this._client);

  final ApiClient _client;

  @override
  Stream<String> sendMessage({
    required String conversationId,
    required String text,
  }) async* {
    final response = await _client.post<Map<String, dynamic>>(
      '/chat',
      body: {'conversationId': conversationId, 'message': text},
    );
    final reply = response.data?['reply'];
    yield reply is String ? reply : '';
  }

  @override
  Future<List<Conversation>> getRecentConversations() async {
    final response = await _client.get<List<dynamic>>('/context');
    final data = response.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Conversation.fromJson)
        .toList();
  }
}
