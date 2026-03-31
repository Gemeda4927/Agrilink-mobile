import 'package:agrilink/features/chat/data/models/chat_model.dart';

abstract class ChatRepository {
  Future<List<ConversationModel>> getConversations();

  void connectSocket();

  void sendMessage({
    required String conversationId,
    required String senderId,
    required String message,
  });

  void listenMessages(Function(dynamic data) callback);

  void disconnect();
}
