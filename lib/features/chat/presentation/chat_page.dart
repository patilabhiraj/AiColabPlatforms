import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      drawer: const ChatDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.2,
            colors: [
              AppColors.landingPrimary.withValues(alpha: 0.05),
              AppColors.darkBackground,
              AppColors.darkBackground,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header (replaces AppBar)
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
      ),
    );
  }
}

// ── Custom Header (Replaces AppBar) ──────────────────────────────────────────
class _CustomHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final title = state is ChatLoaded
            ? (state.selectedConversation?.title ?? 'AI Colab')
            : 'AI Colab';

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.darkBackground.withValues(alpha: 0.95),
                AppColors.darkBackground.withValues(alpha: 0.0),
              ],
            ),
          ),
          child: Row(
            children: [
              // Menu button
              Builder(
                builder: (ctx) => IconButton(
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // color: AppColors.darkCard.withValues(alpha: 0.4),
                      border: Border.all(
                        // color: AppColors.darkBorder.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.menu_rounded,
                      color: AppColors.darkForeground,
                      size: 22,
                    ),
                  ),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 12),
              
              // Logo and title
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.landingPrimary.withValues(alpha: 0.15),
                      AppColors.landingPrimary.withValues(alpha: 0.08),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.landingPrimary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.landingPrimary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.darkForeground,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // New chat button
              IconButton(
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.darkCard.withValues(alpha: 0.4),
                    border: Border.all(
                      color: AppColors.darkBorder.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppColors.darkForeground,
                    size: 22,
                  ),
                ),
                tooltip: 'New chat',
                onPressed: () =>
                    context.read<ChatBloc>().add(ChatStartNewConversation()),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );
      },
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
