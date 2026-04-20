part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class InitializeNotifications extends NotificationEvent {}

class NotificationReceived extends NotificationEvent {
  final NotificationItem notification;

  const NotificationReceived(this.notification);

  @override
  List<Object?> get props => [notification];
}

class MarkNotificationAsRead extends NotificationEvent {
  final String id;

  const MarkNotificationAsRead(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearAllNotifications extends NotificationEvent {}

class SubscribeToTopic extends NotificationEvent {
  final String topic;

  const SubscribeToTopic(this.topic);

  @override
  List<Object?> get props => [topic];
}

class UnsubscribeFromTopic extends NotificationEvent {
  final String topic;

  const UnsubscribeFromTopic(this.topic);

  @override
  List<Object?> get props => [topic];
}