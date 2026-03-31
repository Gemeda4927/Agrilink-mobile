import 'dart:async';

import 'package:agrilink/features/auth/data/service/auth_service.dart';
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
  final String? conversationId;

  const ChatScreen({
    super.key,
    required this.receiverId,
    this.receiverName,
    this.receiverAvatar,
    this.conversationId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? currentUserId;
  String? activeConversationId;
  bool _isTyping = false;
  Timer? _typingTimer;
  bool _isLoadingConversations = true;

  // Reply state
  String? _replyToMessageId;
  String? _replyToContent;
  String? _replyToSenderId;

  late ChatBloc _chatBloc = sl<ChatBloc>();
  late AnimationController _typingAnimationController;

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _init();
  }

  // ================= INIT =================
  Future<void> _init() async {
    final auth = sl<AuthService>();
    final user = await auth.getLoggedInUser();

    if (user == null || !mounted) return;

    currentUserId = user.id;

    _chatBloc.add(ConnectChat(userId: user.id));
    _chatBloc.add(LoadConversations());
  }

  // ================= CHECK EXISTING CONVERSATION =================
  void _checkExistingConversation(List<ConversationModel> conversations) {
    if (!_isLoadingConversations) return;

    _isLoadingConversations = false;

    ConversationModel? existingConversation;
    for (var conv in conversations) {
      if (conv.otherUserId == widget.receiverId) {
        existingConversation = conv;
        break;
      }
    }

    if (existingConversation != null) {
      activeConversationId = existingConversation.id;
    } else if (widget.conversationId != null &&
        widget.conversationId!.isNotEmpty) {
      activeConversationId = widget.conversationId;
    } else {
      activeConversationId = _generateConversationId(
        currentUserId!,
        widget.receiverId,
      );
    }

    _chatBloc.add(SetCurrentConversation(activeConversationId!));
    _chatBloc.add(LoadChatHistory(activeConversationId!));
    _chatBloc.add(MarkConversationRead(activeConversationId!));
  }

  // ================= HELPER METHODS =================
  String _generateConversationId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${time.month}/${time.day}';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  // ================= MESSAGE ACTIONS =================
  void _sendMessage() {
    final text = _controller.text.trim();

    if (text.isEmpty || currentUserId == null) return;

    if (activeConversationId == null) {
      return;
    }

    // Create message with reply context
    String messageContent = text;
    if (_replyToMessageId != null && _replyToContent != null) {
      // You can format the message to include reply context
      // This will be handled in the UI when displaying
      messageContent = text;
    }

    _chatBloc.add(
      SendChatMessage(
        senderId: currentUserId!,
        receiverId: widget.receiverId,
        content: messageContent,
      ),
    );

    // Store reply info in local state for UI display
    // The actual reply relationship should be handled by your backend
    // For now, we'll just clear the reply state
    _controller.clear();
    _clearReply();
    _stopTyping();
    _scrollToBottomDelayed();
  }

  void _onReplyPressed(String messageId, String content, String senderId) {
    setState(() {
      _replyToMessageId = messageId;
      _replyToContent = content;
      _replyToSenderId = senderId;
    });
    // Focus on input field
    FocusScope.of(context).requestFocus(FocusNode());
    _scrollToBottom();
  }

  void _clearReply() {
    setState(() {
      _replyToMessageId = null;
      _replyToContent = null;
      _replyToSenderId = null;
    });
  }

  // ================= TYPING INDICATOR =================
  void _onTyping(String text) {
    if (!_isTyping && text.isNotEmpty) {
      _isTyping = true;
      _chatBloc.add(SendTyping(receiverId: widget.receiverId, isTyping: true));
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_isTyping) _stopTyping();
    });
  }

  void _stopTyping() {
    _isTyping = false;
    _chatBloc.add(SendTyping(receiverId: widget.receiverId, isTyping: false));
    _typingTimer?.cancel();
  }

  // ================= SCROLL =================
  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollToBottomDelayed() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _scrollToBottom();
    });
  }

  // ================= UI BUILDERS =================
  Widget _buildMessage(ChatMessageModel message, bool isMe) {
    // Check if this message is a reply (you'll need to add reply fields to your model)
    // For now, we'll show reply UI based on local state or backend data
    final bool hasReply =
        false; // Replace with actual reply check from your model

    return GestureDetector(
      onLongPress: () =>
          _onReplyPressed(message.id, message.content, message.senderId),
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: isMe ? 60 : 8,
          right: isMe ? 8 : 60,
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Text(
                  widget.receiverName ?? 'User',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            Material(
              elevation: 1,
              borderRadius: BorderRadius.circular(20),
              color: isMe ? const Color(0xFF00A884) : Colors.white,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasReply)
                      // ignore: dead_code
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.white.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isMe
                                ? Colors.white.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Replying to',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isMe
                                    ? Colors.white70
                                    : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Original message content', // Replace with actual reply content
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: isMe
                                    ? Colors.white70
                                    : Colors.grey.shade800,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.grey.shade900,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe ? Colors.white70 : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        _buildMessageStatus(message.status, isMe),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageStatus(String status, bool isMe) {
    if (!isMe) return const SizedBox.shrink();

    switch (status) {
      case 'sending':
        return const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          ),
        );
      case 'sent':
        return const Icon(Icons.check, size: 14, color: Colors.white70);
      case 'delivered':
        return const Icon(Icons.done_all, size: 14, color: Colors.white70);
      case 'read':
        return const Icon(Icons.done_all, size: 14, color: Color(0xFF53BDEB));
      case 'failed':
        return const Icon(Icons.error, size: 14, color: Colors.red);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildReplyBar() {
    if (_replyToMessageId == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: const Color(0xFF00A884), width: 4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${_replyToSenderId == currentUserId ? 'yourself' : widget.receiverName ?? 'message'}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _replyToContent ?? '',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _clearReply,
            icon: const Icon(Icons.close, size: 18),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildReplyBar(),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _controller,
                    onChanged: _onTyping,
                    onSubmitted: (_) => _sendMessage(),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: _replyToMessageId != null
                          ? "Reply..."
                          : "Message",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A884),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00A884).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _typingAnimationController,
                  builder: (context, child) {
                    return Row(
                      children: [
                        Transform.translate(
                          offset: Offset(
                            0,
                            -2 * _typingAnimationController.value,
                          ),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Transform.translate(
                          offset: Offset(
                            0,
                            -2 * _typingAnimationController.value,
                          ),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Transform.translate(
                          offset: Offset(
                            0,
                            -2 * _typingAnimationController.value,
                          ),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'typing',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= DISPOSE =================
  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    _typingAnimationController.dispose();

    if (mounted && !_chatBloc.isClosed) {
      _chatBloc.add(ClearCurrentConversation());
    }

    super.dispose();
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
      ),
      title: BlocBuilder<ChatBloc, ChatState>(
        bloc: _chatBloc,
        builder: (context, state) {
          String title = widget.receiverName ?? "Chat";
          bool isTyping = false;

          if (state is ChatConnected) {
            isTyping = state.typingUsers[widget.receiverId] == true;

            if (state.currentConversationId != null &&
                state.currentConversationId != activeConversationId) {
              activeConversationId = state.currentConversationId;
            }
          }

          return Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: widget.receiverAvatar != null
                    ? NetworkImage(widget.receiverAvatar!)
                    : null,
                child: widget.receiverAvatar == null
                    ? Text(
                        title[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (isTyping)
                      Text(
                        'typing...',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF00A884),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        BlocBuilder<ChatBloc, ChatState>(
          bloc: _chatBloc,
          builder: (context, state) {
            bool isConnected = state is ChatConnected && state.isConnected;

            return Container(
              margin: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isConnected
                          ? const Color(0xFF00A884)
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isConnected ? 'Online' : 'Offline',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return BlocConsumer<ChatBloc, ChatState>(
      bloc: _chatBloc,
      listenWhen: (previous, current) {
        if (current is ChatConnected && _isLoadingConversations) {
          _checkExistingConversation(current.conversations);
        }

        if (current is ChatError &&
            current.type == 'load_history' &&
            current.error.contains('404')) {
          return false;
        }
        return current is ChatError;
      },
      listener: (context, state) {
        if (state is ChatError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ChatLoading || state is ChatConnecting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00A884)),
                ),
                SizedBox(height: 16),
                Text('Connecting...'),
              ],
            ),
          );
        }

        if (state is ChatError &&
            !(state.type == 'load_history' && state.error.contains('404'))) {
          return _buildErrorState(state);
        }

        if (state is ChatConnected) {
          return _buildChatUI(state);
        }

        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00A884)),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(ChatError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load chat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.error,
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (currentUserId != null) {
                _chatBloc.add(ConnectChat(userId: currentUserId!));
                _chatBloc.add(LoadConversations());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A884),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatUI(ChatConnected state) {
    final messages = state.messages;
    final isTyping = state.typingUsers[widget.receiverId] == true;

    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;
                    return _buildMessage(message, isMe);
                  },
                ),
        ),
        if (isTyping) _buildAnimatedTypingIndicator(),
        _buildInputField(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No messages yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start chatting with ${widget.receiverName ?? 'user'} 👋",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
