// lib/features/chat/data/services/chat_service.dart

import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';

class ChatService {
  final DioClient dioClient;
  late IO.Socket socket;
  bool _isConnected = false;
  String? _socketId;

  ChatService({required this.dioClient});

  // ================= SOCKET CONNECTION =================
  void connectSocket(String token) {
    print('🔌 Connecting socket...');

    socket = IO.io(
      ApiConstants.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/socket.io')
          .setAuth({'token': token})
          .enableForceNew()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .build(),
    );

    // Listen to ALL events for debugging
    socket.onAny((event, data) {
      print('🎯 SOCKET EVENT: $event');
      print('  Data: $data');
    });

    socket.onConnect((_) {
      _isConnected = true;
      _socketId = socket.id;
      print('✅ Socket connected: ${socket.id}');
      
      // Test ping to verify connection
      socket.emit('ping', {'test': 'connection'});
    });

    socket.onConnectError((err) {
      print('⚠️ Connect error: $err');
    });

    socket.onError((err) {
      print('❌ Socket error: $err');
    });

    socket.onDisconnect((_) {
      _isConnected = false;
      _socketId = null;
      print('❌ Socket disconnected');
    });

    socket.onReconnect((attempt) {
      print('🔄 Reconnecting... Attempt: $attempt');
    });
  }

  // ================= JOIN CONVERSATION =================
  void joinConversation(String conversationId) {
    if (!_isConnected) {
      print('⚠️ Cannot join conversation: Socket not connected');
      return;
    }

    print('🔗 Joining conversation: $conversationId');
    socket.emit('join_conversation', {'conversationId': conversationId});
  }

  // ================= SEND MESSAGE =================
  void sendMessageSocket({
    required String conversationId,
    required String senderId,
    required String message,
  }) {
    if (!_isConnected) {
      print('⚠️ Cannot send message: Socket not connected');
      return;
    }

    final messageData = {
      'conversationId': conversationId,
      'senderId': senderId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    };

    print('📤 EMITTING: send_message');
    print('  Socket ID: $_socketId');
    print('  Conversation ID: $conversationId');
    print('  Sender ID: $senderId');
    print('  Message: $message');
    
    socket.emit('send_message', messageData);
    print('📤 Message sent');
  }

  // ================= LISTEN FOR MESSAGES =================
  void listenMessagesSocket(Function(Map<String, dynamic>) onMessage) {
    socket.on('new_message', (data) {
      print('📩 INCOMING MESSAGE EVENT');
      print('  Raw data: $data');

      try {
        final parsed = Map<String, dynamic>.from(data);
        print('  Parsed message: ${parsed['message']}');
        print('  From: ${parsed['senderId']}');
        onMessage(parsed);
      } catch (e) {
        print('❌ Parse error: $e');
      }
    });
  }

  // ================= LISTEN FOR CONVERSATION CREATED =================
  void listenForConversationCreated(Function(Map<String, dynamic>) onConversationCreated) {
    socket.on('conversation_created', (data) {
      print('✨ CONVERSATION CREATED EVENT');
      print('  Data: $data');
      
      try {
        final parsed = Map<String, dynamic>.from(data);
        onConversationCreated(parsed);
      } catch (e) {
        print('❌ Parse error: $e');
      }
    });
  }

  // ================= DISCONNECT =================
  void disconnectSocket() {
    if (_isConnected) {
      print('🔌 Disconnecting socket...');
      socket.dispose();
      _isConnected = false;
      _socketId = null;
      print('✅ Socket disconnected');
    }
  }

  // ================= REST API METHODS =================
  Future<List<Map<String, dynamic>>> fetchConversations() async {
    try {
      print('📡 Fetching conversations...');
      final res = await dioClient.get(ApiConstants.chatConversations);
      
      if (res.data is List) {
        print('✅ Found ${res.data.length} conversations');
        return List<Map<String, dynamic>>.from(res.data);
      }
      return [];
    } catch (e) {
      print('❌ Error fetching conversations: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMessagesFromConversation(
    String conversationId,
  ) async {
    try {
      if (conversationId.startsWith('temp_')) {
        return [];
      }
      
      final conversations = await fetchConversations();
      final convo = conversations.firstWhere(
        (c) => c['id'] == conversationId,
        orElse: () => {},
      );
      
      return List<Map<String, dynamic>>.from(convo['messages'] ?? []);
    } catch (e) {
      print('❌ Error getting messages: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> findConversationBetweenUsers({
    required String userOneId,
    required String userTwoId,
  }) async {
    try {
      final conversations = await fetchConversations();
      
      for (final convo in conversations) {
        if ((convo['userOneId'] == userOneId && convo['userTwoId'] == userTwoId) ||
            (convo['userOneId'] == userTwoId && convo['userTwoId'] == userOneId)) {
          print('✅ Found existing conversation: ${convo['id']}');
          return convo;
        }
      }
      
      print('⚠️ No conversation found');
      return null;
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }

  bool get isConnected => _isConnected;
  String? get socketId => _socketId;
}