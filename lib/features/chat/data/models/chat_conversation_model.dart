import 'package:agrilink/features/chat/domain/entities/chat_conversation.dart';
import 'package:agrilink/features/chat/domain/entities/chat_message.dart';
import 'package:agrilink/features/chat/domain/entities/chat_user.dart';

import 'chat_message_model.dart';
import 'chat_user.dart';

class ChatConversationModel {
  final String id;
  final String userOneId;
  final String userTwoId;
  final DateTime createdAt;
  final ChatUserModel userOne;
  final ChatUserModel userTwo;
  final List<ChatMessageModel> messages;

  ChatConversationModel({
    required this.id,
    required this.userOneId,
    required this.userTwoId,
    required this.createdAt,
    required this.userOne,
    required this.userTwo,
    required this.messages,
  });

  /// Convert JSON to Model
  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    return ChatConversationModel(
      id: json['id'] ?? '',
      userOneId: json['userOneId'] ?? '',
      userTwoId: json['userTwoId'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      userOne: ChatUserModel.fromJson(json['userOne'] ?? {}),
      userTwo: ChatUserModel.fromJson(json['userTwo'] ?? {}),
      messages: (json['messages'] as List? ?? [])
          .map((m) => ChatMessageModel.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convert Model to Domain Entity
  ChatConversation toEntity() {
    final userOneEntity = User(
      id: userOne.id,
      phone: userOne.phone,
      email: userOne.email,
      fullName: userOne.fullName,
    );

    final userTwoEntity = User(
      id: userTwo.id,
      phone: userTwo.phone,
      email: userTwo.email,
      fullName: userTwo.fullName,
    );

    final messageEntities = messages.map((m) {
      return ChatMessage(
        id: m.id,
        conversationId: m.conversationId,
        senderId: m.senderId,
        message: m.message,
        createdAt: m.createdAt,
      );
    }).toList();

    return ChatConversation(
      id: id,
      userOneId: userOneId,
      userTwoId: userTwoId,
      createdAt: createdAt,
      userOne: userOneEntity,
      userTwo: userTwoEntity,
      messages: messageEntities,
      lastMessage: messages.isNotEmpty ? messages.last.message : null,
      lastMessageTime: messages.isNotEmpty ? messages.last.createdAt : null,
    );
  }
}
