import 'dart:convert';

import '../../../core/errors/failure.dart';
import '../../../core/services/api_client.dart';
import '../domain/captured_item.dart';
import '../domain/chat_repository.dart';
import '../domain/conversation.dart';


/// Real backend implementation with SSE streaming — used when
/// USE_MOCK_API=false. POSTs to /chat/stream and yields each `delta`
/// token as it arrives on the text/event-stream response.
class SseChatRepository implements ChatRepository {
  SseChatRepository(this._client);

  final ApiClient _client;

  @override
  Stream<String> sendMessage({
    required String conversationId,
    required String text,
  }) async* {
    await for (final chunk in streamMessage(conversationId: conversationId, text: text)) {
      if (chunk.delta.isNotEmpty) yield chunk.delta;
    }
  }

  @override
  Stream<ChatStreamChunk> streamMessage({
    required String conversationId,
    required String text,
  }) async* {
    final response = await _client.postStream(
      '/chat/stream',
      body: {'conversationId': conversationId, 'message': text},
    );
    final body = response.data;
    if (body == null) return;

    try {
      final lines = utf8.decoder
          .bind(body.stream)
          .transform(const LineSplitter());
      await for (final line in lines) {
        if (!line.startsWith('data:')) continue;
        final payload = line.substring(5).trim();
        if (payload.isEmpty) continue;
        if (payload == '[DONE]') return;

        final Map<String, dynamic> chunk;
        try {
          chunk = jsonDecode(payload) as Map<String, dynamic>;
        } on FormatException {
          continue; // ignore non-JSON keep-alive lines
        }

        final error = chunk['error'];
        if (error is String && error.isNotEmpty) {
          throw AppFailure(error);
        }

        final rawCaptured = chunk['captured_items'];
        if (rawCaptured is List && rawCaptured.isNotEmpty) {
          final items = rawCaptured
              .whereType<Map<String, dynamic>>()
              .map((j) => CapturedItem.fromJson(j))
              .toList();
          yield ChatStreamChunk(capturedItems: items);
        }

        final delta = chunk['delta'];
        if (delta is String && delta.isNotEmpty) {
          yield ChatStreamChunk(delta: delta);
        }
      }
    } catch (e) {
      if (e is AppFailure) rethrow;
      throw AppFailure('Stream disconnected: ${e.toString()}');
    }
  }



  @override
  Future<List<Conversation>> getRecentConversations() async {
    final response = await _client.get<List<dynamic>>('/context');
    final data = response.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((json) => Conversation.fromJson(_normalizeId(json)))
        .toList();
  }
}

/// Backend ids may be integers; the Dart models use String ids.
Map<String, dynamic> _normalizeId(Map<String, dynamic> json) => {
      ...json,
      'id': json['id'].toString(),
    };
