import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/routes/route_name.dart';
import '../network/dio_client.dart';
import '../network/token_manager.dart';
import '../../injector.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  late final Logger _logger;

  final StreamController<Map<String, dynamic>> _streamController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _streamController.stream;

  String? _fcmToken;

  static Function(String route, {Map<String, dynamic>? extra})? navigateTo;

  // ================= INIT =================

  Future<void> initialize() async {
    _logger = sl<Logger>();

    await _requestPermission();
    await _initLocalNotifications();
    await _initFirebaseMessaging();
    _setupListeners();
  }

  // ================= PERMISSIONS =================

  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    _logger.i("Permission: ${settings.authorizationStatus}");
  }

  // ================= LOCAL NOTIFICATIONS =================

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(android: android, iOS: ios);

    await localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onTap,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundTap,
    );

    await _createChannels();
  }

  Future<void> _createChannels() async {
    final android = localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android == null) return;

    try {
      const channels = [
        AndroidNotificationChannel(
          'general',
          'General',
          importance: Importance.high,
        ),
        AndroidNotificationChannel(
          'orders',
          'Orders',
          importance: Importance.high,
        ),
        AndroidNotificationChannel('chat', 'Chat', importance: Importance.high),
      ];

      for (final c in channels) {
        await android.createNotificationChannel(c);
      }
    } catch (e) {
      _logger.e("Channel error: $e");
    }
  }

  // ================= FCM =================

  Future<void> _initFirebaseMessaging() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      _logger.i("FCM Token: $_fcmToken");

      // ✅ FIXED: correct instance usage
      _firebaseMessaging.onTokenRefresh.listen((token) {
        _fcmToken = token;
        _logger.i("Token refreshed");
        _saveToken(token);
      });
    } catch (e) {
      _logger.e("FCM init error: $e");
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("fcm_token", token);
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("fcm_token");
  }

  // ================= LISTENERS =================

  void _setupListeners() {
    FirebaseMessaging.onMessage.listen(_onForeground);

    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      _handleNavigation(msg.data);
    });

    FirebaseMessaging.onBackgroundMessage(_bgHandler);
  }

  void _onForeground(RemoteMessage message) {
    _showLocalNotification(message);
    _streamController.add(message.data);
  }

  // ================= SHOW NOTIFICATION =================

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final android = AndroidNotificationDetails(
      _channel(message.data),
      'Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const ios = DarwinNotificationDetails();

    await localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? "Agrilink",
      message.notification?.body ?? "",
      NotificationDetails(android: android, iOS: ios),
      payload: jsonEncode(message.data),
    );
  }

  String _channel(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'order':
        return 'orders';
      case 'chat':
        return 'chat';
      default:
        return 'general';
    }
  }

  // ================= NAVIGATION =================

  void _onTap(NotificationResponse response) {
    if (response.payload == null) return;

    final data = jsonDecode(response.payload!);
    _handleNavigation(data);
  }

  static void _onBackgroundTap(NotificationResponse response) {
    if (response.payload == null || navigateTo == null) return;

    final data = jsonDecode(response.payload!);
    _handleBackgroundNavigation(data);
  }

  void _handleNavigation(Map<String, dynamic> data) {
    navigateTo?.call(_route(data), extra: data);
  }

  static void _handleBackgroundNavigation(Map<String, dynamic> data) {
    navigateTo?.call(_routeStatic(data), extra: data);
  }

  static String _routeStatic(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'order':
        return RouteName.myOrders;
      case 'chat':
        return RouteName.aiRecommendation;
      case 'product':
        return RouteName.product;
      default:
        return RouteName.home;
    }
  }

  String _route(Map<String, dynamic> data) {
    return _routeStatic(data);
  }

  // ================= FIXED BADGE (NO CRASH) =================

  Future<void> updateBadgeCount(int count) async {
    // iOS badge is handled by FCM or notification payload
    // flutter_local_notifications does NOT reliably support programmatic badge in your version

    _logger.i("Badge request ignored (handled by system/FCM): $count");
  }

  Future<void> clearBadge() async => updateBadgeCount(0);

  // ==================== TOPIC SUBSCRIPTION ====================

  Future<NotificationSettings> getNotificationSettings() async {
    try {
      return await _firebaseMessaging.getNotificationSettings();
    } catch (e) {
      _logger.e('Failed to get notification settings: $e');
      rethrow;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      _logger.i('Subscribed to topic: $topic');
    } catch (e) {
      _logger.e('Failed to subscribe to topic $topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      _logger.i('Unsubscribed from topic: $topic');
    } catch (e) {
      _logger.e('Failed to unsubscribe from topic $topic: $e');
    }
  }

  // ================= BACKEND =================

  Future<bool> registerDeviceToken(String token) async {
    try {
      final dio = sl<DioClient>();

      await dio.post(
        '/notifications/register-device',
        data: {
          'device_token': token,
          'device_type': defaultTargetPlatform == TargetPlatform.iOS
              ? 'ios'
              : 'android',
        },
      );

      return true;
    } catch (e) {
      _logger.e("Register error: $e");
      return false;
    }
  }

  Future<void> unregisterDeviceToken() async {
    try {
      final token = await getSavedToken();
      if (token == null) return;

      final dio = sl<DioClient>();
      await dio.post(
        '/notifications/unregister-device',
        data: {'device_token': token},
      );
    } catch (e) {
      _logger.e("Unregister error: $e");
    }
  }

  // ================= BACKGROUND HANDLER =================

  @pragma('vm:entry-point')
  static Future<void> _bgHandler(RemoteMessage message) async {
    WidgetsFlutterBinding.ensureInitialized();
    Logger().i("BG message: ${message.data}");
  }

  void dispose() {
    _streamController.close();
  }
}
