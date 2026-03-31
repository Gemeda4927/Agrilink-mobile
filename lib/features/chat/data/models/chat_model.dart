class ChatConversationModel {
  final String id;
  final String userOneId;
  final String userTwoId;
  final DateTime createdAt;
  final List<ChatMessageModel> messages;

  ChatConversationModel({
    required this.id,
    required this.userOneId,
    required this.userTwoId,
    required this.createdAt,
    required this.messages,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    return ChatConversationModel(
      id: json["id"],
      userOneId: json["userOneId"],
      userTwoId: json["userTwoId"],
      createdAt: DateTime.parse(json["createdAt"]),
      messages: (json["messages"] as List? ?? [])
          .map((e) => ChatMessageModel.fromJson(e))
          .toList(),
    );
  }
}

class ChatMessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String message;
  final DateTime createdAt;
  String status; // Add this for message status
  final bool? isPending;
  final String? tempId;

  ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    required this.createdAt,
    this.status = 'sent',
    this.isPending,
    this.tempId,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json["id"],
      conversationId: json["conversationId"],
      senderId: json["senderId"],
      message: json["message"],
      createdAt: DateTime.parse(json["createdAt"]),
      status: json["status"] ?? 'sent',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "conversationId": conversationId,
      "senderId": senderId,
      "message": message,
      "createdAt": createdAt.toIso8601String(),
      "status": status,
    };
  }
}
