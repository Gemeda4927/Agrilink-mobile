// chat_state.dart
import 'package:agrilink/features/chat/data/models/chat_model.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ConversationModel> conversations;

  ChatLoaded(this.conversations);
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);
}