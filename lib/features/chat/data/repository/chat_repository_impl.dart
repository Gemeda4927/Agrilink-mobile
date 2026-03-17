import 'package:agrilink/features/chat/data/models/conversation_model.dart';

import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/chat_message_model.dart';
import '../services/chat_service.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatService chatService;

  ChatRepositoryImpl({required this.chatService});

  @override
  Future<List<ChatConversation>> fetchConversations() async {
    final raw = await chatService.fetchConversations();
    return raw
        .map((e) => ChatConversationModel.fromJson(e).toEntity())
        .toList();
  }

  @override
  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    final raw = await chatService.fetchMessages(conversationId);
    return raw.map((e) => ChatMessageModel.fromJson(e).toEntity()).toList();
  }

  @override
  Future<bool> sendMessage({
    required String conversationId,
    required String senderId,
    required String message,
  }) async {
    try {
      if (chatService.isConnected) {
        chatService.sendMessageSocket(
          conversationId: conversationId,
          senderId: senderId,
          message: message,
        );
      } else {
        await chatService.sendMessageRest(
          conversationId: conversationId,
          senderId: senderId,
          message: message,
        );
      }
      return true;
    } catch (_) {
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
  bool get isSocketConnected => chatService.isConnected;
}
