
import '../entities/chat_conversation.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  // REST Methods
  Future<List<ChatConversation>> fetchConversations();
  Future<List<ChatMessage>> fetchMessages(String conversationId);
  
  // Conversation Management
  Future<ChatConversation> getOrCreateConversation({
    required String userOneId,
    required String userTwoId,
    String? receiverName, // Add this
  });
  
  // Socket Methods
  void connectSocket(String token);
  void disconnectSocket();
  bool get isSocketConnected;
  void joinConversation(String conversationId);
  void listenForMessages(Function(ChatMessage) onMessage);
  
  // Send Message
  Future<bool> sendMessage({
    required String conversationId,
    required String senderId,
    required String message,
  });
}