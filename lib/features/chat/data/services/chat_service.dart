import 'dart:async';
import 'package:agrilink/core/network/dio_client.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:dio/dio.dart';

class ChatService {
  final DioClient dioClient;
  final Logger logger;

  IO.Socket? _socket;
  bool _isConnected = false;
  String? _userId;
  String? _currentConversationId;

  // Stream controllers for different events
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController.broadcast();

  final StreamController<Map<String, dynamic>> _messageSentController =
      StreamController.broadcast();

  final StreamController<Map<String, dynamic>> _messageDeliveredController =
      StreamController.broadcast();

  final StreamController<Map<String, dynamic>> _messageReadController =
      StreamController.broadcast();

  final StreamController<Map<String, dynamic>> _errorController =
      StreamController.broadcast();

  final StreamController<Map<String, dynamic>> _typingController =
      StreamController.broadcast();

  final StreamController<bool> _connectionController =
      StreamController.broadcast();

  // Public streams
  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  Stream<Map<String, dynamic>> get messageSent => _messageSentController.stream;
  Stream<Map<String, dynamic>> get messageDelivered =>
      _messageDeliveredController.stream;
  Stream<Map<String, dynamic>> get messageRead => _messageReadController.stream;
  Stream<Map<String, dynamic>> get errors => _errorController.stream;
  Stream<Map<String, dynamic>> get typing => _typingController.stream;
  Stream<bool> get connectionStatus => _connectionController.stream;

  ChatService({required this.logger, required this.dioClient});

  // ================= CONNECTION MANAGEMENT =================

  void connect({required String baseUrl, required String userId}) {
    logger.i("🔌 CONNECTING - BaseUrl: $baseUrl, UserId: $userId");
    _userId = userId;

    // Clean up existing connection
    _cleanupSocket();

    // Initialize new socket
    _initializeSocket(baseUrl);

    _registerListeners();

    logger.i("🚀 Starting socket connection...");
    _socket!.connect();
  }

  void _cleanupSocket() {
    logger.d("🧹 Cleaning up existing socket connection...");
    _socket?.clearListeners();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    logger.d("✅ Socket cleanup complete");
  }

