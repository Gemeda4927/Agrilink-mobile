import 'package:agrilink/core/network/api_constants.dart';
import '../../domain/repositories/chat_repository.dart';
import '../services/chat_service.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatService chatService;

  ChatRepositoryImpl({required this.chatService});

  // ================= CONNECT =================
  @override
  void connect(String userId) {
    chatService.connect(baseUrl: ApiConstants.baseUrl, userId: userId);
  }

  // ================= DISCONNECT =================
  @override
  void disconnect() {
    chatService.disconnect();
  }

  // ================= SEND MESSAGE =================
  @override
  void sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String? tempId,
  }) {
    chatService.sendMessage(
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      tempId: tempId,
    );
  }

  // ================= SET CURRENT CONVERSATION =================
  @override
  void setCurrentConversation(String conversationId) {
    chatService.setCurrentConversation(conversationId);
  }

  // ================= CLEAR CURRENT CONVERSATION =================
  @override
  void clearCurrentConversation() {
    chatService.clearCurrentConversation();
  }

  // ================= MARK CONVERSATION AS READ =================
  @override
  void markConversationAsRead(String conversationId) {
    chatService.markConversationAsRead(conversationId);
  }

  // ================= MARK MESSAGE AS READ =================
  @override
  void markMessageAsRead(String messageId, String conversationId) {
    chatService.markAsRead(messageId, conversationId);
  }

  // ================= MARK MESSAGE AS DELIVERED =================
  @override
  void markMessageAsDelivered(String messageId, String receiverId) {
    chatService.markAsDelivered(messageId, receiverId);
  }

  // ================= SEND TYPING INDICATOR =================
  @override
  void sendTyping(String receiverId, bool isTyping) {
    chatService.sendTyping(receiverId, isTyping);
  }

  // ================= TRACK MESSAGE STATUS =================
  @override
  void trackMessage(String messageId) {
    chatService.trackMessage(messageId);
  }

  // ================= STREAMS =================
  @override
  Stream<Map<String, dynamic>> get messages => chatService.messages;

  @override
  Stream<Map<String, dynamic>> get messageSent => chatService.messageSent;

  @override
  Stream<Map<String, dynamic>> get messageDelivered => chatService.messageDelivered;

  @override
  Stream<Map<String, dynamic>> get messageRead => chatService.messageRead;

  @override
  Stream<Map<String, dynamic>> get errors => chatService.errors;

  @override
  Stream<Map<String, dynamic>> get typing => chatService.typing;

  @override
  Stream<bool> get connectionStatus => chatService.connectionStatus;

  // ================= GET CONVERSATIONS =================
  @override
  Future<List<dynamic>> getConversations() {
    return chatService.fetchConversations();
  }

  // ================= GET MESSAGES =================
  @override
  Future<List<dynamic>> getMessages(String conversationId) {
    return chatService.fetchMessages(conversationId);
  }

  // ================= CONNECTION STATUS =================
  @override
  bool get isConnected => chatService.isConnected;

  @override
  String? get socketId => chatService.socketId;
}