// chat_event.dart
import 'package:agrilink/features/chat/data/models/chat_model.dart';

abstract class ChatEvent {}

class LoadConversationsEvent extends ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final String conversationId;
  final String senderId;
  final String message;

  SendMessageEvent({
    required this.conversationId,
    required this.senderId,
    required this.message,
  });
}

class ListenMessagesEvent extends ChatEvent {}

class CreateConversationEvent extends ChatEvent {
  final String userOneId;
  final String userTwoId;

  CreateConversationEvent({
    required this.userOneId,
    required this.userTwoId,
  });
}

class NewMessageEvent extends ChatEvent {
  final MessageModel message;

  NewMessageEvent(this.message);
}