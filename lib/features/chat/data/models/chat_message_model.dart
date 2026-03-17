import '../../domain/entities/chat_message.dart';

class ChatMessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String message;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  ChatMessage toEntity() {
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      message: message,
      createdAt: createdAt,
    );
  }
}