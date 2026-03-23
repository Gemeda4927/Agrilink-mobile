import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/chat_usecases.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FetchConversations fetchConversations;
  final FetchMessages fetchMessages;
  final SendMessage sendMessage;
  final ConnectSocket connectSocket;
  final DisconnectSocket disconnectSocket;
  final JoinConversation joinConversation;
  final ListenForMessages listenForMessages;
  final GetOrCreateConversation getOrCreateConversation; // ✅ ADD THIS

  ChatBloc({
    required this.fetchConversations,
    required this.fetchMessages,
    required this.sendMessage,
    required this.connectSocket,
    required this.disconnectSocket,
    required this.joinConversation,
    required this.listenForMessages,
    required this.getOrCreateConversation, // ✅ ADD THIS
  }) : super(ChatInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<MessageReceivedEvent>(_onMessageReceived);
    on<ConnectSocketEvent>(_onConnectSocket);
    on<DisconnectSocketEvent>(_onDisconnectSocket);
    on<JoinConversationEvent>(_onJoinConversation);
    on<GetOrCreateConversationEvent>(_onGetOrCreateConversation); // ✅ ADD THIS
  }

  /// ================= GET OR CREATE CONVERSATION =================

  Future<void> _onGetOrCreateConversation(
    GetOrCreateConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      print('🔄 Getting or creating conversation...');

      final conversation = await getOrCreateConversation(
        userOneId: event.userOneId,
        userTwoId: event.userTwoId,
        receiverName: event.receiverName, // Pass receiverName
      );

      print('✅ Conversation ready: ${conversation.id}');
      emit(ChatConversationFound(conversation));
    } catch (e) {
      print('❌ Error: $e');
      emit(ChatError("Failed to get or create conversation: $e"));
    }
  }

  /// ================= JOIN CONVERSATION =================
  Future<void> _onJoinConversation(
    JoinConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      joinConversation(event.conversationId);
    } catch (e) {
      emit(ChatError("Failed to join conversation: $e"));
    }
  }

  /// ================= LOAD CONVERSATIONS =================
  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final conversations = await fetchConversations();
      emit(ChatConversationsLoaded(conversations));
    } catch (e) {
      emit(ChatError('Failed to load conversations: $e'));
    }
  }

  /// ================= LOAD MESSAGES =================
  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final messages = await fetchMessages(event.conversationId);
      emit(ChatMessagesLoaded(messages));
    } catch (e) {
      emit(ChatError('Failed to load messages: $e'));
    }
  }

  /// ================= SEND MESSAGE =================
  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final tempMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: event.conversationId,
        senderId: event.senderId,
        message: event.message,
        createdAt: DateTime.now(),
      );

      emit(ChatMessageSent(tempMessage));

      final success = await sendMessage(
        conversationId: event.conversationId,
        senderId: event.senderId,
        message: event.message,
      );

      if (success) {
        final messages = await fetchMessages(event.conversationId);
        emit(ChatMessagesLoaded(messages));
      } else {
        emit(ChatError('Failed to send message'));
      }
    } catch (e) {
      emit(ChatError('Failed to send message: $e'));
    }
  }

  /// ================= RECEIVE MESSAGE =================
  void _onMessageReceived(MessageReceivedEvent event, Emitter<ChatState> emit) {
    if (state is ChatMessagesLoaded) {
      final current = state as ChatMessagesLoaded;
      emit(ChatMessagesLoaded([...current.messages, event.message]));
    } else {
      emit(ChatMessageReceived(event.message));
    }
  }

  /// ================= CONNECT SOCKET =================
  Future<void> _onConnectSocket(
    ConnectSocketEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await connectSocket(event.token);
      emit(ChatSocketConnected());

      listenForMessages((message) {
        add(MessageReceivedEvent(message));
      });
    } catch (e) {
      emit(ChatConnectionError('Failed to connect socket: $e'));
    }
  }

  /// ================= DISCONNECT =================
  void _onDisconnectSocket(
    DisconnectSocketEvent event,
    Emitter<ChatState> emit,
  ) {
    try {
      disconnectSocket();
      emit(ChatSocketDisconnected());
    } catch (e) {
      emit(ChatConnectionError('Failed to disconnect socket: $e'));
    }
  }
}
