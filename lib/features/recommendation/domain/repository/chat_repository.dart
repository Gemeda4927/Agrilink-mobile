import 'package:agrilink/features/recommendation/data/model/chat_request_model.dart';
import 'package:agrilink/features/recommendation/data/model/chat_response_model.dart';

abstract class ChatRepository2 {
  Future<ChatResponseModel> sendMessage(ChatRequestModel model);
}
