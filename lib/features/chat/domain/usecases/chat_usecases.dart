import 'package:agrilink/features/chat/domain/entities/chat_message.dart';
import 'package:agrilink/features/chat/domain/repositories/chat_repository.dart';

import '../../domain/entities/chat_conversation.dart';

/// ===================== Fetch Conversations =====================
class FetchConversations {
  final ChatRepository repository;

  FetchConversations(this.repository);

  Future<List<ChatConversation>> call() async {
    return await repository.fetchConversations();
  }
}

/// ===================== Fetch Messages =====================
class FetchMessages {
  final ChatRepository repository;

  FetchMessages(this.repository);

  Future<List<ChatMessage>> call(String conversationId) async {
    return await repository.fetchMessages(conversationId);
  }
}

/// ===================== Send Message =====================
class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Future<void> call({
    required String conversationId,
    required String senderId,
    required String message,
  }) async {
    await repository.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      message: message,
    );
  }
}

/// ===================== Connect Socket =====================
class ConnectSocket {
  final ChatRepository repository;

  ConnectSocket(this.repository);

  void call(String token) {
    repository.connectSocket(token);
  }
}

/// ===================== Disconnect Socket =====================
class DisconnectSocket {
  final ChatRepository repository;

  DisconnectSocket(this.repository);

  void call() {
    repository.disconnectSocket();
  }
}
