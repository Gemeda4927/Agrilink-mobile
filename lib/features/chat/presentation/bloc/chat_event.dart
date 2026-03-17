abstract class ChatEvent {
  const ChatEvent();
}

class LoadConversations extends ChatEvent {}

class LoadMessages extends ChatEvent {
  final String conversationId;

  const LoadMessages(this.conversationId);
}

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

class ReceiveMessageEvent extends ChatEvent {
  final Map<String, dynamic> messageData;

  const ReceiveMessageEvent(this.messageData);
}

class ConnectSocketEvent extends ChatEvent {
  final String token;

  const ConnectSocketEvent(this.token);
}

class DisconnectSocketEvent extends ChatEvent {}
