import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

enum MessageRole { user, assistant, system }

enum MessageStatus { sending, streaming, sent, error }

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required MessageRole role,
    required String content,
    required DateTime createdAt,
    @Default(MessageStatus.sent) MessageStatus status,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

extension ChatMessageX on ChatMessage {
  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
}
