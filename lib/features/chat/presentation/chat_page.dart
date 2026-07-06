import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/entities/chat_message.dart';
import '../bloc/chat_bloc.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_drawer.dart';
import 'widgets/chat_empty_state.dart';
import 'widgets/chat_input_bar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _scrollCtrl = ScrollController();
  bool _isStreaming = false;

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      final maxExtent = _scrollCtrl.position.maxScrollExtent;
      if (animated) {
        _scrollCtrl.animateTo(
          maxExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        _scrollCtrl.jumpTo(maxExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: context.cBg,
        extendBodyBehindAppBar: true,
        drawer: const ChatDrawer(),
        body: Stack(
          children: [
            _ChatBackground(),
            SafeArea(
              child: Column(
                children: [
                  const _CustomHeader(),
                  
                  // Chat Content
                  Expanded(
                    child: BlocConsumer<ChatBloc, ChatState>(
                      listenWhen: (prev, curr) {
                        if (curr is! ChatLoaded) return false;
                        if (prev is! ChatLoaded) return true;
                        return curr.messages.length > prev.messages.length ||
                            curr.isStreaming != prev.isStreaming ||
                            (curr.isStreaming &&
                                curr.streamingContent != prev.streamingContent) ||
                            // Follow multi-model streaming (content changes in place).
                            (curr.messages.isNotEmpty &&
                                prev.messages.isNotEmpty &&
                                curr.messages.last != prev.messages.last);
                      },
                      listener: (context, state) {
                        if (state is! ChatLoaded) return;
                        final liveMulti = state.messages.isNotEmpty &&
                            !state.messages.last.isUser &&
                            state.messages.last.isMultiModel &&
                            state.isSending;
                        final streaming = state.isStreaming || liveMulti;
                        // Instant jump while streaming, smooth animate for new messages
                        _scrollToBottom(animated: !_isStreaming);
                        _isStreaming = streaming;
                      },
                      builder: (context, state) {
                      if (state is ChatLoading) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.landingPrimary.withValues(alpha: 0.2),
                                      AppColors.landingPrimary.withValues(alpha: 0.1),
                                    ],
                                  ),
                                ),
                                child: const CircularProgressIndicator(
                                  color: AppColors.landingPrimary,
                                  strokeWidth: 3,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Loading...',
                                style: TextStyle(
                                  color: context.cMuted.withValues(alpha: 0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is ChatError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.cError.withValues(alpha: 0.1),
                                  ),
                                  child: Icon(
                                    Icons.error_outline_rounded,
                                    color: context.cError,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: context.cFg,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (state is! ChatLoaded) return const SizedBox();

                      return Column(
                        children: [
                          Expanded(
                            child: state.messages.isEmpty && !state.isSending && !state.isStreaming
                                ? ChatEmptyState(
                                    onSuggestion: (text) =>
                                        context.read<ChatBloc>().add(ChatSendMessageStreaming(text)),
                                  )
                                : _MessagesList(
                                    messages: state.messages,
                                    isSending: state.isSending,
                                    isStreaming: state.isStreaming,
                                    streamingContent: state.streamingContent ?? '',
                                    scrollCtrl: _scrollCtrl,
                                    chatId: state.selectedConversation?.id,
                                  ),
                          ),
                          ChatInputBar(
                            enabled: !state.isSending && !state.isStreaming,
                            onSend: (text) =>
                                context.read<ChatBloc>().add(ChatSendMessageStreaming(text)),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _ChatBackground extends StatefulWidget {
  const _ChatBackground();

  @override
  State<_ChatBackground> createState() => _ChatBackgroundState();
}

class _ChatBackgroundState extends State<_ChatBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = context.cBg;
    final isDark = context.isDark;

    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(decoration: BoxDecoration(color: bg)),

          // Subtle brand glow at top (lighter in light mode)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.2,
                colors: [
                  AppColors.landingPrimary.withValues(alpha: isDark ? 0.15 : 0.08),
                  bg.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),

          // Grid pattern
          CustomPaint(
            painter: _CheckerGridPainter(borderColor: context.cBorder),
            size: Size.infinite,
          ),

          // Animated subtle glow (dark mode only)
          if (isDark)
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                final glow = 0.06 + (_glowController.value * 0.04);
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      radius: 0.6,
                      colors: [
                        AppColors.landingPrimary.withValues(alpha: glow),
                        AppColors.darkBackground.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                );
              },
            ),

          // Vignette
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.0,
                colors: [
                  bg.withValues(alpha: isDark ? 0.9 : 0.5),
                  bg.withValues(alpha: 0.0),
                  bg.withValues(alpha: isDark ? 1.9 : 0.8),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckerGridPainter extends CustomPainter {
  const _CheckerGridPainter({required this.borderColor});
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    const double step = 32.0;
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (double y = 0; y <= size.height; y += step) {
      final distanceY = (y - centerY).abs() / centerY;
      if (distanceY < 0.8) {
        linePaint.color = borderColor.withValues(alpha: 0.3 * (1.0 - distanceY));
        canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      }
    }
    for (double x = 0; x <= size.width; x += step) {
      final distanceX = (x - centerX).abs() / centerX;
      if (distanceX < 0.8) {
        linePaint.color = borderColor.withValues(alpha: 0.3 * (1.0 - distanceX));
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerGridPainter old) => old.borderColor != borderColor;
}

// ── Custom Header (Minimal Floating Buttons) ─────────────────────────────────
class _CustomHeader extends StatelessWidget {
  const _CustomHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Menu button (left)
          Builder(
            builder: (ctx) => _FloatingButton(
              icon: Icons.sort_sharp,
            
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          
          // Profile/Account button (right)
          _FloatingButton(
            icon: Icons.account_circle_outlined,
            onPressed: () {
              // TODO: Open profile/account page
            },
          ),
        ],
      ),
    );
  }
}

// ── Floating Button Widget ───────────────────────────────────────────────────
class _FloatingButton extends StatelessWidget {
  const _FloatingButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        // borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.cCard.withValues(alpha: context.isDark ? 0.5 : 0.9),
            border: Border.all(
              color: context.cBorder.withValues(alpha: 0.4),
            ),
          ),
          child: Icon(
            icon,
            color: context.cFg.withValues(alpha: 0.9),
            size: 27,
          ),
        ),
      ),
    );
  }
}

// ── Messages list ─────────────────────────────────────────────────────────────
class _MessagesList extends StatelessWidget {
  const _MessagesList({
    required this.messages,
    required this.isSending,
    required this.isStreaming,
    required this.streamingContent,
    required this.scrollCtrl,
    this.chatId,
  });

  final List<ChatMessage> messages;
  final bool isSending;
  final bool isStreaming;
  final String streamingContent;
  final ScrollController scrollCtrl;
  final String? chatId;

  @override
  Widget build(BuildContext context) {
    // In multi-model mode the live assistant message is already in [messages]
    // (its per-model slots update in place), so no extra streaming/typing item
    // is needed even though isSending stays true until all models finish.
    final lastIsLiveMulti = messages.isNotEmpty &&
        messages.last.isMultiModel &&
        !messages.last.isUser;
    final extra = lastIsLiveMulti ? 0 : (isStreaming ? 1 : (isSending ? 1 : 0));
    final itemCount = messages.length + extra;

    return ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == messages.length) {
          if (isStreaming) {
            return ChatBubble(
              message: ChatMessage(
                id: 'streaming',
                content: streamingContent,
                isUser: false,
                timestamp: DateTime.now(),
              ),
              isStreaming: true,
              chatId: chatId,
              onQuestionTap: (question) {
                context.read<ChatBloc>().add(ChatSendMessageStreaming(question));
              },
            );
          } else if (isSending) {
            return const TypingIndicator();
          }
        }
        return RepaintBoundary(
          child: ChatBubble(
            message: messages[index],
            chatId: chatId,
            onQuestionTap: (question) {
              context.read<ChatBloc>().add(ChatSendMessageStreaming(question));
            },
          ),
        );
      },
    );
  }
}