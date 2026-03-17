import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';

abstract class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatConversationsLoaded extends ChatState {
  final List<ChatConversation> conversations;

  const ChatConversationsLoaded(this.conversations);
}

class ChatMessagesLoaded extends ChatState {
  final List<ChatMessage> messages;

  const ChatMessagesLoaded(this.messages);
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);
}

class ChatSocketConnected extends ChatState {}

class ChatSocketDisconnected extends ChatState {}
