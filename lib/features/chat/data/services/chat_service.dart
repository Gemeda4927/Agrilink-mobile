import 'package:socket_io_client/socket_io_client.dart'
    as IO
    show Socket, OptionBuilder, io, DartySocket;
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';

class ChatService {
  final DioClient dioClient;
  late IO.Socket socket;
  bool _isConnected = false;

  ChatService({required this.dioClient});

  // ================= SOCKET.IO REAL-TIME =================
  void connectSocket(String token) {
    socket = IO.io(
      ApiConstants.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNew()
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    socket.onConnect((_) {
      _isConnected = true;
      print('✅ Socket connected');
    });

    socket.onDisconnect((_) {
      _isConnected = false;
      print('❌ Socket disconnected');
    });

    socket.onConnectError((err) {
      print('⚠️ Socket connection error: $err');
    });

    socket.onError((err) {
      print('⚠️ Socket error: $err');
    });
  }

  /// Send message through socket
  void sendMessageSocket({
    required String conversationId,
    required String senderId,
    required String message,
  }) {
    if (!_isConnected) {
      print('❌ Socket not connected');
      return;
    }

    socket.emit('send_message', {
      'conversationId': conversationId,
      'senderId': senderId,
      'message': message,
    });
  }

  /// Listen for incoming messages
  void listenMessagesSocket(Function(Map<String, dynamic>) onMessage) {
    socket.on('new_message', (data) {
      if (data is Map<String, dynamic>) {
        onMessage(data);
      } else {
        print('⚠️ Invalid message format received from socket: $data');
      }
    });
  }

  /// Disconnect socket manually
  void disconnectSocket() {
    if (_isConnected) {
      socket.dispose();
      _isConnected = false;
      print('✅ Socket disconnected manually');
    }
  }

  // ================= REST API =================

  /// Fetch all conversations for the current user
  Future<List<Map<String, dynamic>>> fetchConversations() async {
    try {
      final response = await dioClient.get(ApiConstants.chatConversations);
      final data = response.data as List<dynamic>;
      return data.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ Error fetching conversations: $e');
      return [];
    }
  }

  /// Fetch messages for a specific conversation
  Future<List<Map<String, dynamic>>> fetchMessages(
    String conversationId,
  ) async {
    try {
      final response = await dioClient.get(
        '/chat/conversations/$conversationId/messages',
      );
      final data = response.data as List<dynamic>;
      return data.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ Error fetching messages: $e');
      return [];
    }
  }

  /// Send message via REST API (fallback if socket not available)
  Future<bool> sendMessageRest({
    required String conversationId,
    required String senderId,
    required String message,
  }) async {
    try {
      await dioClient.post(
        '/chat/messages',
        data: {
          'conversationId': conversationId,
          'senderId': senderId,
          'message': message,
        },
      );
      return true;
    } catch (e) {
      print('❌ Error sending message via REST: $e');
      return false;
    }
  }

  /// Check if socket is connected
  bool get isConnected => _isConnected;
}
