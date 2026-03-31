// In your domain/repositories/chat_repository.dart
import 'dart:async';

abstract class ChatRepository {
  // Connection methods
  void connect(String userId);
  void disconnect();
  
  // Message methods
  void sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String? tempId,
  });
  
  // Conversation management
  void setCurrentConversation(String conversationId);
  void clearCurrentConversation();
  void markConversationAsRead(String conversationId);
  void markMessageAsRead(String messageId, String conversationId);
  void markMessageAsDelivered(String messageId, String receiverId);
  
  // Typing indicator
  void sendTyping(String receiverId, bool isTyping);
  
  // Track message
  void trackMessage(String messageId);
  
  // Streams
  Stream<Map<String, dynamic>> get messages;
  Stream<Map<String, dynamic>> get messageSent;
  Stream<Map<String, dynamic>> get messageDelivered;
  Stream<Map<String, dynamic>> get messageRead;
  Stream<Map<String, dynamic>> get errors;
  Stream<Map<String, dynamic>> get typing;
  Stream<bool> get connectionStatus;
  
  // Data fetching
  Future<List<dynamic>> getConversations();
  Future<List<dynamic>> getMessages(String conversationId);
  
  // Status getters
  bool get isConnected;
  String? get socketId;
}