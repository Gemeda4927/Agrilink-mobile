// chat_bloc.dart
import 'package:agrilink/features/chat/presentation/bloc/chat_event.dart';
import 'package:agrilink/features/chat/presentation/bloc/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/chat_model.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;

  ChatBloc({required this.repository}) : super(ChatInitial()) {
    on<LoadConversationsEvent>(_onLoad);
    on<SendMessageEvent>(_onSend);
    on<ListenMessagesEvent>(_onListen);
    on<NewMessageEvent>(_onNewMessage);
  }

  Future<void> _onLoad(
    LoadConversationsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());

    try {
      final data = await repository.getConversations();
      emit(ChatLoaded(data));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onSend(SendMessageEvent event, Emitter<ChatState> emit) {
    repository.sendMessage(
      conversationId: event.conversationId,
      senderId: event.senderId,
      message: event.message,
    );
  }

  void _onListen(ListenMessagesEvent event, Emitter<ChatState> emit) {
    repository.connectSocket();
    repository.listenMessages((data) {
      final message = MessageModel.fromJson(data);
      add(NewMessageEvent(message));
    });
  }

  void _onNewMessage(NewMessageEvent event, Emitter<ChatState> emit) {
    if (state is ChatLoaded) {
      final current = (state as ChatLoaded).conversations;

      final updated = current.map((conv) {
        if (conv.id == event.message.conversationId) {
          return conv.copyWith(
            messages: [...conv.messages, event.message]
          );
        }
        return conv;
      }).toList();

      emit(ChatLoaded(updated));
    }
  }

  @override
  Future<void> close() {
    repository.disconnect();
    return super.close();
  }
}