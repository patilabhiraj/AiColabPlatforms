import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/bloc/auth_bloc.dart';
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
  bool _showAppBar = false;
  
  // Progressive blur and opacity values (ChatGPT iOS behavior)
  double _headerBlur = 0.0;      // Starts at 0, increases to 15 as you scroll
  double _headerOpacity = 0.0;   // Starts at 0, increases to 0.85 as you scroll
  
  bool _userScrolledAway = false;
  bool _awaitingConversationLoad = false;

  static const double _bottomThreshold = 80;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    
    final offset = _scrollCtrl.offset;
    
    // ═══════════════════════════════════════════════════════════════════════
    // CHATGPT iOS EXACT VALUES (Pixel-Perfect Recreation)
    // ═══════════════════════════════════════════════════════════════════════
    // ChatGPT uses VERY subtle opacity (8-15% max) with STRONG blur (20-30σ)
    // This creates the iconic "barely there" glass effect
    // ═══════════════════════════════════════════════════════════════════════
    
    // STRONG blur: 0σ → 30σ (ChatGPT uses heavy blur for glass effect)
    // Every 4px of scroll adds 1σ (reaches max at 120px)
    final newBlur = (offset / 4).clamp(0.0, 30.0);
    
    // VERY LOW opacity: 0% → 12% (ChatGPT is extremely subtle)
    // This is the key - barely visible background, strong blur
    final newOpacity = (offset / 1000).clamp(0.0, 0.12);
    
    // Show header after minimal scroll (30px)
    final shouldShow = offset > 30;
    
    // Performance: Only update when change is noticeable
    if ((newBlur - _headerBlur).abs() > 0.5 || shouldShow != _showAppBar) {
      setState(() {
        _headerBlur = newBlur;
        _headerOpacity = newOpacity;
        _showAppBar = shouldShow;
      });
    }
    
    // Existing auto-scroll detection (unchanged)
    final distanceFromBottom =
        _scrollCtrl.position.maxScrollExtent - _scrollCtrl.position.pixels;
    final nearBottom = distanceFromBottom <= _bottomThreshold;
    if (_isStreaming) {
      _userScrolledAway = !nearBottom;
    }
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
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: context.cBg,
        extendBodyBehindAppBar: true,
        drawer: const ChatDrawer(),
        body: Stack(
          children: [
            _ChatBackground(),
            
            // ═══════════════════════════════════════════════════════════════
            // CHAT CONTENT - Takes full screen height (no space for header)
            // Messages start from the very top and scroll underneath the header
            // ═══════════════════════════════════════════════════════════════
            Positioned.fill(
              child: Column(
                children: [
                  // Chat Content - NO header here, content starts immediately
                  Expanded(
                    child: BlocConsumer<ChatBloc, ChatState>(
                      listenWhen: (prev, curr) {
                        if (curr is! ChatLoaded) return false;
                        if (prev is! ChatLoaded) return true;
                        return curr.messages.length != prev.messages.length ||
                            curr.isStreaming != prev.isStreaming ||
                            (curr.isStreaming &&
                                curr.streamingContent !=
                                    prev.streamingContent) ||
                            curr.selectedConversation?.id !=
                                prev.selectedConversation?.id ||
                            // Follow multi-model streaming (content changes in place).
                            (curr.messages.isNotEmpty &&
                                prev.messages.isNotEmpty &&
                                curr.messages.last != prev.messages.last);
                      },
                      listener: (context, state) {
                        if (state is! ChatLoaded) return;

                        // Selecting a chat — including re-selecting the one
                        // that's already open — clears its messages then
                        // reloads them. Treat every such reload as "just
                        // opened" and land at the bottom once loaded, even if
                        // the user had scrolled away before.
                        if (state.messages.isEmpty) {
                          _awaitingConversationLoad = true;
                          _userScrolledAway = false;
                        } else if (_awaitingConversationLoad) {
                          _awaitingConversationLoad = false;
                          _scrollToBottom(animated: false);
                        }

                        final liveMulti =
                            state.messages.isNotEmpty &&
                            !state.messages.last.isUser &&
                            state.messages.last.isMultiModel &&
                            state.isSending;
                        final streaming = state.isStreaming || liveMulti;
                        final wasStreaming = _isStreaming;
                        // While a multi-model answer is streaming, each chunk
                        // updates a model's content in place — jumping to the
                        // bottom on every chunk fights the per-model "scroll to
                        // this answer's top" behaviour in _MultiModelCards and
                        // yanks the reader down to whatever is currently the
                        // tallest card. Only auto-scroll for single-model
                        // streaming and for the very first frame a multi-model
                        // answer appears (so the new message is at least
                        // brought into view once).
                        final justStartedMulti = liveMulti && !wasStreaming;

                        if (wasStreaming && !streaming) {
                          // Stream just finished — snap to the bottom even if
                          // the reader had scrolled away to read something else.
                          _userScrolledAway = false;
                          _scrollToBottom(animated: true);
                        } else if ((state.isStreaming || justStartedMulti) &&
                            !_userScrolledAway) {
                          // Instant jump while streaming, smooth animate for new messages
                          _scrollToBottom(animated: !wasStreaming);
                        }
                        _isStreaming = streaming;
                      },
                      builder: (context, state) {
                        // On startup (ChatInitial / ChatLoading) show the home
                        // screen immediately instead of a blocking spinner —
                        // conversations keep loading in the background. This
                        // mirrors ChatGPT / Claude / Gemini, which never gate the
                        // composer behind a full-screen loader.
                        if (state is ChatInitial || state is ChatLoading) {
                          return Column(
                            children: [
                              Expanded(
                                child: ChatEmptyState(
                                  onSuggestion: (text) => context
                                      .read<ChatBloc>()
                                      .add(ChatSendMessageStreaming(text)),
                                ),
                              ),
                              // Composer is visible but disabled until the chat
                              // shell (models/assistants) has loaded.
                              ChatInputBar(enabled: false, onSend: (_) {}),
                            ],
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
                                      color: context.cError.withValues(
                                        alpha: 0.1,
                                      ),
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
                              child:
                                  state.messages.isEmpty &&
                                      !state.isSending &&
                                      !state.isStreaming
                                  ? ChatEmptyState(
                                      onSuggestion: (text) => context
                                          .read<ChatBloc>()
                                          .add(ChatSendMessageStreaming(text)),
                                    )
                                  : _MessagesList(
                                      messages: state.messages,
                                      isSending: state.isSending,
                                      isStreaming: state.isStreaming,
                                      streamingContent:
                                          state.streamingContent ?? '',
                                      scrollCtrl: _scrollCtrl,
                                      chatId: state.selectedConversation?.id,
                                    ),
                            ),
                            ChatInputBar(
                              enabled: !state.isSending && !state.isStreaming,
                              onSend: (text) => context.read<ChatBloc>().add(
                                ChatSendMessageStreaming(text),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // ═══════════════════════════════════════════════════════════════
            // FLOATING ACTION BUTTONS - Always visible (menu + add/profile)
            // These are the ONLY permanently visible elements, NOT a header bar
            // Positioned at top corners, matching ChatGPT iOS exactly
            // ═══════════════════════════════════════════════════════════════
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: const _FloatingHeaderButtons(),
              ),
            ),
            
            // ═══════════════════════════════════════════════════════════════
            // FLOATING GLASS CIRCLES - ChatGPT iOS Exact
            // ═══════════════════════════════════════════════════════════════
            // NO full-width glass bar! Each button is an individual glass circle
            // Messages are visible BETWEEN the circles
            // Left: Menu button (floating glass circle)
            // Right: Edit + More buttons (floating glass circles)
            // ═══════════════════════════════════════════════════════════════
            if (_showAppBar)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: AnimatedOpacity(
                    opacity: _showAppBar ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // LEFT: Menu button (individual glass circle)
                          _GlassCircleButton(
                            icon: Icons.menu_rounded,
                            blurAmount: _headerBlur,
                            opacity: _headerOpacity,
                            onTap: () => Scaffold.of(context).openDrawer(),
                          ),

                          // RIGHT: Action buttons (individual glass circles)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _GlassCircleButton(
                                icon: Icons.edit_outlined,
                                blurAmount: _headerBlur,
                                opacity: _headerOpacity,
                                onTap: () => context.read<ChatBloc>().add(
                                  ChatStartNewConversation(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _GlassCircleButton(
                                icon: Icons.more_horiz_rounded,
                                blurAmount: _headerBlur,
                                opacity: _headerOpacity,
                                onTap: () {
                                  // TODO: Open more menu
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
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

          // Subtle brand glow at top (more visible in light mode for warmth)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.2,
                colors: [
                  AppColors.landingPrimary.withValues(
                    alpha: isDark ? 0.15 : 0.12,
                  ),
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
        linePaint.color = borderColor.withValues(
          alpha: 0.3 * (1.0 - distanceY),
        );
        canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      }
    }
    for (double x = 0; x <= size.width; x += step) {
      final distanceX = (x - centerX).abs() / centerX;
      if (distanceX < 0.8) {
        linePaint.color = borderColor.withValues(
          alpha: 0.3 * (1.0 - distanceX),
        );
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerGridPainter old) => old.borderColor != borderColor;
}

// ══════════════════════════════════════════════════════════════════════════════
// FLOATING HEADER BUTTONS (ChatGPT iOS Style)
// ══════════════════════════════════════════════════════════════════════════════
// These are the ONLY permanently visible elements at the top.
// NO background bar, NO blur, NO container - just two floating circular buttons.
// This matches ChatGPT iOS exactly:
// - Left: Menu button (opens drawer)
// - Right: Add button (new chat) OR Profile button (when no chat active)
// The translucent header bar (_TransparentAppBar) is separate and only appears
// when scrolling up, overlaying these buttons.
// ══════════════════════════════════════════════════════════════════════════════
class _FloatingHeaderButtons extends StatelessWidget {
  const _FloatingHeaderButtons();

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

          // Right button: profile on the welcome screen, "new chat" once a
          // conversation is active.
          BlocBuilder<ChatBloc, ChatState>(
            buildWhen: (prev, curr) {
              bool isEmpty(ChatState s) =>
                  s is! ChatLoaded ||
                  (s.messages.isEmpty && !s.isSending && !s.isStreaming);
              return isEmpty(prev) != isEmpty(curr);
            },
            builder: (context, state) {
              final isChatActive =
                  state is ChatLoaded &&
                  (state.messages.isNotEmpty ||
                      state.isSending ||
                      state.isStreaming);

              if (!isChatActive) {
                return const _ProfileButton();
              }

              return _FloatingButton(
                icon: Icons.add_rounded,
                onPressed: () =>
                    context.read<ChatBloc>().add(ChatStartNewConversation()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Floating Button Widget ───────────────────────────────────────────────────
class _FloatingButton extends StatelessWidget {
  const _FloatingButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? context.cCard.withValues(alpha: 0.5)
                    : context.cCard.withValues(alpha: 0.7),
                border: Border.all(
                  color: context.cBorder.withValues(alpha: isDark ? 0.4 : 0.6),
                  width: isDark ? 1 : 1.5,
                ),
                boxShadow: !isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: context.cFg.withValues(alpha: 0.9),
                size: 27,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Profile button (shows the user's photo when set) ────────────────────────
class _ProfileButton extends StatelessWidget {
  const _ProfileButton();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final profileImageUrl = authState is AuthAuthenticated
        ? authState.user.profileImageUrl
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // TODO: Open profile/account page
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.cCard.withValues(alpha: context.isDark ? 0.5 : 0.9),
            border: Border.all(color: context.cBorder.withValues(alpha: 0.4)),
          ),
          child: profileImageUrl != null && profileImageUrl.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    profileImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.account_circle_outlined,
                      color: context.cFg.withValues(alpha: 0.9),
                      size: 27,
                    ),
                  ),
                )
              : Icon(
                  Icons.account_circle_outlined,
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
    final lastIsLiveMulti =
        messages.isNotEmpty &&
        messages.last.isMultiModel &&
        !messages.last.isUser;
    final extra = lastIsLiveMulti ? 0 : (isStreaming ? 1 : (isSending ? 1 : 0));
    final itemCount = messages.length + extra;

    // ═══════════════════════════════════════════════════════════════════════
    // CHATGPT iOS PADDING STRATEGY
    // ═══════════════════════════════════════════════════════════════════════
    // Top padding: SafeArea + 64px (room for floating buttons + some space)
    // This ensures first message starts in a natural position but can scroll
    // up underneath the translucent header when user scrolls.
    //
    // WHY 64px: Accounts for floating buttons (50px) + breathing room (14px)
    // This matches ChatGPT iOS exactly where first message isn't cramped
    // against the top but naturally scrolls behind the glass header.
    // ═══════════════════════════════════════════════════════════════════════
    final topSafeArea = MediaQuery.of(context).padding.top;
    
    return ListView.builder(
      controller: scrollCtrl,
      padding: EdgeInsets.fromLTRB(
        14,
        topSafeArea + 64,  // Start below floating buttons with spacing
        14,
        12,
      ),
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
                context.read<ChatBloc>().add(
                  ChatSendMessageStreaming(question),
                );
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

// ══════════════════════════════════════════════════════════════════════════════
// CHATGPT IOS INDIVIDUAL GLASS CIRCLE BUTTON
// ══════════════════════════════════════════════════════════════════════════════
// Each button is an independent floating glass circle - NOT connected by a bar
// This matches ChatGPT iOS exactly where buttons float individually
//
// SPECIFICATIONS (ChatGPT iOS Exact):
// - Size: 48×48px circular button
// - Shape: ClipOval (perfect circle)
// - Blur: BackdropFilter(sigmaX: 20, sigmaY: 20)
// - Opacity: Dark mode (white @ 8%), Light mode (white @ 25%)
// - Border: <5% opacity (nearly invisible)
// - NO shadow, NO elevation
// - Messages are visible BETWEEN the circles (no connecting background)
//
// PROGRESSIVE ANIMATION:
// - Blur animates from 0σ → 30σ as user scrolls
// - Opacity animates from 0% → 12% as user scrolls
// - Smooth transition using AnimatedContainer
// ══════════════════════════════════════════════════════════════════════════════
class _GlassCircleButton extends StatelessWidget {
  const _GlassCircleButton({
    required this.icon,
    required this.blurAmount,
    required this.opacity,
    required this.onTap,
  });

  final IconData icon;
  final double blurAmount;   // Progressive: 0-30σ
  final double opacity;      // Progressive: 0-0.12
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),  // Half of 48px for perfect circle
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: blurAmount,
              sigmaY: blurAmount,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Dark mode: white @ 8%, Light mode: white @ 25%
                color: isDark
                    ? Colors.white.withValues(alpha: opacity * 0.67)  // Targets 8% at max
                    : Colors.white.withValues(alpha: opacity * 2.08),  // Targets 25% at max
                    
                // Nearly invisible border (3-4% opacity)
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withValues(
                    alpha: 0.04,
                  ),
                  width: 0.5,
                ),
              ),
              child: Icon(
                icon,
                color: context.cFg.withValues(alpha: 0.9),
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TYPING INDICATOR
// ══════════════════════════════════════════════════════════════════════════════
class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.cCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.cBorder.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TypingDot(delay: 0),
                const SizedBox(width: 4),
                _TypingDot(delay: 150),
                const SizedBox(width: 4),
                _TypingDot(delay: 300),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  const _TypingDot({required this.delay});
  final int delay;

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.3 + (_controller.value * 0.7),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.cFg.withValues(alpha: 0.6),
            ),
          ),
        );
      },
    );
  }
}
