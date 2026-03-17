import '../entities/chat_conversation.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  /// Fetch all conversations for the current user
  Future<List<ChatConversation>> fetchConversations();

  /// Fetch all messages for a given conversation
  Future<List<ChatMessage>> fetchMessages(String conversationId);

  /// Send a message via socket or REST fallback
  Future<bool> sendMessage({
    required String conversationId,
    required String senderId,
    required String message,
  });

  /// Socket connection functions
  void connectSocket(String token);
  void disconnectSocket();

  /// Check if socket is connected
  bool get isSocketConnected;
}