import 'dart:async';
import 'package:agrilink/features/chat/presentation/bloc/chat_event.dart';
import 'package:agrilink/features/chat/presentation/bloc/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrilink/features/chat/domain/usecases/chat_usecases.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatUseCases useCases;

  String? _currentUserId;
  String? _currentConversationId;
  final Map<String, List<ChatMessageModel>> _conversationMessages = {};
  final List<ConversationModel> _conversations = [];
  final Map<String, bool> _typingUsers = {};
  final Map<String, String> _messageStatuses = {};

  StreamSubscription? _messageSubscription;
  StreamSubscription? _messageSentSubscription;
  StreamSubscription? _messageDeliveredSubscription;
  StreamSubscription? _messageReadSubscription;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _errorSubscription;
  StreamSubscription? _connectionSubscription;

  ChatBloc({required this.useCases}) : super(const ChatInitial()) {
    on<ConnectChat>(_onConnect);
    on<DisconnectChat>(_onDisconnect);
    on<SendChatMessage>(_onSendMessage);
    on<IncomingMessage>(_onIncomingMessage);
    on<MessageSent>(_onMessageSent);
    on<MessageDelivered>(_onMessageDelivered);
    on<MessageRead>(_onMessageRead);
    on<SendTyping>(_onSendTyping);
    on<UserTyping>(_onUserTyping);
    on<SetCurrentConversation>(_onSetCurrentConversation);
    on<ClearCurrentConversation>(_onClearCurrentConversation);
    on<MarkConversationRead>(_onMarkConversationRead);
    on<LoadChatHistory>(_onLoadHistory);
    on<LoadConversations>(_onLoadConversations);
    on<ChatErrorEvent>(_onChatError);
  }

  // ================= CONNECTION =================
  Future<void> _onConnect(ConnectChat event, Emitter<ChatState> emit) async {
    if (_currentUserId != null) return;

    emit(const ChatConnecting());

    _currentUserId = event.userId;
    useCases.connect(event.userId);

    // Setup listeners
    await _setupListeners();

    // Load conversations
    add(LoadConversations());
  }

  Future<void> _setupListeners() async {
    // Cancel existing subscriptions
    await _cancelSubscriptions();

    // Listen for new messages
    _messageSubscription = useCases.messages.listen((msg) {
      add(IncomingMessage(msg));
    });

    // Listen for message sent confirmations
    _messageSentSubscription = useCases.messageSent.listen((data) {
      add(MessageSent(data));
    });

    // Listen for message delivered confirmations
    _messageDeliveredSubscription = useCases.messageDelivered.listen((data) {
      add(MessageDelivered(data));
    });

    // Listen for message read confirmations
    _messageReadSubscription = useCases.messageRead.listen((data) {
      add(MessageRead(data));
    });

    // Listen for typing indicators
    _typingSubscription = useCases.typing.listen((data) {
      if (data['senderId'] != _currentUserId) {
        add(UserTyping(userId: data['senderId'], isTyping: data['isTyping']));
      }
    });

    // Listen for connection status
    _connectionSubscription = useCases.connectionStatus.listen((isConnected) {
      if (state is ChatConnected) {
        final currentState = state as ChatConnected;
        emit(currentState.copyWith(isConnected: isConnected));
      }
    });

    // Listen for errors
    _errorSubscription = useCases.errors.listen((error) {
      add(
        ChatErrorEvent(
          error: error['error'] ?? 'Unknown error',
          type: error['type'],
        ),
      );
    });
  }

  // ================= LOAD CONVERSATIONS =================
  // ================= LOAD CONVERSATIONS =================
  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final conversationsData = await useCases.getConversations();

      _conversations.clear();
      for (final conv in conversationsData) {
        _conversations.add(ConversationModel.fromJson(conv, _currentUserId!));

        // Store messages for each conversation
        final messagesList = conv['messages'] as List? ?? [];
        final messages = messagesList.map((msg) {
          return ChatMessageModel.fromJson(msg, _currentUserId!);
        }).toList();

        // Store in memory
        _conversationMessages[conv['id']] = messages;
      }

      if (state is ChatConnected) {
        final currentState = state as ChatConnected;
        emit(
          currentState.copyWith(
            conversations: List.from(_conversations),
            isConnected: useCases.isConnected,
          ),
        );
      } else {
        emit(
          ChatConnected(
            messages: _conversationMessages[_currentConversationId] ?? [],
            conversations: List.from(_conversations),
            isConnected: useCases.isConnected,
            currentConversationId: _currentConversationId,
          ),
        );
      }
    } catch (e) {
      add(ChatErrorEvent(error: e.toString(), type: 'load_conversations'));
    }
  }

  // ================= LOAD HISTORY =================
  Future<void> _onLoadHistory(
    LoadChatHistory event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // First check if we already have messages in memory
      if (_conversationMessages.containsKey(event.conversationId)) {
        final messages = _conversationMessages[event.conversationId] ?? [];

        if (state is ChatConnected &&
            _currentConversationId == event.conversationId) {
          final currentState = state as ChatConnected;
          emit(currentState.copyWith(messages: messages));
        }
        return;
      }

      // If not in memory, try to fetch from API
      final messagesData = await useCases.getMessages(event.conversationId);

      final messages = messagesData.map((msg) {
        return ChatMessageModel.fromJson(msg, _currentUserId!);
      }).toList();

      _conversationMessages[event.conversationId] = messages;

      if (state is ChatConnected &&
          _currentConversationId == event.conversationId) {
        final currentState = state as ChatConnected;
        emit(currentState.copyWith(messages: messages));
      }
    } catch (e) {
      // If we get 404, it's okay - just means no messages
      if (e.toString().contains('404') || e.toString().contains('Not Found')) {
        print('📭 No messages found for conversation ${event.conversationId}');
        _conversationMessages[event.conversationId] = [];

        if (state is ChatConnected &&
            _currentConversationId == event.conversationId) {
          final currentState = state as ChatConnected;
          emit(currentState.copyWith(messages: []));
        }
      } else {
        add(ChatErrorEvent(error: e.toString(), type: 'load_history'));
      }
    }
  }

  // ================= SEND MESSAGE =================
  Future<void> _onSendMessage(
    SendChatMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentConversationId == null) {
      add(
        ChatErrorEvent(error: 'No active conversation', type: 'send_message'),
      );
      return;
    }

    final tempId =
        event.tempId ?? DateTime.now().millisecondsSinceEpoch.toString();

    // Create temporary message
    final tempMessage = ChatMessageModel(
      id: tempId,
      content: event.content,
      senderId: event.senderId,
      receiverId: event.receiverId,
      conversationId: _currentConversationId!,
      createdAt: DateTime.now(),
      status: 'sending',
      isPending: true,
      tempId: tempId,
    );

    // Add to messages list
    final currentMessages = _getCurrentMessages();
    currentMessages.insert(0, tempMessage);
    _conversationMessages[_currentConversationId!] = currentMessages;
    _messageStatuses[tempId] = 'sending';

    if (state is ChatConnected) {
      final currentState = state as ChatConnected;
      emit(
        currentState.copyWith(
          messages: List.from(currentMessages),
          messageStatuses: Map.from(_messageStatuses),
        ),
      );
    }

    // Send message
    useCases.sendMessage(
      senderId: event.senderId,
      receiverId: event.receiverId,
      content: event.content,
      tempId: tempId,
    );

    // Update conversation list (update last message)
    _updateConversationLastMessage(_currentConversationId!, event.content);
    add(LoadConversations());
  }

  // ================= INCOMING MESSAGE =================
  void _onIncomingMessage(IncomingMessage event, Emitter<ChatState> emit) {
    final message = event.message;
    final conversationId =
        message['conversationId']?.toString() ??
        message['conversation']['id']?.toString();

    if (conversationId == null) return;

    final newMessage = ChatMessageModel.fromJson(message, _currentUserId!);

    // Add to conversation messages
    final conversationMessages = _conversationMessages[conversationId] ?? [];
    conversationMessages.insert(0, newMessage);
    _conversationMessages[conversationId] = conversationMessages;

    // Update conversation list
    _updateConversationLastMessage(conversationId, newMessage.content);
    add(LoadConversations());

    // If this is the current conversation, update UI
    if (_currentConversationId == conversationId && state is ChatConnected) {
      final currentState = state as ChatConnected;
      emit(currentState.copyWith(messages: List.from(conversationMessages)));

      // Mark as read if it's the current conversation
      if (newMessage.senderId != _currentUserId) {
        useCases.markMessageAsRead(newMessage.id, conversationId);
      }
    }
  }

  // ================= MESSAGE SENT CONFIRMATION =================
  void _onMessageSent(MessageSent event, Emitter<ChatState> emit) {
    final data = event.data;
    final tempId = data['tempId'];
    final messageId = data['messageId'];
    final conversationId = data['conversationId'];

    print(
      '📨 Message sent confirmation - tempId: $tempId, messageId: $messageId, conversationId: $conversationId',
    );

    // 🔥 CRITICAL: Update the current conversation ID if it's different
    if (conversationId != null && conversationId != _currentConversationId) {
      print(
        '🔄 Updating conversation ID from $_currentConversationId to $conversationId',
      );

      // Move messages from old temp conversation ID to real one
      if (_currentConversationId != null) {
        final oldMessages = _conversationMessages.remove(
          _currentConversationId,
        );
        if (oldMessages != null) {
          _conversationMessages[conversationId] = oldMessages;
        }
      }

      _currentConversationId = conversationId;

      // Update use case with real conversation ID
      useCases.setCurrentConversation(conversationId);

      // Emit state update with new conversation ID
      if (state is ChatConnected) {
        final currentState = state as ChatConnected;
        emit(currentState.copyWith(currentConversationId: conversationId));
      }
    }

    // Update message status in the conversation messages
    final activeConversationId = conversationId ?? _currentConversationId;
    final messages = _conversationMessages[activeConversationId!] ?? [];
    final index = messages.indexWhere(
      (msg) => msg.tempId == tempId || msg.id == tempId,
    );

    if (index != -1) {
      print(
        '✅ Found message at index $index, updating status from ${messages[index].status} to sent',
      );

      messages[index] = messages[index].copyWith(
        id: messageId,
        status: 'sent',
        isPending: false,
        tempId: null,
      );

      _conversationMessages[activeConversationId] = messages;
      _messageStatuses.remove(tempId);
      _messageStatuses[messageId] = 'sent';

      if (_currentConversationId == activeConversationId &&
          state is ChatConnected) {
        final currentState = state as ChatConnected;
        emit(
          currentState.copyWith(
            messages: List.from(messages),
            messageStatuses: Map.from(_messageStatuses),
          ),
        );
        print('✅ UI updated with sent status');
      }
    } else {
      print('⚠️ Message not found for tempId: $tempId');
    }
  }

  // ================= MESSAGE DELIVERED =================
  void _onMessageDelivered(MessageDelivered event, Emitter<ChatState> emit) {
    final data = event.data;
    final messageId = data['messageId'];
    final conversationId = data['conversationId'];

    print('📨 Message delivered confirmation - messageId: $messageId');

    final messages = _conversationMessages[conversationId] ?? [];
    final index = messages.indexWhere((msg) => msg.id == messageId);

    if (index != -1 && messages[index].senderId == _currentUserId) {
      print('✅ Updating message $messageId status to delivered');

      messages[index] = messages[index].copyWith(status: 'delivered');
      _conversationMessages[conversationId] = messages;
      _messageStatuses[messageId] = 'delivered';

      if (_currentConversationId == conversationId && state is ChatConnected) {
        final currentState = state as ChatConnected;
        emit(
          currentState.copyWith(
            messages: List.from(messages),
            messageStatuses: Map.from(_messageStatuses),
          ),
        );
      }
    }
  }

  // ================= MESSAGE READ =================
  void _onMessageRead(MessageRead event, Emitter<ChatState> emit) {
    final data = event.data;
    final messageId = data['messageId'];
    final conversationId = data['conversationId'];

    print('📨 Message read confirmation - messageId: $messageId');

    final messages = _conversationMessages[conversationId] ?? [];
    final index = messages.indexWhere((msg) => msg.id == messageId);

    if (index != -1 && messages[index].senderId == _currentUserId) {
      print('✅ Updating message $messageId status to read');

      messages[index] = messages[index].copyWith(status: 'read');
      _conversationMessages[conversationId] = messages;
      _messageStatuses[messageId] = 'read';

      if (_currentConversationId == conversationId && state is ChatConnected) {
        final currentState = state as ChatConnected;
        emit(
          currentState.copyWith(
            messages: List.from(messages),
            messageStatuses: Map.from(_messageStatuses),
          ),
        );
      }
    }
  }

  // ================= TYPING =================
  void _onSendTyping(SendTyping event, Emitter<ChatState> emit) {
    useCases.sendTyping(event.receiverId, event.isTyping);
  }

  void _onUserTyping(UserTyping event, Emitter<ChatState> emit) {
    _typingUsers[event.userId] = event.isTyping;

    if (state is ChatConnected) {
      final currentState = state as ChatConnected;
      emit(currentState.copyWith(typingUsers: Map.from(_typingUsers)));
    }
  }

  // ================= CONVERSATION MANAGEMENT =================
  void _onSetCurrentConversation(
    SetCurrentConversation event,
    Emitter<ChatState> emit,
  ) {
    _currentConversationId = event.conversationId;
    useCases.setCurrentConversation(event.conversationId);

    // Load messages for this conversation
    add(LoadChatHistory(event.conversationId));

    // Mark conversation as read
    useCases.markConversationAsRead(event.conversationId);
  }

  void _onClearCurrentConversation(
    ClearCurrentConversation event,
    Emitter<ChatState> emit,
  ) {
    _currentConversationId = null;
    useCases.clearCurrentConversation();
  }

  void _onMarkConversationRead(
    MarkConversationRead event,
    Emitter<ChatState> emit,
  ) {
    useCases.markConversationAsRead(event.conversationId);
  }

  // ================= ERROR HANDLING =================
  void _onChatError(ChatErrorEvent event, Emitter<ChatState> emit) {
    emit(ChatError(error: event.error, type: event.type));
  }

  // ================= DISCONNECT =================
  Future<void> _onDisconnect(
    DisconnectChat event,
    Emitter<ChatState> emit,
  ) async {
    await _cancelSubscriptions();
    useCases.disconnect();

    _currentUserId = null;
    _currentConversationId = null;
    _conversationMessages.clear();
    _conversations.clear();
    _typingUsers.clear();
    _messageStatuses.clear();

    emit(const ChatDisconnected());
  }

  // ================= HELPER METHODS =================
  List<ChatMessageModel> _getCurrentMessages() {
    if (_currentConversationId == null) return [];
    return _conversationMessages[_currentConversationId!] ?? [];
  }

  void _updateConversationLastMessage(String conversationId, String message) {
    final conversationIndex = _conversations.indexWhere(
      (c) => c.id == conversationId,
    );
    if (conversationIndex != -1) {
      _conversations[conversationIndex] = ConversationModel(
        id: _conversations[conversationIndex].id,
        otherUserId: _conversations[conversationIndex].otherUserId,
        otherUserName: _conversations[conversationIndex].otherUserName,
        lastMessage: message,
        lastMessageTime: DateTime.now(),
        unreadCount: _conversations[conversationIndex].unreadCount,
      );
    }
  }

  Future<void> _cancelSubscriptions() async {
    await _messageSubscription?.cancel();
    await _messageSentSubscription?.cancel();
    await _messageDeliveredSubscription?.cancel();
    await _messageReadSubscription?.cancel();
    await _typingSubscription?.cancel();
    await _errorSubscription?.cancel();
    await _connectionSubscription?.cancel();
  }

  @override
  Future<void> close() async {
    await _cancelSubscriptions();
    useCases.disconnect();
    super.close();
  }
}
