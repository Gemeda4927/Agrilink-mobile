class ChatResponseModel {
  final String response;
  final String conversationId;
  final List<dynamic>? agentBreakdown;
  final List<String>? followUpQuestions;

  ChatResponseModel({
    required this.response,
    required this.conversationId,
    this.agentBreakdown,
    this.followUpQuestions,
  });

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatResponseModel(
      response: json["response"] ?? "",
      conversationId: json["conversation_id"] ?? "",
      agentBreakdown: json["agent_breakdown"],
      followUpQuestions: List<String>.from(json["follow_up_questions"] ?? []),
    );
  }
}