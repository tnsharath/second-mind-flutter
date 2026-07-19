import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/conversation.dart';
import 'chat_controller.dart';

final recentConversationsProvider = FutureProvider<List<Conversation>>(
  (ref) => ref.watch(chatRepositoryProvider).getRecentConversations(),
);
