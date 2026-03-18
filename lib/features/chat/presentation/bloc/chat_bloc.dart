import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrilink/features/chat/domain/usecases/chat_usecases.dart';
import 'package:agrilink/features/chat/domain/entities/chat_message.dart';
import 'package:agrilink/features/chat/domain/entities/chat_conversation.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FetchConversations fetchConversations;
  final FetchMessages fetchMessages;
  final SendMessage sendMessage;
  final ConnectSocket connectSocket;
  final DisconnectSocket disconnectSocket;

  ChatBloc({
    required this.fetchConversations,
    required this.fetchMessages,
    required this.sendMessage,
    required this.connectSocket,
    required this.disconnectSocket,
  }) : super(ChatInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<ReceiveMessageEvent>(_onReceiveMessage);
    on<ConnectSocketEvent>(_onConnectSocket);
    on<DisconnectSocketEvent>(_onDisconnectSocket);
  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final List<ChatConversation> conversations = await fetchConversations();
      emit(ChatConversationsLoaded(conversations));
    } catch (e) {
      emit(ChatError('Failed to load conversations: $e'));
    }
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final List<ChatMessage> messages = await fetchMessages(
        event.conversationId,
      );
      emit(ChatMessagesLoaded(messages));
    } catch (e) {
      emit(ChatError('Failed to load messages: $e'));
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await sendMessage(
        conversationId: event.conversationId,
        senderId: event.senderId,
        message: event.message,
      );

      // Reload messages after sending
      final messages = await fetchMessages(event.conversationId);
      emit(ChatMessagesLoaded(messages));
    } catch (e) {
      emit(ChatError('Failed to send message: $e'));
    }
  }

  void _onReceiveMessage(ReceiveMessageEvent event, Emitter<ChatState> emit) {
    if (state is ChatMessagesLoaded) {
      final currentMessages = (state as ChatMessagesLoaded).messages;
      final newMessage = ChatMessage.fromJson(event.messageData);
      emit(ChatMessagesLoaded([...currentMessages, newMessage]));
    }
  }

  void _onConnectSocket(ConnectSocketEvent event, Emitter<ChatState> emit) {
    connectSocket(event.token);
    emit(ChatSocketConnected());
  }

  void _onDisconnectSocket(
    DisconnectSocketEvent event,
    Emitter<ChatState> emit,
  ) {
    disconnectSocket();
    emit(ChatSocketDisconnected());
  }
}
