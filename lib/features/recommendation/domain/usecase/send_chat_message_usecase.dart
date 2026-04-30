import 'package:agrilink/features/recommendation/data/model/chat_request_model.dart';

import '../../domain/entity/chat_message_entity.dart';
import '../../domain/entity/chat_response_entity.dart';
import '../../domain/entity/agent_breakdown_entity.dart';
import '../../domain/entity/source_entity.dart';

import '../repository/chat_repository.dart';

class SendChatMessageUseCase2 {
  final ChatRepository2 repository;

  SendChatMessageUseCase2(this.repository);

  Future<ChatResponseEntity> call(ChatMessageEntity message) async {
    final request = ChatRequestModel(
      message: message.message,
      location: message.location,
    );

    final response = await repository.sendMessage(request);

    return ChatResponseEntity(
      response: response.response,
      conversationId: response.conversationId,

      agentBreakdown: (response.agentBreakdown ?? [])
          .map(
            (e) => AgentBreakdownEntity(
              agentType: e["agent_type"] ?? "",
              response: e["response"] ?? "",
              confidence: (e["confidence"] ?? 0).toDouble(),
              sources: (e["sources"] ?? [])
                  .map<SourceEntity>(
                    (s) => SourceEntity(
                      type: s["type"] ?? "",
                      name: s["name"] ?? "",
                      provider: s["provider"] ?? "",
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),

      followUpQuestions: response.followUpQuestions ?? [],
    );
  }
}