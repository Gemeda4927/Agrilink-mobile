import 'package:agrilink/features/chat/domain/entities/chat_message.dart';
import 'package:agrilink/features/chat/domain/entities/chat_user.dart';

class ChatConversation {
  final String id;
  final String userOneId;
  final String userTwoId;
  final DateTime createdAt;
  final List<ChatMessage> messages;
  final User userOne;
  final User userTwo;

  ChatConversation({
    required this.id,
    required this.userOneId,
    required this.userTwoId,
    required this.createdAt,
    required this.messages,
    required this.userOne,
    required this.userTwo,
  });
}
