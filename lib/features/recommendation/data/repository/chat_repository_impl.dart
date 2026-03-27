import 'package:agrilink/features/recommendation/data/service/chat_service.dart';

import '../../domain/repository/chat_repository.dart';
import '../model/chat_request_model.dart';
import '../model/chat_response_model.dart';

class ChatRepositoryImpl2 implements ChatRepository2 {
  final ChatService2 service;

  ChatRepositoryImpl2({required this.service});

  @override
  Future<ChatResponseModel> sendMessage(ChatRequestModel model) {
    return service.sendMessage(model);
  }
}