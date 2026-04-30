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
  bool _isInitialized = false;
  bool _isSubscribed = false; // Track if already subscribed

  Stream<Map<String, dynamic>> get messageStream => _streamController.stream;

  static Function(String route, {Map<String, dynamic>? extra})? navigateTo;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _logger = sl<Logger>();
    _logger.i('Initializing notification service...');

    await _requestPermission();
    await _initLocalNotifications();
    await _initFirebaseMessaging();
    _setupListeners();
    
    _isInitialized = true;
    _logger.i('Notification service ready - waiting for manual subscription');
  }

  Future<void> _requestPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
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
            AndroidFlutterLocalNotificationsPlugin>();

    if (android == null) return;

    try {
      const channels = [
        AndroidNotificationChannel('general', 'General Notifications', importance: Importance.high),
        AndroidNotificationChannel('orders', 'Order Notifications', importance: Importance.high),
        AndroidNotificationChannel('products', 'Product Notifications', importance: Importance.high),
        AndroidNotificationChannel('role_requests', 'Role Request Notifications', importance: Importance.high),
        AndroidNotificationChannel('market_prices', 'Market Price Notifications', importance: Importance.high),
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
        _logger.i('FCM token saved - waiting for manual subscription');
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
    _isSubscribed = false; // Reset subscription flag on token refresh
    _logger.i('Token refreshed - subscription reset');
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
    _addToStreamAndSave(message);
    _handleNavigation(message.data);
  }

  void _addToStreamAndSave(RemoteMessage message) {
    final enrichedData = _enrichMessageData(message);
    _streamController.add(enrichedData);
    _saveNotificationToStorage(enrichedData);
  }

  Future<void> _saveNotificationToStorage(Map<String, dynamic> notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString('saved_notifications') ?? '[]';
      List<dynamic> savedList = jsonDecode(savedJson);

      savedList.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': notification['title'],
        'body': notification['body'],
        'type': notification['type'],
        'timestamp': DateTime.now().toIso8601String(),
        'read': false,
        'data': notification,
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
    final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _getChannelId(message.data),
        _getChannelName(message.data),
        importance: Importance.high,
        priority: Priority.high,
        autoCancel: true,
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
      case 'order_placed':
      case 'order_status_changed':
        return 'orders';
      case 'product_created':
        return 'products';
      case 'role_request_approved':
      case 'role_request_rejected':
        return 'role_requests';
      case 'market_price_approved':
      case 'market_price_rejected':
        return 'market_prices';
      default:
        return 'general';
    }
  }

  String _getChannelName(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    switch (type) {
      case 'order_placed':
      case 'order_status_changed':
        return 'Order Notifications';
      case 'product_created':
        return 'Product Notifications';
      case 'role_request_approved':
      case 'role_request_rejected':
        return 'Role Request Notifications';
      case 'market_price_approved':
      case 'market_price_rejected':
        return 'Market Price Notifications';
      default:
        return 'General Notifications';
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
    _logger.i('Navigating to: $route');
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
      case 'order_placed':
      case 'order_status_changed':
        return RouteName.myOrders;
      case 'product_created':
        return RouteName.myProducts;
      case 'role_request_approved':
      case 'role_request_rejected':
        return RouteName.dashboard;
      case 'market_price_approved':
      case 'market_price_rejected':
        return RouteName.approvedPrices;
      default:
        return RouteName.home;
    }
  }

  Future<void> clearBadge() async {
    try {
      await _localNotifications.cancelAll();
    } catch (e) {
      _logger.e('Failed to clear badge: $e');
    }
  }

  // ✅ ONLY CALL THIS WHEN USER CLICKS NOTIFICATION BADGE
  Future<void> subscribeManually(String role) async {
    if (_isSubscribed) {
      _logger.i('Already subscribed to notifications');
      return;
    }

    try {
      final token = await getSavedToken();
      if (token == null) {
        _logger.w('No FCM token available');
        return;
      }

      _logger.i('📱 Manually subscribing to notifications (user clicked badge)...');
      
      // Register device token with backend
      final dioClient = sl<DioClient>();
      final response = await dioClient.post(
        ApiConstants.deviceRegister,
        data: {
          'token': token,
          'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Subscribe to topics
        await _firebaseMessaging.subscribeToTopic('all_users');
        await _firebaseMessaging.subscribeToTopic('role_${role.toLowerCase()}');
        
        _isSubscribed = true;
        _logger.i('✅ Successfully subscribed to notifications (manual)');
        
        // Show confirmation
        _showSubscriptionConfirmation();
      }
    } catch (e) {
      _logger.e('Failed to subscribe manually: $e');
    }
  }

  void _showSubscriptionConfirmation() {
    // You can show a snackbar or dialog
    _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'Notifications Enabled 🔔',
      'You will now receive notifications',
      const NotificationDetails(
        android: AndroidNotificationDetails('general', 'General Notifications'),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> unsubscribeManually() async {
    if (!_isSubscribed) return;

    try {
      final token = await getSavedToken();
      if (token != null) {
        final dioClient = sl<DioClient>();
        await dioClient.post(ApiConstants.deviceUnregister, data: {'token': token});
      }
      
      await _firebaseMessaging.unsubscribeFromTopic('all_users');
      _isSubscribed = false;
      _logger.i('Unsubscribed from notifications');
    } catch (e) {
      _logger.e('Failed to unsubscribe: $e');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _onBackgroundMessage(RemoteMessage message) async {
    WidgetsFlutterBinding.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    final savedJson = prefs.getString('saved_notifications') ?? '[]';
    List<dynamic> savedList = jsonDecode(savedJson);

    savedList.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': message.notification?.title,
      'body': message.notification?.body,
      'type': message.data['type'],
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
      'data': message.data,
    });

    if (savedList.length > 50) savedList = savedList.take(50).toList();
    await prefs.setString('saved_notifications', jsonEncode(savedList));
  }

  void dispose() {
    _streamController.close();
  }
}