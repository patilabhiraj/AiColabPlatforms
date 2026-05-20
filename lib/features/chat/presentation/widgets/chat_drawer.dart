import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../bloc/chat_bloc.dart';
import 'conversation_tile.dart';

class ChatDrawer extends StatelessWidget {
  const ChatDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.darkSidebar,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.landingPrimary.withValues(alpha: 0.12),
                      border: Border.all(
                        color: AppColors.landingPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.all_inclusive_rounded,
                      color: AppColors.landingPrimary,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'AI Colab',
                    style: TextStyle(
                      color: AppColors.darkForeground,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.darkMutedForeground,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // ── New Chat button ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: AppRadius.borderLg,
                  onTap: () {
                    context
                        .read<ChatBloc>()
                        .add(ChatStartNewConversation());
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.borderLg,
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add_rounded,
                            size: 18, color: AppColors.darkForeground),
                        SizedBox(width: 8),
                        Text(
                          'New Chat',
                          style: TextStyle(
                            color: AppColors.darkForeground,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Section label ────────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                'RECENT',
                style: TextStyle(
                  color: AppColors.darkMutedForeground,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // ── Conversation list ────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is! ChatLoaded) return const SizedBox();

                  if (state.conversations.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No conversations yet.\nStart a new chat!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.darkMutedForeground,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: state.conversations.length,
                    itemBuilder: (context, index) {
                      final conv = state.conversations[index];
                      final isSelected =
                          state.selectedConversation?.id == conv.id;
                      return ConversationTile(
                        conversation: conv,
                        isSelected: isSelected,
                        onTap: () {
                          context
                              .read<ChatBloc>()
                              .add(ChatSelectConversation(conv));
                          Navigator.pop(context);
                        },
                        onDelete: () => Navigator.pop(context),
                      );
                    },
                  );
                },
              ),
            ),

            const Divider(color: AppColors.darkBorder, height: 1),

            // ── Profile footer ───────────────────────────────────────────────
            const _ProfileFooter(),
          ],
        ),
      ),
    );
  }
}

class _ProfileFooter extends StatelessWidget {
  const _ProfileFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Avatar circle with initial
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.landingPrimary.withValues(alpha: 0.15),
              border: Border.all(
                color: AppColors.landingPrimary.withValues(alpha: 0.4),
              ),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.landingPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Account',
                  style: TextStyle(
                    color: AppColors.darkForeground,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.darkMutedForeground,
              size: 20,
            ),
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }
}
