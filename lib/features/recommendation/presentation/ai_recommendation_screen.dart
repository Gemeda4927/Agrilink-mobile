// // ai_recommendation_screen.dart
// import 'package:agrilink/features/recommendation/domain/entity/agent_breakdown_entity.dart';
// import 'package:agrilink/features/recommendation/domain/entity/chat_response_entity.dart';
// import 'package:agrilink/features/recommendation/domain/usecase/send_chat_message_usecase.dart';
// import 'package:agrilink/features/recommendation/presentation/bloc/chat_bloc.dart';
// import 'package:agrilink/features/recommendation/presentation/bloc/chat_event.dart';
// import 'package:agrilink/features/recommendation/presentation/bloc/chat_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:agrilink/injector.dart' as di;

// class AIRecommendationScreen extends StatelessWidget {
//   const AIRecommendationScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<ChatBloc2>(
//       create: (context) {
//         try {
//           return di.sl<ChatBloc2>();
//         } catch (e) {
//           final useCase = di.sl<SendChatMessageUseCase2>();
//           return ChatBloc2(sendMessageUseCase: useCase);
//         }
//       },
//       child: const _ChatScreenContent(),
//     );
//   }
// }

// class _ChatScreenContent extends StatefulWidget {
//   const _ChatScreenContent();

//   @override
//   State<_ChatScreenContent> createState() => _ChatScreenContentState();
// }

// class _ChatScreenContentState extends State<_ChatScreenContent>
//     with WidgetsBindingObserver {
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode _focusNode = FocusNode();
//   final List<Map<String, dynamic>> _messages = [];

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _addWelcomeMessage();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _controller.dispose();
//     _scrollController.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }

//   @override
//   void didChangeMetrics() {
//     _scrollToBottom();
//   }

//   void _addWelcomeMessage() {
//     _messages.add({
//       'isUser': false,
//       'text': 'Hello! I\'m your AI Crop Advisor. How can I help you today?',
//       'timestamp': DateTime.now(),
//     });
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 200),
//           curve: Curves.easeOutCubic,
//         );
//       }
//     });
//   }

//   void _sendMessage() {
//     final text = _controller.text.trim();
//     if (text.isEmpty) return;

//     _addUserMessage(text);
//     _controller.clear();
//     _focusNode.requestFocus();

//     context.read<ChatBloc2>().add(SendMessageEvent(message: text));
//   }

//   void _addUserMessage(String text) {
//     setState(() {
//       _messages.add({
//         'isUser': true,
//         'text': text,
//         'timestamp': DateTime.now(),
//       });
//     });
//     _scrollToBottom();
//   }

//   void _addAIMessage(ChatResponseEntity entity) {
//     setState(() {
//       _messages.add({
//         'isUser': false,
//         'text': entity.response,
//         'timestamp': DateTime.now(),
//         'responseEntity': entity,
//       });
//     });
//     _scrollToBottom();
//   }

//   void _addErrorMessage(String error) {
//     setState(() {
//       _messages.add({
//         'isUser': false,
//         'text': error,
//         'isError': true,
//         'timestamp': DateTime.now(),
//       });
//     });
//     _scrollToBottom();
//   }

//   void _clearChat() {
//     setState(() {
//       _messages.clear();
//       _addWelcomeMessage();
//     });
//     context.read<ChatBloc2>().add(ClearChatEvent());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: _buildAppBar(),
//       body: SafeArea(
//         child: BlocConsumer<ChatBloc2, ChatState2>(
//           listener: (context, state) {
//             if (state is ChatLoaded) {
//               _addAIMessage(state.response);
//             } else if (state is ChatError) {
//               _addErrorMessage(state.message);
//             }
//           },
//           builder: (context, state) {
//             final isLoading = state is ChatLoading;
//             return Column(
//               children: [
//                 Expanded(child: _buildMessageList(isLoading)),
//                 _buildInputBar(isLoading),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       title: const Text(
//         'AI Crop Advisor',
//         style: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.w500,
//           color: Colors.white,
//         ),
//       ),
//       backgroundColor: const Color(0xFF1A8C3F),
//       elevation: 0,
//       centerTitle: false,
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.delete_outline, size: 20),
//           onPressed: _clearChat,
//           tooltip: 'Clear chat',
//         ),
//       ],
//     );
//   }

//   Widget _buildMessageList(bool isLoading) {
//     if (_messages.isEmpty) {
//       return _buildEmptyState();
//     }

