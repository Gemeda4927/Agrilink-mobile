import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

// Connection Events
class ConnectChat extends ChatEvent {
  final String userId;

  const ConnectChat({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class DisconnectChat extends ChatEvent {}

// Message Events
class SendChatMessage extends ChatEvent {
  final String senderId;
  final String receiverId;
  final String content;
  final String? tempId;
  final String? replyToId;

  const SendChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.tempId,
    this.replyToId,
  });

  @override
  List<Object?> get props => [senderId, receiverId, content, tempId];
}

class IncomingMessage extends ChatEvent {
  final Map<String, dynamic> message;

  const IncomingMessage(this.message);

  @override
  List<Object?> get props => [message];
}

// Message Status Events
class MessageSent extends ChatEvent {
  final Map<String, dynamic> data;

  const MessageSent(this.data);

  @override
  List<Object?> get props => [data];
}

class MessageDelivered extends ChatEvent {
  final Map<String, dynamic> data;

  const MessageDelivered(this.data);

  @override
  List<Object?> get props => [data];
}

class MessageRead extends ChatEvent {
  final Map<String, dynamic> data;

  const MessageRead(this.data);

  @override
  List<Object?> get props => [data];
}

// Typing Events
class SendTyping extends ChatEvent {
  final String receiverId;
  final bool isTyping;

  const SendTyping({required this.receiverId, required this.isTyping});

  @override
  List<Object?> get props => [receiverId, isTyping];
}

class UserTyping extends ChatEvent {
  final String userId;
  final bool isTyping;

  const UserTyping({required this.userId, required this.isTyping});

  @override
  List<Object?> get props => [userId, isTyping];
}

// Conversation Management Events
class SetCurrentConversation extends ChatEvent {
  final String conversationId;

  const SetCurrentConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class ClearCurrentConversation extends ChatEvent {}

class MarkConversationRead extends ChatEvent {
  final String conversationId;

  const MarkConversationRead(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

// Data Loading Events
class LoadChatHistory extends ChatEvent {
  final String conversationId;

  const LoadChatHistory(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class LoadConversations extends ChatEvent {}

// Error Events
class ChatErrorEvent extends ChatEvent {
  final String error;
  final String? type;

  const ChatErrorEvent({required this.error, this.type});

  @override
  List<Object?> get props => [error, type];
}
