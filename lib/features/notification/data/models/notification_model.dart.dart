import '../../domain/entities/notification.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final bool isSent;
  final bool markAsRead;  
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.isSent,
    required this.markAsRead,  
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'UNKNOWN',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isSent: json['isSent'] ?? false,
      markAsRead: json['markAsRead'] ?? false,  // ✅ Use correct field name
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'isSent': isSent,
      'markAsRead': markAsRead,  // ✅ Updated
      'createdAt': createdAt.toIso8601String(),
    };
  }

  NotificationEntity toEntity({required bool isRead}) {
    return NotificationEntity(
      id: id,
      userId: userId,
      type: NotificationType.fromString(type),
      title: title,
      message: message,
      isSent: isSent,
      isRead: markAsRead,  // ✅ Map markAsRead to isRead in entity
      createdAt: createdAt,
    );
  }
}