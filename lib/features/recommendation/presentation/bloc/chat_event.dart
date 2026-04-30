abstract class ChatEvent2 {
  const ChatEvent2();
}

class SendMessageEvent extends ChatEvent2 {
  final String message;

  const SendMessageEvent({required this.message});
}

class ClearChatEvent extends ChatEvent2 {}

class RetryLastMessageEvent extends ChatEvent2 {
  final String message;

  const RetryLastMessageEvent({required this.message});
}