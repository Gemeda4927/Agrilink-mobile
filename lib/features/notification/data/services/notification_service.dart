import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/notification_model.dart.dart';

class ApiNotificationService  {
  final DioClient dioClient;
  final SharedPreferences prefs;

  ApiNotificationService ({
    required this.dioClient,
    required this.prefs,
  });

  // ================= API CALLS =================
  

Future<List<NotificationModel>> getNotifications() async {
  try {
    final response = await dioClient.get('/notification');
    
    // Check if response has the nested structure
    if (response.data != null && response.data['notification'] != null) {
      final List<dynamic> notificationsData = response.data['notification'];
      return notificationsData
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    }
    
    // Fallback for empty response
    return [];
  } catch (e) {
    throw Exception('Failed to get notifications: $e');
  }
}


  // GET /notification/new - Get new notifications
  Future<List<NotificationModel>> getNewNotifications() async {
    try {
      final Response response = await dioClient.get('${ApiConstants.notifications}/new');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load new notifications: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error fetching new notifications: $e');
    }
  }

  // PATCH /notification/{id} - Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final Response response = await dioClient.patch(
        '${ApiConstants.notifications}/$notificationId',
      );

      if (response.statusCode == 200) {
        // Mark as read locally after successful API call
        markAsReadLocally(notificationId);
      } else {
        throw Exception('Failed to mark notification as read: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  // ================= LOCAL STORAGE (Read/Delete state) =================
  
  static const String _readNotificationsKey = 'read_notifications';
  static const String _deletedNotificationsKey = 'deleted_notifications';

  // Get read notification IDs
  Set<String> getReadNotifications() {
    final List<String>? list = prefs.getStringList(_readNotificationsKey);
    return list?.toSet() ?? {};
  }

  // Save read notification IDs
  void _saveReadNotifications(Set<String> readIds) {
    prefs.setStringList(_readNotificationsKey, readIds.toList());
  }

  // Mark a notification as read
  void markAsReadLocally(String notificationId) {
    final readIds = getReadNotifications();
    readIds.add(notificationId);
    _saveReadNotifications(readIds);
  }

  // Mark all as read
  void markAllAsReadLocally(List<String> allNotificationIds) {
    _saveReadNotifications(Set.from(allNotificationIds));
  }

  // Check if notification is read
  bool isNotificationRead(String notificationId) {
    return getReadNotifications().contains(notificationId);
  }

  // Get unread count
  int getUnreadCount(List<String> allNotificationIds) {
    final readIds = getReadNotifications();
    return allNotificationIds.where((id) => !readIds.contains(id)).length;
  }

  // Get deleted notification IDs
  Set<String> getDeletedNotifications() {
    final List<String>? list = prefs.getStringList(_deletedNotificationsKey);
    return list?.toSet() ?? {};
  }

  // Save deleted notification IDs
  void _saveDeletedNotifications(Set<String> deletedIds) {
    prefs.setStringList(_deletedNotificationsKey, deletedIds.toList());
  }

  // Mark a notification as deleted
  void deleteNotificationLocally(String notificationId) {
    final deletedIds = getDeletedNotifications();
    deletedIds.add(notificationId);
    _saveDeletedNotifications(deletedIds);
    // Also remove from read if present
    final readIds = getReadNotifications();
    readIds.remove(notificationId);
    _saveReadNotifications(readIds);
  }

  // Delete all notifications
  void deleteAllNotificationsLocally() {
    _saveDeletedNotifications({});
    _saveReadNotifications({});
  }

  // Check if notification is deleted
  bool isNotificationDeleted(String notificationId) {
    return getDeletedNotifications().contains(notificationId);
  }

  // Get filtered notifications (exclude deleted)
  List<NotificationModel> getFilteredNotifications(
    List<NotificationModel> notifications,
  ) {
    final deletedIds = getDeletedNotifications();
    return notifications.where((n) => !deletedIds.contains(n.id)).toList();
  }

  // Clear all data (on logout)
  void clearAllLocalData() {
    prefs.remove(_readNotificationsKey);
    prefs.remove(_deletedNotificationsKey);
  }

  String _handleDioError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data != null && data is Map) {
        return data['message'] ?? 'Server error occurred';
      }
      return 'Server error: ${error.response?.statusCode}';
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Receive timeout. Please try again.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please check your network.';
    } else {
      return 'Unexpected error: ${error.message}';
    }
  }
}