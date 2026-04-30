import 'package:agrilink/features/recommendation/domain/entity/chat_response_entity.dart';

class ChatMessageEntity {
  final String message;
  final String? location;

  ChatMessageEntity({required this.message, this.location});
}

class ChatMessage {
  final bool isUser;
  final String text;
  final DateTime timestamp;
  final bool isError;
  final ChatResponseEntity? responseEntity;
  final Map<String, dynamic>? errorInfo;

  ChatMessage({
    required this.isUser,
    required this.text,
    required this.timestamp,
    this.isError = false,
    this.responseEntity,
    this.errorInfo,
  });
}