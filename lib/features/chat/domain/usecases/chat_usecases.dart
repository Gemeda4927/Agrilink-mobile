import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/repositories/chat_repository.dart';
import '../entities/chat_user.dart';

/// ===================== FETCH CONVERSATIONS =====================
class FetchConversations {
  final ChatRepository repository;

  FetchConversations(this.repository);

  Future<List<ChatConversation>> call() {
    return repository.fetchConversations();
  }
}

/// ===================== FETCH MESSAGES =====================
class FetchMessages {
  final ChatRepository repository;

  FetchMessages(this.repository);

  Future<List<ChatMessage>> call(String conversationId) {
    return repository.fetchMessages(conversationId);
  }
}

/// ===================== SEND MESSAGE =====================
class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Future<bool> call({
    required String conversationId,
    required String senderId,
    required String message,
  }) {
    return repository.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      message: message,
    );
  }
}

/// ===================== CONNECT SOCKET =====================
class ConnectSocket {
  final ChatRepository repository;

  ConnectSocket(this.repository);

  Future<void> call(String token) async {
    repository.connectSocket(token);
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

/// ===================== DISCONNECT SOCKET =====================
class DisconnectSocket {
  final ChatRepository repository;

  DisconnectSocket(this.repository);

  void call() {
    repository.disconnectSocket();
  }
}

/// ===================== JOIN CONVERSATION =====================
class JoinConversation {
  final ChatRepository repository;

  JoinConversation(this.repository);

  void call(String conversationId) {
    repository.joinConversation(conversationId);
  }
}

/// ===================== LISTEN MESSAGES =====================
class ListenForMessages {
  final ChatRepository repository;

  ListenForMessages(this.repository);

  void call(Function(ChatMessage) onMessage) {
    repository.listenForMessages(onMessage);
  }
}

class GetOrCreateConversation {
  final ChatRepository repository;

  GetOrCreateConversation(this.repository);

  Future<ChatConversation> call({
    required String userOneId,
    required String userTwoId,
    String? receiverName,
  }) async {
    print('🔍 Looking for conversation between $userOneId and $userTwoId');

    // Fetch all conversations
    final conversations = await repository.fetchConversations();

    // Find existing conversation
    for (final conversation in conversations) {
      if ((conversation.userOneId == userOneId &&
              conversation.userTwoId == userTwoId) ||
          (conversation.userOneId == userTwoId &&
              conversation.userTwoId == userOneId)) {
        print('✅ Found existing conversation: ${conversation.id}');
        return conversation;
      }
    }

    // No existing conversation, create temporary one
    print('⚠️ No existing conversation, creating temporary');

    // Get user details if available
    User? userOne;
    User? userTwo;

    for (final conversation in conversations) {
      if (conversation.userOneId == userOneId) userOne = conversation.userOne;
      if (conversation.userTwoId == userOneId) userOne = conversation.userTwo;
      if (conversation.userOneId == userTwoId) userTwo = conversation.userOne;
      if (conversation.userTwoId == userTwoId) userTwo = conversation.userTwo;
    }

    return ChatConversation(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      userOneId: userOneId,
      userTwoId: userTwoId,
      createdAt: DateTime.now(),
      userOne:
          userOne ??
          User(id: userOneId, email: '', fullName: null, phone: null),
      userTwo:
          userTwo ??
          User(id: userTwoId, email: '', fullName: receiverName, phone: null),
      messages: [],
      lastMessage: null,
      lastMessageTime: null,
    );
  }
}
