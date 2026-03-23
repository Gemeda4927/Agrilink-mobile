import 'chat_message.dart';
import 'chat_user.dart';

class ChatConversation {
  final String id;
  final String userOneId;
  final String userTwoId;
  final DateTime createdAt;
  final User userOne;
  final User userTwo;
  final List<ChatMessage> messages;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  ChatConversation({
    required this.id,
    required this.userOneId,
    required this.userTwoId,
    required this.createdAt,
    required this.userOne,
    required this.userTwo,
    required this.messages,
    this.lastMessage,
    this.lastMessageTime,
  });

  /// Helper method to get the other participant
  User getOtherParticipant(String currentUserId) {
    return currentUserId == userOneId ? userTwo : userOne;
  }

  /// Helper method to get the participant name
  String getParticipantName(String currentUserId) {
    final otherUser = getOtherParticipant(currentUserId);
    return otherUser.fullName ?? otherUser.email;
  }
}
