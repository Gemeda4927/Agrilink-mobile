import 'package:agrilink/features/chat/domain/entities/chat_conversation.dart';
import 'package:agrilink/features/chat/domain/entities/chat_message.dart';
import 'package:agrilink/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:agrilink/features/chat/presentation/bloc/chat_event.dart';
import 'package:agrilink/features/chat/presentation/bloc/chat_state.dart';
import 'package:agrilink/injector.dart';
import 'package:agrilink/core/network/token_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  ChatConversation? _selectedConversation;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final token = sl<TokenManager>().getToken();
    if (token != null) {
      context.read<ChatBloc>().add(ConnectSocketEvent(token));
    }

    // Load conversations
    context.read<ChatBloc>().add(LoadConversations());
  }

  @override
  void dispose() {
    context.read<ChatBloc>().add(DisconnectSocketEvent());
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (_selectedConversation == null || messageText.isEmpty) return;

    final senderId = _selectedConversation!.userTwo.id; // or your current user id
    context.read<ChatBloc>().add(
          SendMessageEvent(
            conversationId: _selectedConversation!.id,
            senderId: senderId,
            message: messageText,
          ),
        );

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
      ),
      body: Row(
        children: [
          // ================= Conversations List =================
          SizedBox(
            width: 250,
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChatConversationsLoaded) {
                  final conversations = state.conversations;
                  return ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conv = conversations[index];
                      return ListTile(
                        title: Text(conv.userTwo.profile?.fullName ?? "User"),
                        subtitle: Text(
                          conv.messages.isNotEmpty
                              ? conv.messages.last.message
                              : "No messages yet",
                        ),
                        selected: _selectedConversation?.id == conv.id,
                        onTap: () {
                          setState(() {
                            _selectedConversation = conv;
                          });
                          context
                              .read<ChatBloc>()
                              .add(LoadMessages(conv.id));
                        },
                      );
                    },
                  );
                } else if (state is ChatError) {
                  return Center(child: Text(state.message));
                } else {
                  return const Center(child: Text("No conversations"));
                }
              },
            ),
          ),

          const VerticalDivider(width: 1),

          // ================= Chat Messages =================
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      if (state is ChatLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is ChatMessagesLoaded) {
                        final messages = state.messages;
                        return ListView.builder(
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message =
                                messages[messages.length - 1 - index];
                            final isMe = message.senderId ==
                                _selectedConversation?.userTwo.id;
                            return Align(
                              alignment:
                                  isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? Colors.green[200]
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(message.message),
                              ),
                            );
                          },
                        );
                      } else if (state is ChatError) {
                        return Center(child: Text(state.message));
                      } else {
                        return const Center(child: Text("Select a conversation"));
                      }
                    },
                  ),
                ),

                // ================= Message Input =================
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: Colors.grey[200],
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: "Type a message...",
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.green),
                        onPressed: _sendMessage,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}