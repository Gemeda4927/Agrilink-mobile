import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatConnecting extends ChatState {
  const ChatConnecting();
}

class ChatConnected extends ChatState {
  final List<ChatMessageModel> messages;
  final List<ConversationModel> conversations;
  final bool isConnected;
  final String? currentConversationId;
  final Map<String, bool> typingUsers;
  final Map<String, String> messageStatuses;

  const ChatConnected({
    required this.messages,
    required this.conversations,
    required this.isConnected,
    this.currentConversationId,
    this.typingUsers = const {},
    this.messageStatuses = const {},
  });

  @override
  List<Object?> get props => [
    messages,
    conversations,
    isConnected,
    currentConversationId,
    typingUsers,
    messageStatuses,
  ];

  ChatConnected copyWith({
    List<ChatMessageModel>? messages,
    List<ConversationModel>? conversations,
    bool? isConnected,
    String? currentConversationId,
    Map<String, bool>? typingUsers,
    Map<String, String>? messageStatuses,
  }) {
    return ChatConnected(
      messages: messages ?? this.messages,
      conversations: conversations ?? this.conversations,
      isConnected: isConnected ?? this.isConnected,
      currentConversationId:
          currentConversationId ?? this.currentConversationId,
      typingUsers: typingUsers ?? this.typingUsers,
      messageStatuses: messageStatuses ?? this.messageStatuses,
    );
  }
}

class ChatDisconnected extends ChatState {
  const ChatDisconnected();
}

class ChatError extends ChatState {
  final String error;
  final String? type;

  const ChatError({required this.error, this.type});

  @override
  List<Object?> get props => [error, type];
}

// Models
class ChatMessageModel {
  final String id;
  final String content;
  final String senderId;
  final String receiverId;
  final String conversationId;
  final DateTime createdAt;
  String status;
  final bool isPending;
  final String? tempId;

  ChatMessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.receiverId,
    required this.conversationId,
    required this.createdAt,
    this.status = 'sending',
    this.isPending = false,
    this.tempId,
  });

  ChatMessageModel copyWith({
    String? id,
    String? content,
    String? senderId,
    String? receiverId,
    String? conversationId,
    DateTime? createdAt,
    String? status,
    bool? isPending,
    String? tempId,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      conversationId: conversationId ?? this.conversationId,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      isPending: isPending ?? this.isPending,
      tempId: tempId ?? this.tempId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': content,
      'senderId': senderId,
      'receiverId': receiverId,
      'conversationId': conversationId,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory ChatMessageModel.fromJson(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      content: json['message'] ?? json['content'] ?? '',
      senderId: json['senderId']?.toString() ?? '',
      receiverId: json['receiverId']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      status: json['status'] ?? 'delivered',
      isPending: json['pending'] ?? false,
      tempId: json['tempId'],
    );
  }
}

class ConversationModel {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  ConversationModel({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromJson(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    final isUserOne = json['userOne']['id'] == currentUserId;
    final otherUser = isUserOne ? json['userTwo'] : json['userOne'];
    final otherUserName =
        otherUser['profile']?['fullName'] ?? otherUser['email'] ?? 'Unknown';
    final otherUserId = otherUser['id'];

    String? lastMessage;
    DateTime? lastMessageTime;

    if (json['messages'] != null && json['messages'].isNotEmpty) {
      final lastMsg = json['messages'].last;
      lastMessage = lastMsg['message'];
      lastMessageTime = DateTime.parse(lastMsg['createdAt']);
    }

    return ConversationModel(
      id: json['id'],
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
    );
  }
}
