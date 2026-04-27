import 'package:dartz/dartz.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

abstract class UseCase<Type, Params> {
  Future<Either<String, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}

// Get Notifications
class GetNotificationsUseCase
    implements UseCase<List<NotificationEntity>, NoParams> {
  final NotificationRepository repository;
  GetNotificationsUseCase(this.repository);

  @override
  Future<Either<String, List<NotificationEntity>>> call(NoParams params) async {
    try {
      final notifications = await repository.getNotifications();
      return Right(notifications);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

// Get New Notifications
class GetNewNotificationsUseCase
    implements UseCase<List<NotificationEntity>, NoParams> {
  final NotificationRepository repository;
  GetNewNotificationsUseCase(this.repository);

  @override
  Future<Either<String, List<NotificationEntity>>> call(NoParams params) async {
    try {
      final notifications = await repository.getNewNotifications();
      return Right(notifications);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

// Get Unread Notifications
class GetUnreadNotificationsUseCase
    implements UseCase<List<NotificationEntity>, NoParams> {
  final NotificationRepository repository;
  GetUnreadNotificationsUseCase(this.repository);

  @override
  Future<Either<String, List<NotificationEntity>>> call(NoParams params) async {
    try {
      final notifications = await repository.getUnreadNotifications();
      return Right(notifications);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

// Mark as Read
class MarkAsReadParams {
  final String notificationId;
  MarkAsReadParams({required this.notificationId});
}

class MarkAsReadUseCase implements UseCase<void, MarkAsReadParams> {
  final NotificationRepository repository;
  MarkAsReadUseCase(this.repository);

  @override
  Future<Either<String, void>> call(MarkAsReadParams params) async {
    try {
      await repository.markAsRead(params.notificationId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

// Mark All as Read
class MarkAllAsReadUseCase implements UseCase<void, NoParams> {
  final NotificationRepository repository;
  MarkAllAsReadUseCase(this.repository);

  @override
  Future<Either<String, void>> call(NoParams params) async {
    try {
      await repository.markAllAsRead();
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

// Delete Notification
class DeleteNotificationParams {
  final String notificationId;
  DeleteNotificationParams({required this.notificationId});
}

class DeleteNotificationUseCase implements UseCase<void, DeleteNotificationParams> {
  final NotificationRepository repository;
  DeleteNotificationUseCase(this.repository);

  @override
  Future<Either<String, void>> call(DeleteNotificationParams params) async {
    try {
      await repository.deleteNotification(params.notificationId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

// Delete All Notifications
class DeleteAllNotificationsUseCase implements UseCase<void, NoParams> {
  final NotificationRepository repository;
  DeleteAllNotificationsUseCase(this.repository);

  @override
  Future<Either<String, void>> call(NoParams params) async {
    try {
      await repository.deleteAllNotifications();
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

// Get Unread Count
class GetUnreadCountUseCase implements UseCase<int, NoParams> {
  final NotificationRepository repository;
  GetUnreadCountUseCase(this.repository);

  @override
  Future<Either<String, int>> call(NoParams params) async {
    try {
      final count = await repository.getUnreadCount();
      return Right(count);
    } catch (e) {
      return Left(e.toString());
    }
  }
}