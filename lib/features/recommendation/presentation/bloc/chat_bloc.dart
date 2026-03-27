import 'package:bloc/bloc.dart';
import 'package:agrilink/features/recommendation/domain/usecase/send_chat_message_usecase.dart';
import 'package:agrilink/features/recommendation/domain/entity/chat_message_entity.dart';
import 'package:agrilink/features/recommendation/presentation/bloc/chat_event.dart';
import 'package:agrilink/features/recommendation/presentation/bloc/chat_state.dart';

class ChatBloc2 extends Bloc<ChatEvent2, ChatState2> {
  final SendChatMessageUseCase2 sendMessageUseCase;
  
  ChatBloc2({required this.sendMessageUseCase}) : super(ChatInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<ClearChatEvent>(_onClearChat);
    on<RetryLastMessageEvent>(_onRetryLastMessage);
  }
  
  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState2> emit,
  ) async {
    emit(ChatLoading());
    
    try {
      // Create ChatMessageEntity
      final chatMessage = ChatMessageEntity(
        message: event.message,
        location: null, // Add location if needed
      );
      
      // ✅ Call the use case using call() method
      final response = await sendMessageUseCase(chatMessage);
      
      emit(ChatLoaded(response: response));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }
  
  void _onClearChat(
    ClearChatEvent event,
    Emitter<ChatState2> emit,
  ) {
    emit(ChatInitial());
  }
  
  Future<void> _onRetryLastMessage(
    RetryLastMessageEvent event,
    Emitter<ChatState2> emit,
  ) async {
    if (event.message.isNotEmpty) {
      emit(ChatLoading());
      
      try {
        final chatMessage = ChatMessageEntity(
          message: event.message,
          location: null,
        );
        
        final response = await sendMessageUseCase(chatMessage);
        
        emit(ChatLoaded(response: response));
      } catch (e) {
        emit(ChatError(message: e.toString()));
      }
    }
  }
}