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
      backgroundColor: AppColors.darkBackground,
      drawer: const ChatDrawer(),
      appBar: _ChatAppBar(),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatLoaded) _scrollToBottom();
        },
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.landingPrimary,
                strokeWidth: 2.5,
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
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.darkMutedForeground, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.darkMutedForeground, fontSize: 14),
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
    );
  }
}

// ── AppBar ────────────────────────────────────────────────────────────────────
class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final title = state is ChatLoaded
            ? (state.selectedConversation?.title ?? 'AI Colab')
            : 'AI Colab';

        return AppBar(
          backgroundColor: AppColors.darkCard,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: AppColors.darkCard,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.darkBorder),
          ),
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded,
                  color: AppColors.darkForeground, size: 22),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.darkForeground,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_rounded,
                  color: AppColors.darkForeground, size: 25),
              tooltip: 'New chat',
              onPressed: () =>
                  context.read<ChatBloc>().add(ChatStartNewConversation()),
            ),
            const SizedBox(width: 4),
          ],
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
