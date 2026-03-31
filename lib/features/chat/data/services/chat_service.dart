import 'package:agrilink/core/network/api_constants.dart';
import 'package:agrilink/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:logger/logger.dart';

class ChatService {
  final DioClient dioClient;
  final Logger logger;

  IO.Socket? socket; // ✅ safe

  ChatService({
    required this.dioClient,
    required this.logger,
  });

  // ================= CONNECT =================
  void connectSocket() {
    if (socket != null && socket!.connected) return;

    socket = IO.io(
      "http://agrilink-1-x6ph.onrender.com",
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      logger.i("🟢 Socket Connected");
    });

    socket!.onDisconnect((_) {
      logger.w("🔴 Socket Disconnected");
    });

    socket!.onError((e) {
      logger.e("⚠️ Socket Error: $e");
    });
  }

  // ================= SEND =================
  void sendSocketMessage({
    required String conversationId,
    required String senderId,
    required String message,
  }) {
    if (socket == null || !socket!.connected) {
      connectSocket();
    }

    socket!.emit('send_message', {
      "conversationId": conversationId,
      "senderId": senderId,
      "message": message,
    });
  }

  // ================= LISTEN =================
  void onMessage(Function(dynamic data) callback) {
    socket?.on('receive_message', (data) {
      callback(data);
    });
  }

  // ================= GET =================
  Future<Response> getConversations() {
    return dioClient.get(ApiConstants.chatConversations);
  }

  // ================= DISCONNECT =================
  void disconnect() {
    socket?.disconnect();
    socket = null;
  }
}