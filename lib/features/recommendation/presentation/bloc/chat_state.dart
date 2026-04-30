import 'package:agrilink/features/recommendation/domain/entity/chat_response_entity.dart';

abstract class ChatState2 {
  const ChatState2();
}

class ChatInitial extends ChatState2 {}

class ChatLoading extends ChatState2 {}

class ChatLoaded extends ChatState2 {
  final ChatResponseEntity response;

  const ChatLoaded({required this.response});
}

class ChatError extends ChatState2 {
  final String message;

  const ChatError({required this.message});
}