//     return ListView.builder(
//       controller: _scrollController,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       itemCount: _messages.length + (isLoading ? 1 : 0),
//       itemBuilder: (context, index) {
//         if (isLoading && index == _messages.length) {
//           return _buildTypingIndicator();
//         }
//         final msg = _messages[index];
//         return _buildChatBubble(
//           text: msg['text'] as String,
//           isUser: msg['isUser'] as bool,
//           isError: msg['isError'] as bool? ?? false,
//           timestamp: msg['timestamp'] as DateTime,
//           responseEntity: msg['responseEntity'] as ChatResponseEntity?,
//         );
//       },
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 64,
//             height: 64,
//             decoration: BoxDecoration(
//               color: const Color(0xFF1A8C3F).withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.chat_bubble_outline,
//               size: 32,
//               color: Color(0xFF1A8C3F),
//             ),
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'Ask me anything about farming',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               color: Color(0xFF333333),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Crops • Soil • Pests • Weather',
//             style: TextStyle(
//               fontSize: 13,
//               color: Colors.grey.shade500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTypingIndicator() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF5F5F5),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: const Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(
//               width: 4,
//               height: 4,
//               child: CircleAvatar(
//                 radius: 2,
//                 backgroundColor: Color(0xFF9E9E9E),
//               ),
//             ),
//             SizedBox(width: 4),
//             SizedBox(
//               width: 4,
//               height: 4,
//               child: CircleAvatar(
//                 radius: 2,
//                 backgroundColor: Color(0xFF9E9E9E),
//               ),
//             ),
//             SizedBox(width: 4),
//             SizedBox(
//               width: 4,
//               height: 4,
//               child: CircleAvatar(
//                 radius: 2,
//                 backgroundColor: Color(0xFF9E9E9E),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInputBar(bool isLoading) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           top: BorderSide(
//             color: Colors.grey.shade200,
//             width: 0.5,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF5F5F5),
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               child: TextField(
//                 controller: _controller,
//                 focusNode: _focusNode,
//                 maxLines: null,
//                 textInputAction: TextInputAction.send,
//                 enabled: !isLoading,
//                 style: const TextStyle(
//                   fontSize: 15,
//                   color: Color(0xFF333333),
//                 ),
//                 decoration: InputDecoration(
//                   hintText: 'Ask a question...',
//                   hintStyle: TextStyle(
//                     fontSize: 15,
//                     color: Colors.grey.shade500,
//                   ),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                 ),
//                 onSubmitted: (_) => _sendMessage(),
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           GestureDetector(
//             onTap: isLoading ? null : _sendMessage,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 150),
//               width: 44,
//               height: 44,
//               decoration: BoxDecoration(
//                 color: isLoading ? Colors.grey.shade300 : const Color(0xFF1A8C3F),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.arrow_forward,
//                 size: 20,
//                 color: isLoading ? Colors.grey.shade500 : Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildChatBubble({
//     required String text,
//     required bool isUser,
//     required bool isError,
//     required DateTime timestamp,
//     ChatResponseEntity? responseEntity,
//   }) {
//     return Align(
//       alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.75,
//         ),
//         child: Column(
//           crossAxisAlignment:
//               isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//               decoration: BoxDecoration(
//                 color: isError
//                     ? const Color(0xFFFFEBEE)
//                     : isUser
//                         ? const Color(0xFF1A8C3F)
//                         : const Color(0xFFF5F5F5),
//                 borderRadius: BorderRadius.only(
//                   topLeft: const Radius.circular(20),
//                   topRight: const Radius.circular(20),
//                   bottomLeft: Radius.circular(isUser ? 20 : 4),
//                   bottomRight: Radius.circular(isUser ? 4 : 20),
//                 ),
//               ),
//               child: Text(
//                 text,
//                 style: TextStyle(
//                   fontSize: 14,
//                   height: 1.4,
//                   color: isError
//                       ? const Color(0xFFD32F2F)
//                       : isUser
//                           ? Colors.white
//                           : const Color(0xFF333333),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
//               child: Text(
//                 _formatTime(timestamp),
//                 style: TextStyle(
//                   fontSize: 10,
//                   color: Colors.grey.shade400,
//                 ),
//               ),
//             ),
//             if (!isUser && responseEntity != null) ...[
//               if (responseEntity.agentBreakdown.isNotEmpty)
//                 _buildAgentBreakdown(responseEntity.agentBreakdown),
//               if (responseEntity.followUpQuestions.isNotEmpty)
//                 _buildFollowUpQuestions(responseEntity.followUpQuestions),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAgentBreakdown(List<AgentBreakdownEntity> agents) {
//     return Container(
//       margin: const EdgeInsets.only(top: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFAFAFA),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Expert Analysis',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF666666),
//             ),
//           ),
//           const SizedBox(height: 8),
//           ...agents.map((agent) => Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           width: 4,
//                           height: 4,
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF1A8C3F),
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           agent.agentType,
//                           style: const TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF1A8C3F),
//                           ),
//                         ),
//                         if (agent.confidence > 0) ...[
//                           const SizedBox(width: 8),
//                           Text(
//                             '${(agent.confidence * 100).toInt()}%',
//                             style: TextStyle(
//                               fontSize: 9,
//                               color: Colors.grey.shade500,
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       agent.response,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Color(0xFF555555),
//                       ),
//                     ),
//                   ],
//                 ),
//               )),
//         ],
//       ),
//     );
//   }

//   Widget _buildFollowUpQuestions(List<String> questions) {
//     return Container(
//       margin: const EdgeInsets.only(top: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Suggested Questions',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF666666),
//             ),
//           ),
//           const SizedBox(height: 8),
//           ...questions.map((question) => GestureDetector(
//                 onTap: () {
//                   _controller.text = question;
//                   _sendMessage();
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.only(bottom: 8),
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF5F5F5),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     question,
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Color(0xFF1A8C3F),
//                     ),
//                   ),
//                 ),
//               )),
//         ],
//       ),
//     );
//   }

//   String _formatTime(DateTime time) {
//     final now = DateTime.now();
//     if (now.day == time.day && now.month == time.month && now.year == time.year) {
//       return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
//     }
//     return '${time.day}/${time.month} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
//   }
// }