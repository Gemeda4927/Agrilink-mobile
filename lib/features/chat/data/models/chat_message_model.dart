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

  /// Convert JSON to Model
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// Convert Model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert Model to Domain Entity
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