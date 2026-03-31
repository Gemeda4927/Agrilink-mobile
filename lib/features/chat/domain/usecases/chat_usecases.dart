import '../repositories/chat_repository.dart';

class ChatUseCases {
  final ChatRepository repository;

  ChatUseCases(this.repository);

  // ================= SOCKET CONNECTION =================
  void connect(String userId) {
    repository.connect(userId);
  }

  void disconnect() {
    repository.disconnect();
  }

  // ================= MESSAGE SENDING =================
  void sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String? tempId,
  }) {
    repository.sendMessage(
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      tempId: tempId,
    );
  }

  // ================= CONVERSATION MANAGEMENT =================
  void setCurrentConversation(String conversationId) {
    repository.setCurrentConversation(conversationId);
  }

  void clearCurrentConversation() {
    repository.clearCurrentConversation();
  }

  void markConversationAsRead(String conversationId) {
    repository.markConversationAsRead(conversationId);
  }

  void markMessageAsRead(String messageId, String conversationId) {
    repository.markMessageAsRead(messageId, conversationId);
  }

  void markMessageAsDelivered(String messageId, String receiverId) {
    repository.markMessageAsDelivered(messageId, receiverId);
  }

  // ================= TYPING INDICATOR =================
  void sendTyping(String receiverId, bool isTyping) {
    repository.sendTyping(receiverId, isTyping);
  }

  // ================= MESSAGE TRACKING =================
  void trackMessage(String messageId) {
    repository.trackMessage(messageId);
  }

  // ================= STREAMS =================
  Stream<Map<String, dynamic>> get messages => repository.messages;
  Stream<Map<String, dynamic>> get messageSent => repository.messageSent;
  Stream<Map<String, dynamic>> get messageDelivered =>
      repository.messageDelivered;
  Stream<Map<String, dynamic>> get messageRead => repository.messageRead;
  Stream<Map<String, dynamic>> get errors => repository.errors;
  Stream<Map<String, dynamic>> get typing => repository.typing;
  Stream<bool> get connectionStatus => repository.connectionStatus;

  // ================= DATA FETCHING =================
  Future<List<dynamic>> getConversations() {
    return repository.getConversations();
  }

  Future<List<dynamic>> getMessages(String conversationId) {
    return repository.getMessages(conversationId);
  }

  // ================= STATUS GETTERS =================
  bool get isConnected => repository.isConnected;
  String? get socketId => repository.socketId;
}
