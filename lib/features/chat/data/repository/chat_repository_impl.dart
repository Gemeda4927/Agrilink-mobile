import 'package:agrilink/features/chat/data/models/chat_conversation_model.dart';
import 'package:agrilink/features/chat/data/models/chat_message_model.dart';
import 'package:agrilink/features/chat/data/services/chat_service.dart';
import 'package:agrilink/features/chat/domain/entities/chat_conversation.dart';
import 'package:agrilink/features/chat/domain/entities/chat_message.dart';
import 'package:agrilink/features/chat/domain/repositories/chat_repository.dart';

import '../../domain/entities/chat_user.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatService chatService;

  ChatRepositoryImpl({required this.chatService});

  @override
  Future<List<ChatConversation>> fetchConversations() async {
    try {
      final raw = await chatService.fetchConversations();
      return raw
          .map((e) => ChatConversationModel.fromJson(e).toEntity())
          .toList();
    } catch (e) {
      print("❌ Error fetching conversations: $e");
      return [];
    }
  }

  @override
  Future<ChatConversation> getOrCreateConversation({
    required String userOneId,
    required String userTwoId,
    String? receiverName,
  }) async {
    try {
      print('🔍 Looking for conversation between $userOneId and $userTwoId');

      // Check for existing conversation
      final existing = await chatService.findConversationBetweenUsers(
        userOneId: userOneId,
        userTwoId: userTwoId,
      );

      if (existing != null) {
        print('✅ Found existing conversation: ${existing['id']}');
        return ChatConversationModel.fromJson(existing).toEntity();
      }

      print('⚠️ No existing conversation, creating temporary one');

      // Create temporary conversation
      return ChatConversation(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        userOneId: userOneId,
        userTwoId: userTwoId,
        createdAt: DateTime.now(),
        userOne: User(id: userOneId, email: '', fullName: null, phone: null),
        userTwo: User(
          id: userTwoId,
          email: '',
          fullName: receiverName,
          phone: null,
        ),
        messages: [],
        lastMessage: null,
        lastMessageTime: null,
      );
    } catch (e) {
      print("❌ Error: $e");
      throw Exception("Failed to get or create conversation: $e");
    }
  }

  @override
  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    try {
      if (conversationId.startsWith('temp_')) {
        return [];
      }

      final raw = await chatService.getMessagesFromConversation(conversationId);
      return raw.map((e) => ChatMessageModel.fromJson(e).toEntity()).toList();
    } catch (e) {
      print("❌ Error fetching messages: $e");
      return [];
    }
  }

  @override
  Future<bool> sendMessage({
    required String conversationId,
    required String senderId,
    required String message,
  }) async {
    try {
      if (!chatService.isConnected) {
        print("❌ Socket not connected");
        return false;
      }

      print('📤 Sending message to: $conversationId');
      chatService.sendMessageSocket(
        conversationId: conversationId,
        senderId: senderId,
        message: message,
      );

      return true;
    } catch (e) {
      print("❌ Error sending message: $e");
      return false;
    }
  }

  @override
  void connectSocket(String token) {
    chatService.connectSocket(token);
  }

  @override
  void disconnectSocket() {
    chatService.disconnectSocket();
  }

  @override
  void joinConversation(String conversationId) {
    if (!conversationId.startsWith('temp_')) {
      chatService.joinConversation(conversationId);
    }
  }

  @override
  void listenForMessages(Function(ChatMessage) onMessage) {
    chatService.listenMessagesSocket((data) {
      final message = ChatMessageModel.fromJson(data).toEntity();
      onMessage(message);
    });
  }

  @override
  bool get isSocketConnected => chatService.isConnected;
}
