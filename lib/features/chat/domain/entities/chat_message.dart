class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String message;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    required this.createdAt,
  });

  // Factory to convert Map to entity
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}