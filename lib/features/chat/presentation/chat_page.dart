import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xC7C9C9CF),
      appBar: AppBar(
        title: const Text(
          'AI Colab Chat',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.darkCard,
        elevation: 1,
      ),
      body: const Center(
        child: Text(
          'Welcome to the Chat Screen!',
          style: TextStyle(
            color: Color.fromARGB(255, 248, 246, 246),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// // ─── Models ───────────────────────────────────────────────────────────────────

// enum MessageRole { user, assistant }

// enum ChatMode { single, multi }

// class AiModel {
//   final String id;
//   final String name;
//   final Color color;
//   bool selected;

//   AiModel({
//     required this.id,
//     required this.name,
//     required this.color,
//     this.selected = false,
//   });
// }

// class ChatMessage {
//   final String id;
//   final MessageRole role;
//   final Map<String, String> content; // modelId -> text (single: {'': text})
//   final DateTime createdAt;
//   bool isStreaming;

//   ChatMessage({
//     required this.id,
//     required this.role,
//     required this.content,
//     required this.createdAt,
//     this.isStreaming = false,
//   });
// }

// // ─── Constants ────────────────────────────────────────────────────────────────

// const _bg = Color(0xFF0D0D12);
// const _surface = Color(0xFF16161F);
// const _border = Color(0xFF252535);
// const _borderActive = Color(0xFF3E3E6E);
// const _textPrimary = Color(0xFFFFFFFF);
// const _textSecondary = Color(0xFF8A8AAA);
// const _textHint = Color(0xFF4A4A6A);
// const _accent = Color(0xFFC5B8F0);
// const _accentDark = Color(0xFF6A5ABF);

// final _models = [
//   AiModel(
//     id: 'gpt4o',
//     name: 'GPT-4o',
//     color: const Color(0xFF10A37F),
//     selected: true,
//   ),
//   AiModel(
//     id: 'claude',
//     name: 'Claude',
//     color: const Color(0xFF3A9ABF),
//     selected: false,
//   ),
//   AiModel(
//     id: 'gemini',
//     name: 'Gemini',
//     color: const Color(0xFF4A8CF0),
//     selected: false,
//   ),
//   AiModel(
//     id: 'llama',
//     name: 'Llama 3',
//     color: const Color(0xFFBF8A3A),
//     selected: false,
//   ),
//   AiModel(
//     id: 'mistral',
//     name: 'Mistral',
//     color: const Color(0xFFBF3A6A),
//     selected: false,
//   ),
// ];

// // ─── ChatPage ─────────────────────────────────────────────────────────────────

// class ChatPage extends StatefulWidget {
//   const ChatPage({super.key});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
//   final _controller = TextEditingController();
//   final _scrollController = ScrollController();
//   final _focusNode = FocusNode();
//   final List<ChatMessage> _messages = [];
//   ChatMode _mode = ChatMode.single;
//   bool _isLoading = false;
//   late List<AiModel> _modelList;

//   @override
//   void initState() {
//     super.initState();
//     _modelList = _models
//         .map(
//           (m) => AiModel(
//             id: m.id,
//             name: m.name,
//             color: m.color,
//             selected: m.selected,
//           ),
//         )
//         .toList();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _scrollController.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }

//   List<AiModel> get _selectedModels =>
//       _modelList.where((m) => m.selected).toList();

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   Future<void> _sendMessage() async {
//     final text = _controller.text.trim();
//     if (text.isEmpty || _isLoading) return;

//     final activeModels = _mode == ChatMode.single
//         ? [
//             _modelList.firstWhere(
//               (m) => m.selected,
//               orElse: () => _modelList.first,
//             ),
//           ]
//         : _selectedModels;

//     if (activeModels.isEmpty) return;

//     _controller.clear();
//     _focusNode.unfocus();

//     final userMsg = ChatMessage(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       role: MessageRole.user,
//       content: {'': text},
//       createdAt: DateTime.now(),
//     );

//     final aiMsg = ChatMessage(
//       id: '${DateTime.now().millisecondsSinceEpoch}_ai',
//       role: MessageRole.assistant,
//       content: {for (var m in activeModels) m.id: ''},
//       createdAt: DateTime.now(),
//       isStreaming: true,
//     );

//     setState(() {
//       _messages.add(userMsg);
//       _messages.add(aiMsg);
//       _isLoading = true;
//     });
//     _scrollToBottom();

//     // Simulate streaming per model
//     for (final model in activeModels) {
//       _streamFakeResponse(aiMsg, model);
//     }
//   }

//   void _streamFakeResponse(ChatMessage msg, AiModel model) {
//     final responses = {
//       'gpt4o':
//           'GPT-4o: That\'s a great question! Here\'s my detailed analysis. Clean architecture with BLoC pattern is one of the most scalable approaches for Flutter apps. The separation of concerns makes testing and maintenance much easier.',
//       'claude':
//           'Claude: I\'d approach this differently. The key insight is that domain layer should remain completely independent of any framework. Your entities and use cases should be pure Dart with zero Flutter imports.',
//       'gemini':
//           'Gemini: Building on that — consider using freezed for immutable state objects in your BLoC. It pairs perfectly with clean architecture and eliminates a lot of boilerplate code.',
//       'llama':
//           'Llama 3: From a practical standpoint, I recommend starting with the domain layer first. Define your entities and repository contracts before writing any implementation code.',
//       'mistral':
//           'Mistral: Agreed. Also, don\'t forget to handle error states properly in your BLoC. Using Either<Failure, Success> from dartz makes error handling explicit and type-safe.',
//     };

//     final fullText = responses[model.id] ?? 'Response from ${model.name}...';
//     final words = fullText.split(' ');
//     var index = 0;

//     Timer.periodic(const Duration(milliseconds: 60), (timer) {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }
//       if (index >= words.length) {
//         timer.cancel();
//         final allDone = msg.content.keys.every(
//           (k) => !(msg.content[k]?.isEmpty ?? true),
//         );
//         if (allDone) {
//           setState(() {
//             msg.isStreaming = false;
//             _isLoading = false;
//           });
//         }
//         return;
//       }
//       setState(() {
//         msg.content[model.id] =
//             '${msg.content[model.id]}${index == 0 ? '' : ' '}${words[index]}';
//       });
//       index++;
//       _scrollToBottom();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.light,
//       child: Scaffold(
//         backgroundColor: _bg,
//         body: SafeArea(
//           child: Column(
//             children: [
//               _TopBar(modelList: _modelList),
//               Expanded(
//                 child: _messages.isEmpty
//                     ? _EmptyState(
//                         onChipTap: (text) {
//                           _controller.text = text;
//                           _sendMessage();
//                         },
//                       )
//                     : _MessageList(
//                         messages: _messages,
//                         modelList: _modelList,
//                         scrollController: _scrollController,
//                         mode: _mode,
//                       ),
//               ),
//               _BottomBar(
//                 controller: _controller,
//                 focusNode: _focusNode,
//                 mode: _mode,
//                 modelList: _modelList,
//                 isLoading: _isLoading,
//                 onModeChanged: (m) => setState(() => _mode = m),
//                 onModelToggle: (model) => setState(() {
//                   if (_mode == ChatMode.single) {
//                     for (var m in _modelList) m.selected = false;
//                     model.selected = true;
//                   } else {
//                     model.selected = !model.selected;
//                   }
//                 }),
//                 onSend: _sendMessage,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─── TopBar ───────────────────────────────────────────────────────────────────

// class _TopBar extends StatelessWidget {
//   final List<AiModel> modelList;
//   const _TopBar({required this.modelList});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: _bg,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       child: Row(
//         children: [
//           _IconBtn(
//             icon: Icons.menu_rounded,
//             onTap: () => Scaffold.of(context).openDrawer(),
//           ),
//           const Spacer(),
//           const Text(
//             'AI Colab',
//             style: TextStyle(
//               color: _textPrimary,
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               letterSpacing: 0.2,
//             ),
//           ),
//           const Spacer(),
//           GestureDetector(
//             onTap: () {},
//             child: Container(
//               width: 34,
//               height: 34,
//               decoration: const BoxDecoration(
//                 color: Color(0xFF3A3060),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.person_rounded, color: _accent, size: 18),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── EmptyState ───────────────────────────────────────────────────────────────

// class _EmptyState extends StatelessWidget {
//   final void Function(String) onChipTap;
//   const _EmptyState({required this.onChipTap});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 72,
//             height: 72,
//             decoration: BoxDecoration(
//               color: _surface,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: _border),
//             ),
//             child: const   Icon(
//           Icons.all_inclusive,
//           color: Colors.white,
//           size: 48,
//         ),
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             'AI Colab Chat',
//             style: TextStyle(
//               color: _textPrimary,
//               fontSize: 24,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             'Start a conversation with one or multiple AI models. Select your models below and type a message.',
//             textAlign: TextAlign.center,
//             style: TextStyle(color: _textSecondary, fontSize: 14, height: 1.6),
//           ),
//           const SizedBox(height: 28),
//           _PromptChip(
//             icon: Icons.auto_awesome_rounded,
//             label: 'Brainstorm ideas for...',
//             wide: true,
//             onTap: () => onChipTap('Brainstorm ideas for a Flutter AI app'),
//           ),
//           const SizedBox(height: 10),
//           Row(
//             children: [
//               Expanded(
//                 child: _PromptChip(
//                   icon: Icons.chat_bubble_outline_rounded,
//                   label: 'Help me write a...',
//                   onTap: () =>
//                       onChipTap('Help me write a clean architecture guide'),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: _PromptChip(
//                   icon: Icons.lightbulb_outline_rounded,
//                   label: 'Explain how...',
//                   onTap: () => onChipTap('Explain how BLoC pattern works'),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _PromptChip extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final bool wide;
//   final VoidCallback onTap;

//   const _PromptChip({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//     this.wide = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//         decoration: BoxDecoration(
//           color: _surface,
//           borderRadius: BorderRadius.circular(24),
//           border: Border.all(color: _border),
//         ),
//         child: Row(
//           mainAxisSize: wide ? MainAxisSize.max : MainAxisSize.min,
//           children: [
//             Icon(icon, size: 14, color: _accentDark),
//             const SizedBox(width: 8),
//             Flexible(
//               child: Text(
//                 label,
//                 style: const TextStyle(color: _textSecondary, fontSize: 12.5),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─── MessageList ──────────────────────────────────────────────────────────────

// class _MessageList extends StatelessWidget {
//   final List<ChatMessage> messages;
//   final List<AiModel> modelList;
//   final ScrollController scrollController;
//   final ChatMode mode;

//   const _MessageList({
//     required this.messages,
//     required this.modelList,
//     required this.scrollController,
//     required this.mode,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       controller: scrollController,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       itemCount: messages.length,
//       itemBuilder: (context, i) {
//         final msg = messages[i];
//         if (msg.role == MessageRole.user) {
//           return _UserBubble(text: msg.content[''] ?? '');
//         }
//         final modelCount = msg.content.keys.length;
//         if (modelCount > 1) {
//           return _MultiModelResponse(message: msg, modelList: modelList);
//         }
//         final modelId = msg.content.keys.first;
//         final model = modelList.firstWhere(
//           (m) => m.id == modelId,
//           orElse: () => modelList.first,
//         );
//         return _AiBubble(
//           text: msg.content[modelId] ?? '',
//           model: model,
//           isStreaming: msg.isStreaming,
//         );
//       },
//     );
//   }
// }

// // ─── UserBubble ───────────────────────────────────────────────────────────────

// class _UserBubble extends StatelessWidget {
//   final String text;
//   const _UserBubble({required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.centerRight,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 16, left: 48),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: _accentDark,
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(18),
//             topRight: Radius.circular(18),
//             bottomLeft: Radius.circular(18),
//             bottomRight: Radius.circular(4),
//           ),
//         ),
//         child: Text(
//           text,
//           style: const TextStyle(
//             color: _textPrimary,
//             fontSize: 14,
//             height: 1.5,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─── AiBubble ─────────────────────────────────────────────────────────────────

// class _AiBubble extends StatelessWidget {
//   final String text;
//   final AiModel model;
//   final bool isStreaming;

//   const _AiBubble({
//     required this.text,
//     required this.model,
//     required this.isStreaming,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16, right: 48),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _ModelAvatar(model: model, size: 28),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   model.name,
//                   style: TextStyle(
//                     color: model.color,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 14,
//                     vertical: 12,
//                   ),
//                   decoration: BoxDecoration(
//                     color: _surface,
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(4),
//                       topRight: Radius.circular(18),
//                       bottomLeft: Radius.circular(18),
//                       bottomRight: Radius.circular(18),
//                     ),
//                     border: Border.all(color: _border),
//                   ),
//                   child: text.isEmpty && isStreaming
//                       ? _TypingIndicator(color: model.color)
//                       : Text(
//                           text,
//                           style: const TextStyle(
//                             color: _textPrimary,
//                             fontSize: 14,
//                             height: 1.6,
//                           ),
//                         ),
//                 ),
//                 if (!isStreaming && text.isNotEmpty)
//                   _MessageActions(text: text),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── MultiModelResponse ───────────────────────────────────────────────────────

// class _MultiModelResponse extends StatelessWidget {
//   final ChatMessage message;
//   final List<AiModel> modelList;

//   const _MultiModelResponse({required this.message, required this.modelList});

//   @override
//   Widget build(BuildContext context) {
//     final entries = message.content.entries.toList();
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8),
//             child: Text(
//               '${entries.length} models responded',
//               style: const TextStyle(color: _textHint, fontSize: 12),
//             ),
//           ),
//           ...entries.map((e) {
//             final model = modelList.firstWhere(
//               (m) => m.id == e.key,
//               orElse: () => modelList.first,
//             );
//             return Padding(
//               padding: const EdgeInsets.only(bottom: 10),
//               child: _AiBubble(
//                 text: e.value,
//                 model: model,
//                 isStreaming: message.isStreaming && e.value.isEmpty,
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }

// // ─── MessageActions ───────────────────────────────────────────────────────────

// class _MessageActions extends StatelessWidget {
//   final String text;
//   const _MessageActions({required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 6),
//       child: Row(
//         children: [
//           _ActionBtn(
//             icon: Icons.copy_rounded,
//             onTap: () => Clipboard.setData(ClipboardData(text: text)),
//           ),
//           const SizedBox(width: 4),
//           _ActionBtn(icon: Icons.thumb_up_outlined, onTap: () {}),
//           const SizedBox(width: 4),
//           _ActionBtn(icon: Icons.thumb_down_outlined, onTap: () {}),
//           const SizedBox(width: 4),
//           _ActionBtn(icon: Icons.refresh_rounded, onTap: () {}),
//         ],
//       ),
//     );
//   }
// }

// class _ActionBtn extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;
//   const _ActionBtn({required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(6),
//         decoration: BoxDecoration(
//           color: _surface,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: _border),
//         ),
//         child: Icon(icon, size: 13, color: _textSecondary),
//       ),
//     );
//   }
// }

// // ─── TypingIndicator ──────────────────────────────────────────────────────────

// class _TypingIndicator extends StatefulWidget {
//   final Color color;
//   const _TypingIndicator({required this.color});

//   @override
//   State<_TypingIndicator> createState() => _TypingIndicatorState();
// }

// class _TypingIndicatorState extends State<_TypingIndicator>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _anim;

//   @override
//   void initState() {
//     super.initState();
//     _anim = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     )..repeat();
//   }

//   @override
//   void dispose() {
//     _anim.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _anim,
//       builder: (_, __) => Row(
//         mainAxisSize: MainAxisSize.min,
//         children: List.generate(3, (i) {
//           final delay = i / 3.0;
//           final t = (_anim.value - delay).clamp(0.0, 1.0);
//           final opacity = (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(0.3, 1.0);
//           return Container(
//             margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
//             width: 7,
//             height: 7,
//             decoration: BoxDecoration(
//               color: widget.color.withOpacity(opacity),
//               shape: BoxShape.circle,
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }

// // ─── ModelAvatar ──────────────────────────────────────────────────────────────

// class _ModelAvatar extends StatelessWidget {
//   final AiModel model;
//   final double size;
//   const _ModelAvatar({required this.model, required this.size});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         color: model.color.withOpacity(0.15),
//         shape: BoxShape.circle,
//         border: Border.all(color: model.color.withOpacity(0.4)),
//       ),
//       child: Center(
//         child: Text(
//           model.name[0],
//           style: TextStyle(
//             color: model.color,
//             fontSize: size * 0.42,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─── BottomBar ────────────────────────────────────────────────────────────────

// class _BottomBar extends StatelessWidget {
//   final TextEditingController controller;
//   final FocusNode focusNode;
//   final ChatMode mode;
//   final List<AiModel> modelList;
//   final bool isLoading;
//   final void Function(ChatMode) onModeChanged;
//   final void Function(AiModel) onModelToggle;
//   final VoidCallback onSend;

//   const _BottomBar({
//     required this.controller,
//     required this.focusNode,
//     required this.mode,
//     required this.modelList,
//     required this.isLoading,
//     required this.onModeChanged,
//     required this.onModelToggle,
//     required this.onSend,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: _bg,
//       padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (mode == ChatMode.multi)
//             _ModelSelector(modelList: modelList, onToggle: onModelToggle),
//           _InputCard(
//             controller: controller,
//             focusNode: focusNode,
//             mode: mode,
//             isLoading: isLoading,
//             onModeChanged: onModeChanged,
//             onSend: onSend,
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── ModelSelector ────────────────────────────────────────────────────────────

// class _ModelSelector extends StatelessWidget {
//   final List<AiModel> modelList;
//   final void Function(AiModel) onToggle;

//   const _ModelSelector({required this.modelList, required this.onToggle});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 36,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//         itemCount: modelList.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 6),
//         itemBuilder: (_, i) {
//           final model = modelList[i];
//           return GestureDetector(
//             onTap: () => onToggle(model),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//               decoration: BoxDecoration(
//                 color: model.selected
//                     ? model.color.withOpacity(0.15)
//                     : _surface,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: model.selected
//                       ? model.color.withOpacity(0.6)
//                       : _border,
//                 ),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     width: 6,
//                     height: 6,
//                     decoration: BoxDecoration(
//                       color: model.color,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   const SizedBox(width: 5),
//                   Text(
//                     model.name,
//                     style: TextStyle(
//                       color: model.selected ? model.color : _textSecondary,
//                       fontSize: 11.5,
//                       fontWeight: model.selected
//                           ? FontWeight.w500
//                           : FontWeight.normal,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // ─── InputCard ────────────────────────────────────────────────────────────────

// class _InputCard extends StatelessWidget {
//   final TextEditingController controller;
//   final FocusNode focusNode;
//   final ChatMode mode;
//   final bool isLoading;
//   final void Function(ChatMode) onModeChanged;
//   final VoidCallback onSend;

//   const _InputCard({
//     required this.controller,
//     required this.focusNode,
//     required this.mode,
//     required this.isLoading,
//     required this.onModeChanged,
//     required this.onSend,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(top: 8),
//       padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
//       decoration: BoxDecoration(
//         color: _surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: _border),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TextField(
//             controller: controller,
//             focusNode: focusNode,
//             style: const TextStyle(color: _textPrimary, fontSize: 14),
//             maxLines: 4,
//             minLines: 1,
//             textInputAction: TextInputAction.newline,
//             decoration: const InputDecoration(
//               hintText: 'Ask anything...',
//               hintStyle: TextStyle(color: _textHint, fontSize: 14),
//               isDense: true,
//               border: InputBorder.none,
//               contentPadding: EdgeInsets.zero,
//             ),
//             onSubmitted: (_) => onSend(),
//           ),
//           const SizedBox(height: 10),
//           Row(
//             children: [
//               _IconBtn(icon: Icons.add_rounded, onTap: () {}),
//               const SizedBox(width: 6),
//               _ModeToggle(mode: mode, onChanged: onModeChanged),
//               const Spacer(),
//               _IconBtn(icon: Icons.auto_awesome_rounded, onTap: () {}),
//               const SizedBox(width: 6),
//               _IconBtn(icon: Icons.mic_none_rounded, onTap: () {}),
//               const SizedBox(width: 6),
//               _SendButton(isLoading: isLoading, onTap: onSend),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── ModeToggle ───────────────────────────────────────────────────────────────

// class _ModeToggle extends StatelessWidget {
//   final ChatMode mode;
//   final void Function(ChatMode) onChanged;
//   const _ModeToggle({required this.mode, required this.onChanged});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(3),
//       decoration: BoxDecoration(
//         color: const Color(0xFF252535),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _ModeBtn(
//             label: 'Single',
//             active: mode == ChatMode.single,
//             onTap: () => onChanged(ChatMode.single),
//           ),
//           _ModeBtn(
//             label: 'Multi',
//             active: mode == ChatMode.multi,
//             onTap: () => onChanged(ChatMode.multi),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ModeBtn extends StatelessWidget {
//   final String label;
//   final bool active;
//   final VoidCallback onTap;
//   const _ModeBtn({
//     required this.label,
//     required this.active,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//         decoration: BoxDecoration(
//           color: active ? _textPrimary : Colors.transparent,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             color: active ? _bg : _textSecondary,
//             fontSize: 12,
//             fontWeight: active ? FontWeight.w500 : FontWeight.normal,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─── SendButton ───────────────────────────────────────────────────────────────

// class _SendButton extends StatelessWidget {
//   final bool isLoading;
//   final VoidCallback onTap;
//   const _SendButton({required this.isLoading, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: isLoading ? null : onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         width: 30,
//         height: 30,
//         decoration: BoxDecoration(
//           color: isLoading ? _border : _textPrimary,
//           shape: BoxShape.circle,
//         ),
//         child: isLoading
//             ? const Padding(
//                 padding: EdgeInsets.all(7),
//                 child: CircularProgressIndicator(
//                   strokeWidth: 1.5,
//                   color: _textSecondary,
//                 ),
//               )
//             : const Icon(Icons.arrow_upward_rounded, color: _bg, size: 16),
//       ),
//     );
//   }
// }

// // ─── IconBtn ──────────────────────────────────────────────────────────────────

// class _IconBtn extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;
//   const _IconBtn({required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 30,
//         height: 30,
//         decoration: BoxDecoration(
//           color: const Color(0xFF252535),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, color: _textSecondary, size: 16),
//       ),
//     );
//   }
// }

// // ─── Entry point (for standalone testing) ────────────────────────────────────

// void main() => runApp(
//   const MaterialApp(debugShowCheckedModeBanner: false, home: ChatPage()),
// );
