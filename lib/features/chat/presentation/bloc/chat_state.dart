import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';

abstract class ChatState {
  const ChatState();
}

/// ================= INITIAL =================
class ChatInitial extends ChatState {}

/// ================= LOADING =================
class ChatLoading extends ChatState {}

/// ================= DATA =================
class ChatConversationsLoaded extends ChatState {
  final List<ChatConversation> conversations;

  const ChatConversationsLoaded(this.conversations);
}

class ChatMessagesLoaded extends ChatState {
  final List<ChatMessage> messages;

  const ChatMessagesLoaded(this.messages);
}

class ChatConversationFound extends ChatState {
  final ChatConversation conversation;

  const ChatConversationFound(this.conversation);
}

class ChatConversationCreated extends ChatState {
  final ChatConversation conversation;

  const ChatConversationCreated(this.conversation);
}

/// ================= MESSAGE EVENTS =================
class ChatMessageSent extends ChatState {
  final ChatMessage message;

  const ChatMessageSent(this.message);
}

class ChatMessageReceived extends ChatState {
  final ChatMessage message;

  const ChatMessageReceived(this.message);
}

/// ================= SOCKET =================
class ChatSocketConnected extends ChatState {}

class ChatSocketDisconnected extends ChatState {}

class ChatConnectionError extends ChatState {
  final String message;

  const ChatConnectionError(this.message);
}

/// ================= ERROR =================
class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);
}