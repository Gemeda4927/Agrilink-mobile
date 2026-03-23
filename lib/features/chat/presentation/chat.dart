// lib/features/chat/presentation/chat.dart

import 'package:agrilink/core/network/token_manager.dart';
import 'package:agrilink/features/auth/data/service/auth_service.dart';
import 'package:agrilink/features/chat/domain/entities/chat_message.dart';
import 'package:agrilink/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:agrilink/features/chat/presentation/bloc/chat_event.dart';
import 'package:agrilink/features/chat/presentation/bloc/chat_state.dart';
import 'package:agrilink/injector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String? receiverName;
  final String? receiverAvatar;

  const ChatScreen({
    super.key,
    required this.receiverId,
    this.receiverName,
    this.receiverAvatar,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> messages = [];
  String? conversationId;
  String? currentUserId;
  bool _isSocketConnected = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    try {
      final authService = sl<AuthService>();
      final user = await authService.getLoggedInUser();

      if (user != null && mounted) {
        setState(() {
          currentUserId = user.id;
        });
        _connectSocket();
      }
    } catch (e) {
      print('❌ Error getting user: $e');
    }
  }

  void _connectSocket() {
    final token = sl<TokenManager>().getToken();
    if (token != null) {
      context.read<ChatBloc>().add(ConnectSocketEvent(token));
    }
  }

  void _getOrCreateConversation() {
    if (currentUserId == null || !_isSocketConnected) return;

    context.read<ChatBloc>().add(
      GetOrCreateConversationEvent(
        userOneId: currentUserId!,
        userTwoId: widget.receiverId,
        receiverName: widget.receiverName,
      ),
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || conversationId == null || currentUserId == null) return;

    // Add message locally for instant feedback
    final tempMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId!,
      senderId: currentUserId!,
      message: text,
      createdAt: DateTime.now(),
    );

    setState(() {
      messages = [tempMessage, ...messages];
    });

    context.read<ChatBloc>().add(
      SendMessageEvent(
        conversationId: conversationId!,
        senderId: currentUserId!,
        message: text,
      ),
    );

    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (widget.receiverAvatar != null)
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(widget.receiverAvatar!),
              ),
            if (widget.receiverAvatar != null) const SizedBox(width: 10),
            Text(widget.receiverName ?? 'User'),
          ],
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (conversationId != null &&
                  !conversationId!.startsWith('temp_')) {
                context.read<ChatBloc>().add(LoadMessages(conversationId!));
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatSocketConnected) {
            setState(() {
              _isSocketConnected = true;
              _isLoading = false;
            });
            _getOrCreateConversation();
          }

          if (state is ChatConversationFound) {
            setState(() {
              conversationId = state.conversation.id;
              _isLoading = false;
            });

            if (!conversationId!.startsWith('temp_')) {
              context.read<ChatBloc>().add(
                JoinConversationEvent(conversationId!),
              );
            }
            context.read<ChatBloc>().add(LoadMessages(conversationId!));
          }

          if (state is ChatMessagesLoaded) {
            setState(() {
              final existingIds = messages.map((m) => m.id).toSet();
              final newMessages = state.messages
                  .where((m) => !existingIds.contains(m.id))
                  .toList();
              messages = [...newMessages, ...messages];
            });
            _scrollToBottom();
          }

          if (state is ChatMessageReceived) {
            final exists = messages.any((m) => m.id == state.message.id);
            if (!exists) {
              setState(() {
                messages = [state.message, ...messages];
              });
              _scrollToBottom();
            }
          }

          if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (currentUserId == null || _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!_isSocketConnected) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Connecting...'),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(child: _buildMessages()),
              _buildInput(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessages() {
    if (messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("No messages yet", style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
            Text(
              "Send a message to start chatting",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isMe = msg.senderId == currentUserId;
        return _buildMessageBubble(msg, isMe);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe ? Colors.green : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.green,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
