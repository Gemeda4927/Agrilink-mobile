import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<List<NotificationEntity>> getNewNotifications(); 
  Future<List<NotificationEntity>> getUnreadNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  Future<void> deleteAllNotifications();
  Future<int> getUnreadCount();
  Future<void> subscribeToNotifications();
}