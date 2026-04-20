import 'package:agrilink/features/recommendation/domain/entity/chat_message_entity.dart';
import 'package:agrilink/features/recommendation/domain/usecase/send_chat_message_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'package:agrilink/features/recommendation/presentation/bloc/chat_bloc.dart';
import 'package:agrilink/features/recommendation/presentation/bloc/chat_event.dart';
import 'package:agrilink/features/recommendation/presentation/bloc/chat_state.dart';
import 'package:agrilink/features/recommendation/domain/entity/chat_response_entity.dart';
import 'package:agrilink/features/recommendation/domain/entity/agent_breakdown_entity.dart';
import 'package:agrilink/injector.dart' as di;

class AIChatbotFAB extends StatefulWidget {
  const AIChatbotFAB({super.key});

  @override
  State<AIChatbotFAB> createState() => _AIChatbotFABState();
}

class _AIChatbotFABState extends State<AIChatbotFAB>
    with TickerProviderStateMixin {  // ✅ Changed to TickerProviderStateMixin
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for attention
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Subtle rotation animation
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
    
    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _showChatbotModal(BuildContext context) {
    _pulseController.stop();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => BlocProvider.value(
        value: _getChatBloc(),
        child: const AIChatbotModal(),
      ),
    ).then((_) {
      // Resume animation when modal is closed
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  ChatBloc2 _getChatBloc() {
    try {
      return di.sl<ChatBloc2>();
    } catch (e) {
      final useCase = di.sl<SendChatMessageUseCase2>();
      return ChatBloc2(sendMessageUseCase: useCase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotateController]),
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotateAnimation.value,
          child: Transform.scale(
            scale: _isPressed ? 0.9 : _pulseAnimation.value,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  // Outer glow
                  BoxShadow(
                    color: const Color(0xFF1A8C3F).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: _pulseAnimation.value * 2 - 1,
                  ),
                  // Inner shadow for depth
                  BoxShadow(
                    color: const Color(0xFF1A8C3F).withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                  // Drop shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTapDown: (_) {
                    setState(() => _isPressed = true);
                  },
                  onTapUp: (_) {
                    setState(() => _isPressed = false);
                    _showChatbotModal(context);
                  },
                  onTapCancel: () {
                    setState(() => _isPressed = false);
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF4CAF50),
                          Color(0xFF2E7D32),
                          Color(0xFF1B5E20),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Shine effect
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                        // Premium Robot Icon
                        _buildPremiumRobotIcon(),
                        // Animated ring
                        CustomPaint(
                          painter: _RingPainter(
                            progress: _pulseAnimation.value - 1.0,
                          ),
                          size: const Size(60, 60),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumRobotIcon() {
    return CustomPaint(
      painter: _PremiumRobotPainter(),
      size: const Size(32, 32),
    );
  }
}

// Premium Robot Icon Painter
class _PremiumRobotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final centerX = width / 2;
    final centerY = height / 2;

    // Main body paint
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Color(0xFFE0E0E0)],
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.fill;

    // Stroke paint
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Shadow paint
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // Robot head (rounded rectangle)
    final headRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY - 2),
        width: width * 0.6,
        height: height * 0.5,
      ),
      Radius.circular(width * 0.1),
    );

    // Draw shadow
    canvas.drawRRect(
      headRect.shift(const Offset(0, 1)),
      shadowPaint,
    );

    // Draw head
    canvas.drawRRect(headRect, bodyPaint);
    canvas.drawRRect(headRect, strokePaint);

    // Antenna
    final antennaPath = Path()
      ..moveTo(centerX, centerY - height * 0.25)
      ..lineTo(centerX, centerY - height * 0.38);
    
    canvas.drawPath(antennaPath, strokePaint);
    
    // Antenna ball with gradient
    final antennaBallPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
      ).createShader(Rect.fromCircle(
        center: Offset(centerX, centerY - height * 0.4),
        radius: width * 0.07,
      ));
    
    canvas.drawCircle(
      Offset(centerX, centerY - height * 0.4),
      width * 0.07,
      antennaBallPaint,
    );
    
    canvas.drawCircle(
      Offset(centerX, centerY - height * 0.4),
      width * 0.07,
      strokePaint,
    );

    // Eyes with glow
    final eyeGlowPaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(
      Offset(centerX - width * 0.12, centerY - height * 0.05),
      width * 0.07,
      eyeGlowPaint,
    );
    
    canvas.drawCircle(
      Offset(centerX + width * 0.12, centerY - height * 0.05),
      width * 0.07,
      eyeGlowPaint,
    );

    // Eyes
    final eyePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4CAF50), Color(0xFF1B5E20)],
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawCircle(
      Offset(centerX - width * 0.12, centerY - height * 0.05),
      width * 0.06,
      eyePaint,
    );
    
    canvas.drawCircle(
      Offset(centerX + width * 0.12, centerY - height * 0.05),
      width * 0.06,
      eyePaint,
    );

    // Eye shine
    canvas.drawCircle(
      Offset(centerX - width * 0.14, centerY - height * 0.07),
      width * 0.02,
      Paint()..color = Colors.white,
    );
    
    canvas.drawCircle(
      Offset(centerX + width * 0.10, centerY - height * 0.07),
      width * 0.02,
      Paint()..color = Colors.white,
    );

    // Smile
    final smilePath = Path()
      ..moveTo(centerX - width * 0.1, centerY + height * 0.05)
      ..quadraticBezierTo(
        centerX,
        centerY + height * 0.13,
        centerX + width * 0.1,
        centerY + height * 0.05,
      );
    
    canvas.drawPath(smilePath, strokePaint);

    // Ears
    final earPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE0E0E0), Colors.white],
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    // Left ear
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX - width * 0.3, centerY - 2),
          width: width * 0.1,
          height: height * 0.15,
        ),
        Radius.circular(width * 0.03),
      ),
      earPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX - width * 0.3, centerY - 2),
          width: width * 0.1,
          height: height * 0.15,
        ),
        Radius.circular(width * 0.03),
      ),
      strokePaint,
    );

    // Right ear
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX + width * 0.3, centerY - 2),
          width: width * 0.1,
          height: height * 0.15,
        ),
        Radius.circular(width * 0.03),
      ),
      earPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX + width * 0.3, centerY - 2),
          width: width * 0.1,
          height: height * 0.15,
        ),
        Radius.circular(width * 0.03),
      ),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Animated ring painter
