class MessageEntity {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isDelivered;
  final bool isSeen;
  final String conversationId;

  MessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isDelivered,
    required this.isSeen,
    required this.conversationId,
  });

  // ================= TO JSON =================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isDelivered': isDelivered,
      'isSeen': isSeen,
      'conversationId': conversationId,
    };
  }

  // ================= FROM JSON =================
  factory MessageEntity.fromJson(Map<String, dynamic> json) {
    return MessageEntity(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      isDelivered: json['isDelivered'] ?? false,
      isSeen: json['isSeen'] ?? false,
      conversationId: json['conversationId'] ?? '',
    );
  }
}
