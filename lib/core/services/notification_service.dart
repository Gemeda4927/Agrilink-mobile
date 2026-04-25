import 'dart:async';
import 'dart:convert';

import 'package:agrilink/core/network/api_constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/routes/route_name.dart';
import '../network/dio_client.dart';
import '../../injector.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final StreamController<Map<String, dynamic>> _streamController =
      StreamController.broadcast();

  late final Logger _logger;
  String? _fcmToken;

  Stream<Map<String, dynamic>> get messageStream => _streamController.stream;

  static Function(String route, {Map<String, dynamic>? extra})? navigateTo;

  Future<void> initialize() async {
    _logger = sl<Logger>();
    _logger.i('Notification service initializing...');

    await _requestPermission();
    await _initLocalNotifications();
    await _initFirebaseMessaging();
    _setupListeners();

    _logger.i('Notification service ready');
  }

  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    _logger.i('Permission: ${settings.authorizationStatus}');
  }

  Future<void> _initLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTap,
    );

    await _createChannels();
  }

  Future<void> _createChannels() async {
    final android = _localNotifications
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

      for (final channel in channels) {
        await android.createNotificationChannel(channel);
      }
    } catch (e) {
      _logger.e('Failed to create channels: $e');
    }
  }

  Future<void> _initFirebaseMessaging() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        await _saveToken(_fcmToken!);
      }

      _firebaseMessaging.onTokenRefresh.listen(_onTokenRefresh);
    } catch (e) {
      _logger.e('FCM initialization failed: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  void _onTokenRefresh(String token) async {
    _fcmToken = token;
    await _saveToken(token);
    _logger.i('Token refreshed');
  }

  void _setupListeners() {
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
  }

  void _onForegroundMessage(RemoteMessage message) {
    _showLocalNotification(message);
    _addToStreamAndSave(message);
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    // Also add to stream when user taps notification to open app
    _addToStreamAndSave(message);
    _handleNavigation(message.data);
  }

  void _addToStreamAndSave(RemoteMessage message) {
    final enrichedData = _enrichMessageData(message);
    
    // Add to stream for real-time updates
    _streamController.add(enrichedData);
    
    // Save to SharedPreferences for persistence
    _saveNotificationToStorage(enrichedData);
  }

  Future<void> _saveNotificationToStorage(Map<String, dynamic> notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString('saved_notifications') ?? '[]';
      List<dynamic> savedList = jsonDecode(savedJson);
      
      savedList.insert(0, {
        'title': notification['title'],
        'body': notification['body'],
        'type': notification['type'],
        'timestamp': notification['timestamp'],
        'read': false,
      });
      
      if (savedList.length > 50) savedList = savedList.take(50).toList();
      await prefs.setString('saved_notifications', jsonEncode(savedList));
    } catch (e) {
      _logger.e('Failed to save notification: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSavedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString('saved_notifications') ?? '[]';
      final List<dynamic> decoded = jsonDecode(savedJson);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      _logger.e('Failed to load saved notifications: $e');
      return [];
    }
  }

  Map<String, dynamic> _enrichMessageData(RemoteMessage message) {
    return {
      ...message.data,
      'title': message.notification?.title,
      'body': message.notification?.body,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
      100000,
    );

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _getChannelId(message.data),
        'Notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      notificationId,
      message.notification?.title ?? 'Agrilink',
      message.notification?.body ?? '',
      details,
      payload: jsonEncode(message.data),
    );
  }

  String _getChannelId(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    switch (type) {
      case 'order':
        return 'orders';
      case 'chat':
        return 'chat';
      default:
        return 'general';
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    final data = jsonDecode(response.payload!);
    _handleNavigation(data);
  }

  static void _onBackgroundNotificationTap(NotificationResponse response) {
    if (response.payload == null || navigateTo == null) return;
    final data = jsonDecode(response.payload!);
    _handleBackgroundNavigation(data);
  }

  void _handleNavigation(Map<String, dynamic> data) {
    final route = _getRouteFromType(data);
    navigateTo?.call(route, extra: data);
  }

  static void _handleBackgroundNavigation(Map<String, dynamic> data) {
    final route = _getRouteFromTypeStatic(data);
    navigateTo?.call(route, extra: data);
  }

  String _getRouteFromType(Map<String, dynamic> data) {
    return _getRouteFromTypeStatic(data);
  }

  static String _getRouteFromTypeStatic(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    switch (type) {
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

  Future<void> clearBadge() async {
    try {
      await _localNotifications.cancelAll();
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _firebaseMessaging.setAutoInitEnabled(true);
      }
      _logger.i('Badge and notifications cleared');
    } catch (e) {
      _logger.e('Failed to clear badge: $e');
    }
  }

  Future<void> showTestNotification() async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'Test Notification',
      'Your notifications are working! ✅',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general',
          'General Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

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

  Future<bool> registerDeviceToken(String token) async {
    try {
      final dioClient = sl<DioClient>();
      final response = await dioClient.post(
        ApiConstants.deviceRegister,
        data: {
          'token': token,
          'platform': defaultTargetPlatform == TargetPlatform.iOS
              ? 'ios'
              : 'android',
        },
      );

      final success = response.statusCode == 200 || response.statusCode == 201;
      if (success) _logger.i('Device token registered');
      return success;
    } catch (e) {
      _logger.e('Failed to register token: $e');
      return false;
    }
  }

  Future<void> unregisterDeviceToken() async {
    final token = await getSavedToken();
    if (token == null) return;

    try {
      final dioClient = sl<DioClient>();
      await dioClient.post(
        ApiConstants.deviceUnregister,
        data: {'token': token},
      );
      _logger.i('Device token unregistered');
    } catch (e) {
      _logger.e('Failed to unregister token: $e');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _onBackgroundMessage(RemoteMessage message) async {
    WidgetsFlutterBinding.ensureInitialized();
    final logger = Logger();
    logger.i('Background message received: ${message.data}');
    
    // Save to storage even in background
    final prefs = await SharedPreferences.getInstance();
    final savedJson = prefs.getString('saved_notifications') ?? '[]';
    List<dynamic> savedList = jsonDecode(savedJson);
    
    savedList.insert(0, {
      'title': message.notification?.title,
      'body': message.notification?.body,
      'type': message.data['type'],
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
    });
    
    if (savedList.length > 50) savedList = savedList.take(50).toList();
    await prefs.setString('saved_notifications', jsonEncode(savedList));
  }

  void dispose() {
    _streamController.close();
  }
}