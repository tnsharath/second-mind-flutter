import '../domain/captured_item.dart';
import '../domain/chat_repository.dart';
import '../domain/conversation.dart';

/// Simulates AURA's brain: canned, calm replies streamed word by word.
class MockChatRepository implements ChatRepository {
  static const List<String> _replies = [
    'Here\'s what I see: two meetings today and three open goals. '
        'I\'d suggest blocking 45 minutes after the design review to finish '
        'the proposal draft. Want me to hold that slot?',
    'Noted — I\'ll remember that. By the way, your evening looks clear, '
        'so that\'s the best window for the reading goal you set.',
    'I\'ve checked your schedule. Nothing conflicts right now. '
        'I\'ll nudge you ten minutes before the standup starts.',
    'That\'s a good thought to capture. I\'ve stored it as a memory and '
        'linked it to your current goals.',
  ];

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
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final reply = _replies[text.hashCode.abs() % _replies.length];
    final words = reply.split(' ');
    for (final word in words) {
      await Future<void>.delayed(const Duration(milliseconds: 45));
      yield ChatStreamChunk(delta: '$word ');
    }

    final captured = _extractMockCaptured(text);
    if (captured.isNotEmpty) {
      yield ChatStreamChunk(capturedItems: captured);
    }
  }

  List<CapturedItem> _extractMockCaptured(String text) {
    final lower = text.toLowerCase();
    final items = <CapturedItem>[];
    final title = text.length <= 40 ? text : '${text.substring(0, 39)}…';

    if (lower.contains('grateful') || lower.contains('thankful') || lower.contains('blessed')) {
      items.add(CapturedItem(
        category: 'gratitude',
        title: title,
        detail: text,
        entityType: 'note',
      ));
    } else if (lower.contains('feel') || lower.contains('today i') || lower.contains('reflected')) {
      items.add(CapturedItem(
        category: 'journal',
        title: title,
        detail: text,
        entityType: 'note',
      ));
    } else if (lower.contains('goal') || lower.contains('want to achieve') || lower.contains('target')) {
      items.add(CapturedItem(
        category: 'goal',
        title: title,
        detail: text,
        entityType: 'goal',
      ));
    } else if (lower.contains('remind') || lower.contains('meeting') || lower.contains('appointment') || lower.contains('call at')) {
      items.add(CapturedItem(
        category: 'schedule',
        title: title,
        detail: text,
        entityType: 'event',
      ));
    } else if (lower.contains('need to') || lower.contains('todo') || lower.contains('buy')) {
      items.add(CapturedItem(
        category: 'todo',
        title: title,
        detail: text,
        entityType: 'note',
      ));
    } else if (lower.contains('prefer') || lower.contains('favorite') || lower.contains('remember')) {
      items.add(CapturedItem(
        category: 'memory',
        title: title,
        detail: text,
        entityType: 'memory',
      ));
    }
    return items;
  }


  @override
  Future<List<Conversation>> getRecentConversations() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return [
      Conversation(
        id: 'c1',
        title: 'Planning tomorrow',
        preview: 'Let\'s move the gym session to 7:00…',
        updatedAt: now.subtract(const Duration(minutes: 42)),
      ),
      Conversation(
        id: 'c2',
        title: 'Book recommendations',
        preview: 'Added two titles to your reading memory.',
        updatedAt: now.subtract(const Duration(hours: 3)),
      ),
      Conversation(
        id: 'c3',
        title: 'Weekly review',
        preview: 'You completed 5 of 7 goals this week.',
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}
