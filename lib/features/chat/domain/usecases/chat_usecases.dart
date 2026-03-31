

import 'package:agrilink/features/chat/data/models/chat_model.dart';
import 'package:agrilink/features/chat/domain/repositories/chat_repository.dart';

/// ================= GET CONVERSATIONS USE CASE =================
class GetConversationsUseCase {
  final ChatRepository repository;

  GetConversationsUseCase(this.repository);

  /// Call this to fetch all conversations
  Future<List<ConversationModel>> call() async {
    return repository.getConversations();
  }
}

/// ================= SEND MESSAGE USE CASE =================
/// Optional: UseCase if you want to wrap sending message logic
class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  void call({
    required String conversationId,
    required String senderId,
    required String message,
  }) {
    repository.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      message: message,
    );
  }
}

/// ================= LISTEN MESSAGES USE CASE =================
/// Optional: UseCase for real-time messages
class ListenMessagesUseCase {
  final ChatRepository repository;

  ListenMessagesUseCase(this.repository);

  void call(Function(dynamic data) callback) {
    repository.listenMessages(callback);
  }
}