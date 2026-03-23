// lib/features/chat/presentation/bloc/chat_event.dart

import '../../domain/entities/chat_message.dart';

abstract class ChatEvent {
  const ChatEvent();
}

/// ================= LOAD =================
class LoadConversations extends ChatEvent {}

class LoadMessages extends ChatEvent {
  final String conversationId;

  const LoadMessages(this.conversationId);
}

/// ================= SEND =================
class SendMessageEvent extends ChatEvent {
  final String conversationId;
  final String senderId;
  final String message;

  const SendMessageEvent({
    required this.conversationId,
    required this.senderId,
    required this.message,
  });
}

/// ================= CONVERSATION =================
class GetOrCreateConversationEvent extends ChatEvent {
  final String userOneId;
  final String userTwoId;
  final String? receiverName; // Add this

  const GetOrCreateConversationEvent({
    required this.userOneId,
    required this.userTwoId,
    this.receiverName,
  });
}

/// ================= SOCKET =================
class ConnectSocketEvent extends ChatEvent {
  final String token;

  const ConnectSocketEvent(this.token);
}

class DisconnectSocketEvent extends ChatEvent {}

/// ================= REAL-TIME =================
class MessageReceivedEvent extends ChatEvent {
  final ChatMessage message;

  const MessageReceivedEvent(this.message);
}

/// ================= JOIN ROOM =================
class JoinConversationEvent extends ChatEvent {
  final String conversationId;

  const JoinConversationEvent(this.conversationId);
}