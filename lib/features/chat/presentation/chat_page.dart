import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
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

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Transparent status bar
        statusBarIconBrightness: Brightness.light, // Light icons for dark background
        systemNavigationBarColor: Colors.transparent, // Transparent navigation bar
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        extendBodyBehindAppBar: true,
        drawer: const ChatDrawer(),
        body: Stack(
          children: [
            _ChatBackground(),
            SafeArea(
              child: Column(
                children: [
                  _CustomHeader(),
                  
                  // Chat Content
                  Expanded(
                    child: BlocConsumer<ChatBloc, ChatState>(
                      listener: (context, state) {
                        if (state is ChatLoaded) _scrollToBottom();
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
                                  color: AppColors.darkMutedForeground.withValues(alpha: 0.8),
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
                                    color: AppColors.darkDestructive.withValues(alpha: 0.1),
                                  ),
                                  child: const Icon(
                                    Icons.error_outline_rounded,
                                    color: AppColors.darkDestructive,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.darkForeground,
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
                            child: state.messages.isEmpty && !state.isSending
                                ? ChatEmptyState(
                                    onSuggestion: (text) =>
                                        context.read<ChatBloc>().add(ChatSendMessage(text)),
                                  )
                                : _MessagesList(
                                    messages: state.messages,
                                    isSending: state.isSending,
                                    scrollCtrl: _scrollCtrl,
                                  ),
                          ),
                          ChatInputBar(
                            enabled: !state.isSending,
                            onSend: (text) =>
                                context.read<ChatBloc>().add(ChatSendMessage(text)),
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
    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Base dark background
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.darkBackground,
            ),
          ),
          
          // Subtle center glow (very minimal)
          DecoratedBox(
  decoration: BoxDecoration(
    gradient: RadialGradient(
      center: Alignment.topCenter,  // ✅ Changed
      radius: 1.2,                  // ✅ Slightly larger radius
      colors: [
        AppColors.landingPrimary.withValues(alpha: 0.15),
        AppColors.darkBackground.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 1.0],
    ),
  ),
),
          // DecoratedBox(
          //   decoration: BoxDecoration(
          //     gradient: RadialGradient(
          //       center: Alignment.center,
          //       radius: 0.8,
          //       colors: [
          //         AppColors.landingPrimary.withValues(alpha: 0.12),
          //         AppColors.darkBackground.withValues(alpha: 0.0),
          //       ],
          //       stops: const [0.0, 1.0],
          //     ),
          //   ),
          // ),
          
          // Grid pattern
          CustomPaint(
            painter: _CheckerGridPainter(),
            size: Size.infinite,
          ),
          
          // Animated subtle glow in center
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
          
          // Strong vignette - sides completely dark
          DecoratedBox(
  decoration: BoxDecoration(
    gradient: RadialGradient(
      center: Alignment.topCenter,  // ✅ Changed
      radius: 1.0,
      colors: [
        AppColors.darkBackground.withValues(alpha: 0.9),
        AppColors.darkBackground.withValues(alpha: 0.0),
        AppColors.darkBackground.withValues(alpha: 1.9),
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
  const _CheckerGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double step = 32.0; // Consistent grid size
    
    // Grid lines - only visible in center area
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += step) {
      // Calculate distance from center (0.0 = center, 1.0 = edge)
      final distanceY = (y - centerY).abs() / centerY;
      
      // Only draw lines in center area (fade out towards edges)
      if (distanceY < 0.8) {
        final opacity = 0.3 * (1.0 - distanceY);
        linePaint.color = AppColors.darkBorder.withValues(alpha: opacity);
        canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      }
    }
    
    // Draw vertical lines
    for (double x = 0; x <= size.width; x += step) {
      // Calculate distance from center
      final distanceX = (x - centerX).abs() / centerX;
      
      // Only draw lines in center area
      if (distanceX < 0.8) {
        final opacity = 0.3 * (1.0 - distanceX);
        linePaint.color = AppColors.darkBorder.withValues(alpha: opacity);
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Custom Header (Minimal Floating Buttons) ─────────────────────────────────
class _CustomHeader extends StatelessWidget {
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
            color: AppColors.darkCard.withValues(alpha: 0.5),
            // border: Border.all(
            //   color: AppColors.darkBorder.withValues(alpha: 0.4),
            //   width: 1,
            // ),
          ),
          child: Icon(
            icon,
            color: AppColors.darkForeground.withValues(alpha: 0.9),
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
    required this.scrollCtrl,
  });

  final List messages;
  final bool isSending;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final itemCount = messages.length + (isSending ? 1 : 0);

    return ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == messages.length && isSending) {
          return const TypingIndicator();
        }
        return ChatBubble(message: messages[index]);
      },
    );
  }
}