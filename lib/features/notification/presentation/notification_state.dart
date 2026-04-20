part of 'notification_bloc.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationItem> notifications;

  const NotificationLoaded({required this.notifications});

  @override
  List<Object?> get props => [notifications];
}

class NotificationItem extends Equatable {
  final String id;
  final String title;
  final String body;
  final String? type;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.type,
    this.imageUrl,
    required this.data,
    required this.timestamp,
    this.isRead = false,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title'] ?? 'AgriLink',
      body: map['body'] ?? map['message'] ?? '',
      type: map['type'],
      imageUrl: map['image_url'],
      data: map,
      timestamp: DateTime.now(),
      isRead: false,
    );
  }

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    String? imageUrl,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    type,
    imageUrl,
    data,
    timestamp,
    isRead,
  ];
}
