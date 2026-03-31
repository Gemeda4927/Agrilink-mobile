import 'package:agrilink/core/network/api_constants.dart';
import 'package:agrilink/core/network/api_exception.dart';
import 'package:agrilink/core/network/dio_client.dart';
import 'package:agrilink/features/recommendation/data/model/chat_request_model.dart';
import 'package:agrilink/features/recommendation/data/model/chat_response_model.dart';
import 'package:dio/dio.dart';

class ChatService2 {
  final DioClient dioClient;

  ChatService2({required this.dioClient});

  Future<ChatResponseModel> sendMessage(ChatRequestModel request) async {
    try {
      final response = await dioClient.post(
        ApiConstants.cropAdvisorChat, // Updated URL
        data: request.toJson(),
      );

      final data = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ChatResponseModel.fromJson(data);
      } else {
        throw ApiException(
          message: data['message'] ?? "Something went wrong",
          statusCode: response.statusCode,
          type: ExceptionType.server,
        );
      }
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?['message'] ?? e.message ?? "Network error",
        statusCode: e.response?.statusCode,
        type: ExceptionType.network,
      );
    } catch (e) {
      throw ApiException(message: e.toString(), type: ExceptionType.network);
    }
  }
}
