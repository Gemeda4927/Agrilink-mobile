import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../services/notification_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final ApiNotificationService notificationService;

  NotificationRepositoryImpl({required this.notificationService});

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    try {
      final models = await notificationService.getNotifications();

      // Convert models to entities
      final List<NotificationEntity> entities = [];
      for (final model in models) {
        final isRead = notificationService.isNotificationRead(model.id);
        entities.add(model.toEntity(isRead: isRead));
      }
      return entities;
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  @override
  Future<List<NotificationEntity>> getNewNotifications() async {
    try {
      final models = await notificationService.getNewNotifications();

      // Convert models to entities
      final List<NotificationEntity> entities = [];
      for (final model in models) {
        final isRead = notificationService.isNotificationRead(model.id);
        entities.add(model.toEntity(isRead: isRead));
      }
      return entities;
    } catch (e) {
      throw Exception('Failed to get new notifications: $e');
    }
  }

  @override
  Future<List<NotificationEntity>> getUnreadNotifications() async {
    final all = await getNotifications();
    return all.where((n) => !n.isRead).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await notificationService.markNotificationAsRead(notificationId);
    } catch (e) {
      notificationService.markAsReadLocally(notificationId);
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final notifications = await getNotifications();

      for (final notification in notifications) {
        if (!notification.isRead) {
          await notificationService.markNotificationAsRead(notification.id);
        }
      }
    } catch (e) {
      final notifications = await getNotifications();
      final ids = notifications.map((n) => n.id).toList();
      notificationService.markAllAsReadLocally(ids);
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      notificationService.deleteNotificationLocally(notificationId);
    } catch (e) {
      notificationService.deleteNotificationLocally(notificationId);
    }
  }

  @override
  Future<void> deleteAllNotifications() async {
    try {
      notificationService.deleteAllNotificationsLocally();
    } catch (e) {
      notificationService.deleteAllNotificationsLocally();
    }
  }

  @override
  Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => !n.isRead).length;
  }

  @override
  Future<void> subscribeToNotifications() async {
    // FCM registration - handled by NotificationService
  }
}
