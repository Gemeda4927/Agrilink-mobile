import 'package:agrilink/features/chat/data/models/chat_conversation_model.dart';

import '../../domain/entities/chat_conversation.dart';
import 'chat_message_model.dart';

class ChatConversationModel {
  final String id;
  final String userOneId;
  final String userTwoId;
  final DateTime createdAt;
  final List<ChatMessageModel> messages;
  final UserModel userOne;
  final UserModel userTwo;

  ChatConversationModel({
    required this.id,
    required this.userOneId,
    required this.userTwoId,
    required this.createdAt,
    required this.messages,
    required this.userOne,
    required this.userTwo,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    return ChatConversationModel(
      id: json['id'],
      userOneId: json['userOneId'],
      userTwoId: json['userTwoId'],
      createdAt: DateTime.parse(json['createdAt']),
      messages: (json['messages'] as List)
          .map((e) => ChatMessageModel.fromJson(e))
          .toList(),
      userOne: UserModel.fromJson(json['userOne']),
      userTwo: UserModel.fromJson(json['userTwo']),
    );
  }

  ChatConversation toEntity() {
    return ChatConversation(
      id: id,
      userOneId: userOneId,
      userTwoId: userTwoId,
      createdAt: createdAt,
      messages: messages.map((e) => e.toEntity()).toList(),
      userOne: userOne.toEntity(),
      userTwo: userTwo.toEntity(),
    );
  }
}