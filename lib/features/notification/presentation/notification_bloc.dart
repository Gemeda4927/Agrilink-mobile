import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:agrilink/core/services/notification_service.dart';
import 'package:agrilink/injector.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService _notificationService = sl<NotificationService>();
  StreamSubscription? _messageSubscription;
  List<NotificationItem> _notifications = [];

  NotificationBloc() : super(NotificationInitial()) {
    on<InitializeNotifications>(_onInitialize);
    on<NotificationReceived>(_onNotificationReceived);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<ClearAllNotifications>(_onClearAll);
    on<SubscribeToTopic>(_onSubscribeToTopic);
    on<UnsubscribeFromTopic>(_onUnsubscribeFromTopic);

    _setupMessageListener();
  }

  void _setupMessageListener() {
    _messageSubscription = _notificationService.messageStream.listen((data) {
      final notification = NotificationItem.fromMap(data);
      add(NotificationReceived(notification));
    });
  }

  Future<void> _onInitialize(
    InitializeNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    emit(NotificationLoaded(notifications: _notifications));
  }

  void _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    _notifications.insert(0, event.notification);
    emit(NotificationLoaded(notifications: List.from(_notifications)));
  }

  void _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) {
    final index = _notifications.indexWhere((n) => n.id == event.id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      emit(NotificationLoaded(notifications: List.from(_notifications)));
    }
  }

  void _onClearAll(
    ClearAllNotifications event,
    Emitter<NotificationState> emit,
  ) {
    _notifications.clear();
    emit(NotificationLoaded(notifications: []));
  }

  Future<void> _onSubscribeToTopic(
    SubscribeToTopic event,
    Emitter<NotificationState> emit,
  ) async {
    await _notificationService.subscribeToTopic(event.topic);
  }

  Future<void> _onUnsubscribeFromTopic(
    UnsubscribeFromTopic event,
    Emitter<NotificationState> emit,
  ) async {
    await _notificationService.unsubscribeFromTopic(event.topic);
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}