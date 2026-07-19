import '../domain/chat_repository.dart';
import '../domain/conversation.dart';

/// Simulates AURA's brain: canned, calm replies streamed word by word.
class MockChatRepository implements ChatRepository {
  static const List<String> _replies = [
    "Here's what I see: two meetings today and three open goals. "
        "I'd suggest blocking 45 minutes after the design review to finish "
        "the proposal draft. Want me to hold that slot?",
    "Noted — I'll remember that. By the way, your evening looks clear, "
        "so that's the best window for the reading goal you set.",
    "I've checked your schedule. Nothing conflicts right now. "
        "I'll nudge you ten minutes before the standup starts.",
    "That's a good thought to capture. I've stored it as a memory and "
        "linked it to your current goals.",
  ];

  @override
  Stream<String> sendMessage({
    required String conversationId,
    required String text,
  }) async* {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final reply = _replies[text.hashCode.abs() % _replies.length];
    final words = reply.split(' ');
    for (final word in words) {
      await Future<void>.delayed(const Duration(milliseconds: 45));
      yield '$word ';
    }
  }

  @override
  Future<List<Conversation>> getRecentConversations() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return [
      Conversation(
        id: 'c1',
        title: 'Planning tomorrow',
        preview: "Let's move the gym session to 7:00…",
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
