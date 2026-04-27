import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrilink/features/notification/domain/usecases/notification_usecases.dart';
import 'package:agrilink/injector.dart';
import 'package:agrilink/core/services/notification_service.dart';

import '../../domain/entities/notification.dart';
import 'notification_state.dart';

part 'notification_event.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final GetNewNotificationsUseCase getNewNotificationsUseCase;
  final GetUnreadCountUseCase getUnreadCountUseCase;
  final MarkAsReadUseCase markAsReadUseCase;
  final MarkAllAsReadUseCase markAllAsReadUseCase;
  final DeleteNotificationUseCase deleteNotificationUseCase;
  final DeleteAllNotificationsUseCase deleteAllNotificationsUseCase;

  final NotificationService _notificationService = sl<NotificationService>();

  NotificationBloc({
    required this.getNotificationsUseCase,
    required this.getNewNotificationsUseCase,
    required this.getUnreadCountUseCase,
    required this.markAsReadUseCase,
    required this.markAllAsReadUseCase,
    required this.deleteNotificationUseCase,
    required this.deleteAllNotificationsUseCase,
  }) : super(NotificationInitial()) {
    on<InitializeNotifications>(_onInitializeNotifications);
    on<LoadNotificationsFromApi>(_onLoadNotificationsFromApi);
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<DeleteAllNotifications>(_onDeleteAllNotifications);
    on<GetUnreadCount>(_onGetUnreadCount);

    _listenToFCMNotifications();
  }

  void _listenToFCMNotifications() {
    _notificationService.messageStream.listen((messageData) {
      final currentState = state;
      if (currentState is NotificationLoaded) {
        final newNotification = NotificationEntity(
          id:
              messageData['id'] ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          userId: messageData['userId'] ?? '',
          type: NotificationType.fromString(messageData['type'] ?? 'UNKNOWN'),
          title: messageData['title'] ?? 'New Notification',
          message: messageData['body'] ?? '',
          isSent: true,
          isRead: false,
          createdAt: DateTime.now(),
        );

        final updatedNotifications = [
          newNotification,
          ...currentState.notifications,
        ];
        // ✅ Use NotificationLoaded (WITHOUT 's')
        emit(NotificationLoaded(notifications: updatedNotifications));

        // Also update unread count
        add(GetUnreadCount());
      } else {
        // If no state, just reload
        add(LoadNotificationsFromApi());
      }
    });
  }

  Future<void> _onInitializeNotifications(
    InitializeNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    add(LoadNotificationsFromApi());
    add(GetUnreadCount());
  }

  Future<void> _onLoadNotificationsFromApi(
    LoadNotificationsFromApi event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());

    final result = await getNotificationsUseCase(NoParams());
    result.fold((error) => emit(NotificationError(message: error)), (
      notifications,
    ) {
      // ✅ Use NotificationLoaded (WITHOUT 's')
      emit(NotificationLoaded(notifications: notifications));
    });
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    add(LoadNotificationsFromApi());
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await markAsReadUseCase(
      MarkAsReadParams(notificationId: event.notificationId),
    );

    result.fold((error) => null, (_) {
      add(LoadNotificationsFromApi());
      add(GetUnreadCount());
    });
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await markAllAsReadUseCase(NoParams());

    result.fold((error) => null, (_) {
      add(LoadNotificationsFromApi());
      add(GetUnreadCount());
    });
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await deleteNotificationUseCase(
      DeleteNotificationParams(notificationId: event.notificationId),
    );

    result.fold((error) => null, (_) {
      add(LoadNotificationsFromApi());
      add(GetUnreadCount());
    });
  }

  Future<void> _onDeleteAllNotifications(
    DeleteAllNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await deleteAllNotificationsUseCase(NoParams());

    result.fold((error) => null, (_) {
      add(LoadNotificationsFromApi());
      add(GetUnreadCount());
    });
  }

  Future<void> _onGetUnreadCount(
    GetUnreadCount event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await getUnreadCountUseCase(NoParams());

    result.fold(
      (error) => null,
      (count) => emit(UnreadCountUpdated(count: count)),
    );
  }
}
