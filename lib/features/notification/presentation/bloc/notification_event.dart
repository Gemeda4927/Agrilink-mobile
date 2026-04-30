part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class InitializeNotifications extends NotificationEvent {}

class LoadNotificationsFromApi extends NotificationEvent {}  
class LoadNotifications extends NotificationEvent {}

class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;
  
  const MarkNotificationAsRead(this.notificationId); 
  
  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsAsRead extends NotificationEvent {}

class DeleteNotification extends NotificationEvent {
  final String notificationId;
  
  const DeleteNotification(this.notificationId); 
  @override
  List<Object?> get props => [notificationId];
}

class DeleteAllNotifications extends NotificationEvent {}

class GetUnreadCount extends NotificationEvent {}