  void _initializeSocket(String baseUrl) {
    logger.d("🔧 Initializing new socket connection...");
    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .build(),
    );
  }

  // ================= SOCKET EVENT LISTENERS =================

  void _registerListeners() {
    logger.d("📡 Registering socket event listeners...");

    _socket!.onConnect((_) {
      _isConnected = true;
      logger.i("🟢 CONNECTED - Socket ID: ${_socket?.id}");
      _connectionController.add(true);
      _joinRoom();
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      logger.w("🔴 DISCONNECTED - Socket ID: ${_socket?.id}");
      _connectionController.add(false);
    });

    _socket!.onReconnect((attempt) {
      logger.i("🔄 RECONNECTED - Attempt: $attempt, Socket ID: ${_socket?.id}");
      _connectionController.add(true);
      _joinRoom();
    });

    _socket!.onConnectError((e) {
      logger.e("❌ CONNECT ERROR: $e");
      _errorController.add({'type': 'connect_error', 'error': e.toString()});
      _connectionController.add(false);
    });

    _socket!.onError((e) {
      logger.e("❌ SOCKET ERROR: $e");
      _errorController.add({'type': 'socket_error', 'error': e.toString()});
    });

    // Listen for new incoming messages
    _socket!.on('newMessage', (data) {
      logger.i("📨 New message received: $data");
      _messageController.add(Map<String, dynamic>.from(data));
    });

    // Listen for message sent confirmation
    _socket!.on('messageSent', (data) {
      logger.i("✅ MESSAGE SENT CONFIRMATION: $data");
      _messageSentController.add(Map<String, dynamic>.from(data));
    });

    // Listen for message delivery confirmation
    _socket!.on('messageDelivered', (data) {
      logger.i("📬 MESSAGE DELIVERED: $data");
      _messageDeliveredController.add(Map<String, dynamic>.from(data));
    });

    // Listen for message read confirmation
    _socket!.on('messageRead', (data) {
      logger.i("👁️ MESSAGE READ: $data");
      _messageReadController.add(Map<String, dynamic>.from(data));
    });

    // Listen for typing indicators
    _socket!.on('typing', (data) {
      logger.d("⌨️ User typing: $data");
      _typingController.add(Map<String, dynamic>.from(data));
    });

    // Listen for user status
    _socket!.on('userStatus', (data) {
      logger.d("👤 User status update: $data");
    });

    // Listen for connection status
    _socket!.on('connectionStatus', (data) {
      logger.i("🔌 Connection status: $data");
    });

    logger.d("✅ All socket event listeners registered");
  }

  // ================= ROOM MANAGEMENT =================

  void _joinRoom() {
    if (_socket == null || _userId == null) {
      logger.w(
        "⚠️ Cannot join room - Socket: ${_socket != null}, UserId: $_userId",
      );
      return;
    }

    logger.i("🚪 Joining room with userId: $_userId");
    _socket!.emit('join', _userId);
    logger.d("📤 Join room event emitted");
  }

  // ================= CONVERSATION MANAGEMENT =================

  void setCurrentConversation(String conversationId) {
    _currentConversationId = conversationId;
    logger.d("📌 Current conversation set to: $conversationId");

    // Mark all messages in this conversation as read
    if (_socket != null && _isConnected) {
      markConversationAsRead(conversationId);
    }
  }

  void clearCurrentConversation() {
    _currentConversationId = null;
    logger.d("📌 Current conversation cleared");
  }

  void markConversationAsRead(String conversationId) {
    if (_socket == null || !_isConnected) return;

    logger.i("👁️ Marking conversation as read: $conversationId");
    _socket!.emit('markConversationRead', {
      'conversationId': conversationId,
      'userId': _userId,
    });
  }

  // ================= MESSAGE OPERATIONS =================

  void sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String? tempId,
  }) {
    logger.i(
      "📤 SENDING MESSAGE - From: $senderId, To: $receiverId, Content: ${content.length} chars",
    );

    if (_socket == null || !_isConnected) {
      logger.w(
        "⚠️ Cannot send message - Socket exists: ${_socket != null}, Connected: $_isConnected",
      );
      _errorController.add({
        'type': 'send_error',
        'error': 'Socket not connected',
        'message': content,
      });
      return;
    }

    final payload = {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': content,
      'timestamp': DateTime.now().toIso8601String(),
      'tempId': tempId ?? DateTime.now().millisecondsSinceEpoch.toString(),
    };

    logger.d("📦 Message payload: $payload");

    // Emit with acknowledgement callback
    _socket!.emitWithAck(
      'sendMessage',
      payload,
      ack: (data) {
        logger.i("📮 MESSAGE ACKNOWLEDGEMENT: $data");

        // Check if we got a message object back (success case)
        if (data != null && data['message'] != null) {
          logger.i("✅ Message sent successfully!");
          logger.i("📝 Message ID: ${data['message']['id']}");
          logger.i("💬 Conversation ID: ${data['conversation']['id']}");

          // Add to message sent stream with the full data
          _messageSentController.add(
            Map<String, dynamic>.from({
              'tempId': tempId,
              'messageId': data['message']['id'],
              'conversationId': data['conversation']['id'],
              'message': data['message']['message'],
              'status': 'sent',
              'serverData': data,
            }),
          );

          // Also emit as a new message (in case it's from current user)
          _messageController.add(
            Map<String, dynamic>.from({
              ...data['message'],
              'tempId': tempId,
              'status': 'sent',
            }),
          );
        } else if (data != null && data['success'] == true) {
          // Alternative success format
          logger.i("✅ Message sent successfully (alternative format)");
          _messageSentController.add(
            Map<String, dynamic>.from({
              'tempId': tempId,
              'messageId': data['messageId'],
              'status': 'sent',
            }),
          );
        } else if (data != null && data['error'] != null) {
          // Error case
          logger.e("❌ Server rejected message: ${data['error']}");
          _errorController.add({
            'type': 'send_rejected',
            'error': data['error'],
            'message': payload,
          });
        } else {
          // Unknown response format but we got something
          logger.w("⚠️ Unknown acknowledgement format: $data");
          _messageSentController.add(
            Map<String, dynamic>.from({
              'tempId': tempId,
              'status': 'sent',
              'rawData': data,
            }),
          );
        }
      },
    );

    logger.i("✅ Message emit completed");
  }

  void trackMessage(String messageId) {
    if (_socket == null || !_isConnected) {
      logger.w("⚠️ Cannot track message - Socket not connected");
      return;
    }

    logger.d("🔍 Tracking message: $messageId");
    _socket!.emit('trackMessage', {'messageId': messageId});
  }

  void markAsDelivered(String messageId, String receiverId) {
    if (_socket == null || !_isConnected) {
      logger.w("⚠️ Cannot mark as delivered - Socket not connected");
      return;
    }

    logger.d("📬 Marking message as delivered: $messageId");
    _socket!.emit('markDelivered', {
      'messageId': messageId,
      'receiverId': receiverId,
    });
  }

  void markAsRead(String messageId, String conversationId) {
    if (_socket == null || !_isConnected) {
      logger.w("⚠️ Cannot mark as read - Socket not connected");
      return;
    }

    logger.d("👁️ Marking message as read: $messageId");
    _socket!.emit('markRead', {
      'messageId': messageId,
      'conversationId': conversationId,
      'userId': _userId,
    });
  }

  void sendTyping(String receiverId, bool isTyping) {
    if (_socket == null || !_isConnected) return;

    _socket!.emit('typing', {
      'receiverId': receiverId,
      'isTyping': isTyping,
      'senderId': _userId,
    });
  }

  // ================= API CALLS =================

  Future<List<dynamic>> fetchConversations() async {
    logger.i("📥 Fetching conversations...");
    try {
      final response = await dioClient.get('/chat/conversations');
      logger.d("📡 API Response status: ${response.statusCode}");

      final data = response.data;

      if (data is List) {
        logger.i(
          "📥 Conversations loaded successfully: ${data.length} conversations",
        );
        logger.d("📋 Conversation IDs: ${data.map((c) => c['id']).toList()}");
        return data;
      }

      logger.w(
        "⚠️ Unexpected response format - Expected List, got ${data.runtimeType}",
      );
      return [];
    } catch (e, stackTrace) {
      logger.e("❌ ERROR fetching conversations: $e");
      logger.e("📋 Stack trace: $stackTrace");
      return [];
    }
  }

  Future<List<dynamic>> fetchMessages(String conversationId) async {
    logger.i("📥 Fetching messages for conversation: $conversationId");
    try {
      final response = await dioClient.get('/chat/messages/$conversationId');
      logger.d("📡 API Response status: ${response.statusCode}");

      final data = response.data;

      if (data is List) {
        logger.i("📥 Messages loaded successfully: ${data.length} messages");
        return data;
      }

      logger.w(
        "⚠️ Unexpected response format - Expected List, got ${data.runtimeType}",
      );
      return [];
    } catch (e) {
      // Check if it's a DioException and status code is 404
      if (e is DioException && e.response?.statusCode == 404) {
        logger.i("ℹ️ No messages found for conversation: $conversationId");
        return [];
      }
      logger.e("❌ ERROR fetching messages: $e");
      return [];
    }
  }

  // ================= CONNECTION STATUS GETTERS =================

  bool get isConnected => _isConnected;

  String? get socketId => _socket?.id;

  // ================= CLEANUP =================

  void disconnect() {
    logger.i("🔌 Disconnecting chat service...");
    logger.d(
      "Current status - Connected: $_isConnected, Socket exists: ${_socket != null}",
    );

    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    _currentConversationId = null;

    logger.i("✅ Chat service disconnected");
  }

  void dispose() {
    logger.i("🧹 Disposing ChatService...");
    _messageController.close();
    _messageSentController.close();
    _messageDeliveredController.close();
    _messageReadController.close();
    _errorController.close();
    _typingController.close();
    _connectionController.close();
    disconnect();
    logger.i("✅ ChatService disposed");
  }
}
