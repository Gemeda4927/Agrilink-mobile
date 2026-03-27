import 'agent_breakdown_entity.dart';

class ChatResponseEntity {
  final String response;
  final String conversationId;
  final List<AgentBreakdownEntity> agentBreakdown;
  final List<String> followUpQuestions;

  ChatResponseEntity({
    required this.response,
    required this.conversationId,
    required this.agentBreakdown,
    required this.followUpQuestions,
  });
}