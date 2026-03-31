import 'package:agrilink/features/chat/data/models/chat_model.dart';
import 'package:agrilink/features/chat/data/services/chat_service.dart';
import 'package:agrilink/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatService service;

  ChatRepositoryImpl({required this.service});

  @override
  Future<List<ConversationModel>> getConversations() async {
    final response = await service.getConversations();
    final List data = response.data;

    return data.map((e) => ConversationModel.fromJson(e)).toList();
  }

  @override
  void connectSocket() {
    service.connectSocket();
  }

  @override
  void sendMessage({
    required String conversationId,
    required String senderId,
    required String message,
  }) {
    service.sendSocketMessage(
      conversationId: conversationId,
      senderId: senderId,
      message: message,
    );
  }

  @override
  void listenMessages(Function(dynamic data) callback) {
    service.onMessage(callback);
  }

  @override
  void disconnect() {
    service.disconnect();
  }
}