class _RingPainter extends CustomPainter {
  final double progress;

  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 + 4;

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3 * (1 - progress))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, paint);

    final dashPaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.5 * (1 - progress))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final dashPath = Path();
    final dashCount = 8;
    final dashLength = (2 * math.pi * radius) / (dashCount * 2);

    for (int i = 0; i < dashCount * 2; i += 2) {
      final startAngle = (i * dashLength / radius) + (progress * math.pi);
      final sweepAngle = dashLength / radius;

      for (int j = 0; j < 360; j += 45) {
        dashPath.addArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle + (j * math.pi / 180),
          sweepAngle,
        );
      }
    }

    canvas.drawPath(dashPath, dashPaint);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

// Chatbot Modal Bottom Sheet
class AIChatbotModal extends StatefulWidget {
  const AIChatbotModal({super.key});

  @override
  State<AIChatbotModal> createState() => _AIChatbotModalState();
}

class _AIChatbotModalState extends State<AIChatbotModal> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final List<ChatMessage> _messages = [];
  String? _lastUserMessage;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      isUser: false,
      text: "👋 Hello! I'm your AI Crop Advisor. I can help you with:\n\n🌱 Crop recommendations\n🌍 Soil health advice\n🐛 Pest management\n🌦️ Weather planning\n\nWhat would you like to know?",
      timestamp: DateTime.now(),
    ));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _lastUserMessage = text;
    
    setState(() {
      _messages.add(ChatMessage(
        isUser: true,
        text: text,
        timestamp: DateTime.now(),
      ));
    });

    _controller.clear();
    _focusNode.requestFocus();
    _scrollToBottom();

    context.read<ChatBloc2>().add(SendMessageEvent(message: text));
  }

  void _retryLastMessage() {
    if (_lastUserMessage != null) {
      context.read<ChatBloc2>().add(RetryLastMessageEvent(message: _lastUserMessage!));
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _addWelcomeMessage();
    });
    context.read<ChatBloc2>().add(ClearChatEvent());
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: BlocConsumer<ChatBloc2, ChatState2>(
              listener: (context, state) {
                if (state is ChatLoaded) {
                  setState(() {
                    _messages.add(ChatMessage(
                      isUser: false,
                      text: state.response.response,
                      timestamp: DateTime.now(),
                      responseEntity: state.response,
                    ));
                  });
                  _scrollToBottom();
                } else if (state is ChatError) {
                  setState(() {
                    _messages.add(ChatMessage(
                      isUser: false,
                      text: "❌ ${state.message}",
                      timestamp: DateTime.now(),
                      isError: true,
                    ));
                  });
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                return _buildChatArea(state);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header content
          Row(
            children: [
              // Premium Robot Avatar
              Stack(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A8C3F).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: CustomPaint(
                        painter: _PremiumRobotPainter(),
                        size: const Size(28, 28),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2.5,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Crop Advisor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4CAF50).withOpacity(0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Online • Powered by AI',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action buttons
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _clearChat,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.grey.shade600,
                        size: 22,
                      ),
                      tooltip: 'Clear chat',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.grey.shade600,
                        size: 22,
                      ),
                      tooltip: 'Close',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea(ChatState2 state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: _messages.length + (state is ChatLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (state is ChatLoading && index == _messages.length) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Column(
      crossAxisAlignment: message.isUser 
          ? CrossAxisAlignment.end 
          : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(bottom: message.isUser ? 16 : 8),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            child: Column(
              crossAxisAlignment:
                  message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: message.isUser
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                          )
                        : null,
                    color: message.isUser 
                        ? null 
                        : message.isError 
                            ? Colors.red.shade50 
                            : Colors.grey.shade50,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(22),
                      topRight: const Radius.circular(22),
                      bottomLeft: Radius.circular(message.isUser ? 22 : 6),
                      bottomRight: Radius.circular(message.isUser ? 6 : 22),
                    ),
                    boxShadow: message.isUser
                        ? [
                            BoxShadow(
                              color: const Color(0xFF2E7D32).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : message.isError
                            ? [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                    border: message.isError && !message.isUser
                        ? Border.all(color: Colors.red.shade200)
                        : null,
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.45,
                      color: message.isUser 
                          ? Colors.white 
                          : message.isError 
                              ? Colors.red.shade700 
                              : const Color(0xFF2C2C2C),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 10, right: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (message.isError && !message.isUser) ...[
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _retryLastMessage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.refresh_rounded,
                                  size: 12,
                                  color: Colors.green.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Retry',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!message.isUser && message.responseEntity != null) ...[
          if (message.responseEntity!.agentBreakdown.isNotEmpty)
            _buildAgentBreakdown(message.responseEntity!.agentBreakdown),
          if (message.responseEntity!.followUpQuestions.isNotEmpty)
            _buildFollowUpQuestions(message.responseEntity!.followUpQuestions),
        ],
      ],
    );
  }

  Widget _buildAgentBreakdown(List<AgentBreakdownEntity> agents) {
    return Container(
      margin: const EdgeInsets.only(left: 8, bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Expert Analysis',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C2C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...agents.map((agent) => _buildAgentCard(agent)),
        ],
      ),
    );
  }

  Widget _buildAgentCard(AgentBreakdownEntity agent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getAgentIcon(agent.agentType),
                  size: 16,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  agent.agentType,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              ),
              if (agent.confidence > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(agent.confidence).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getConfidenceColor(agent.confidence).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up_rounded,
                        size: 10,
                        color: _getConfidenceColor(agent.confidence),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(agent.confidence * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _getConfidenceColor(agent.confidence),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            agent.response,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.grey.shade700,
            ),
          ),
          if (agent.sources.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: agent.sources.map((source) => _buildSourceChip(source)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSourceChip(dynamic source) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.link_rounded,
            size: 12,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            source.name,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpQuestions(List<String> questions) {
    return Container(
      margin: const EdgeInsets.only(left: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 4),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: Colors.amber.shade700,
                ),
                const SizedBox(width: 6),
                Text(
                  'Suggested Questions',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          ...questions.map((question) => GestureDetector(
                onTap: () {
                  _controller.text = question;
                  _sendMessage();
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 14,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          question,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: const Color(0xFF4CAF50).withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 6),
            _buildDot(1),
            const SizedBox(width: 6),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final delay = index * 0.25;
        final offset = math.sin((value * 2 * math.pi) + (delay * 2 * math.pi)) * 0.4 + 0.6;
        
        return Transform.translate(
          offset: Offset(0, -3 * offset),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4CAF50).withOpacity(0.3 + (offset * 0.5)),
                  const Color(0xFF2E7D32).withOpacity(0.5 + (offset * 0.3)),
                ],
              ),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade100),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BlocBuilder<ChatBloc2, ChatState2>(
        builder: (context, state) {
          final isLoading = state is ChatLoading;
          
          return Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    enabled: !isLoading,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF2C2C2C),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: isLoading ? null : _sendMessage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: isLoading
                        ? null
                        : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                          ),
                    color: isLoading ? Colors.grey.shade300 : null,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: isLoading
                        ? []
                        : [
                            BoxShadow(
                              color: const Color(0xFF2E7D32).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    color: isLoading ? Colors.grey.shade500 : Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getAgentIcon(String agentType) {
    final type = agentType.toLowerCase();
    if (type.contains('crop')) return Icons.grass_rounded;
    if (type.contains('soil')) return Icons.landscape_rounded;
    if (type.contains('weather')) return Icons.wb_sunny_rounded;
    if (type.contains('pest')) return Icons.bug_report_rounded;
    if (type.contains('market')) return Icons.trending_up_rounded;
    return Icons.psychology_rounded;
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return const Color(0xFF4CAF50);
    if (confidence >= 0.6) return const Color(0xFFFF9800);
    if (confidence >= 0.4) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.day == time.day && now.month == time.month && now.year == time.year) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.day}/${time.month} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

