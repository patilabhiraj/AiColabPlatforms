import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../bloc/chat_bloc.dart';
import '../../../domain/entities/chat_conversation.dart';
import '../../pages/starred_messages_page.dart';
import 'section_header.dart';

class ChatsSection extends StatelessWidget {
  const ChatsSection({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.onChatTap,
  });

  final bool isExpanded;
  final VoidCallback onToggle;
  final Function(ChatConversation) onChatTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SectionHeader(
            title: 'CHATS',
            isExpanded: isExpanded,
            onToggle: onToggle,
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
              size: 20,
              color: context.cMuted.withValues(alpha: 0.6),
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 8),
            BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is! ChatLoaded) {
                  return const SizedBox();
                }

                if (state.conversations.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No chats yet',
                      style: TextStyle(
                        color: context.cMuted.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  );
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Starred Messages — tappable row
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context); // close drawer
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<ChatBloc>(),
                                child: const StarredMessagesPage(),
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star_rounded, size: 18, color: Colors.amber.withValues(alpha: 0.9)),
                              const SizedBox(width: 8),
                              Text(
                                'Starred Messages',
                                style: TextStyle(
                                  color: context.cFg.withValues(alpha: 0.85),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              BlocBuilder<ChatBloc, ChatState>(
                                buildWhen: (p, c) {
                                  if (p is ChatLoaded && c is ChatLoaded) {
                                    return p.starredMessages.length != c.starredMessages.length;
                                  }
                                  return false;
                                },
                                builder: (context, state) {
                                  if (state is! ChatLoaded || state.starredMessages.isEmpty) {
                                    return const SizedBox();
                                  }
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${state.starredMessages.length}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Chat items
                    ...state.conversations.map((conversation) {
                      final isSelected = state.selectedConversation?.id == conversation.id;
                      return _ChatItem(
                        title: conversation.title,
                        isSelected: isSelected,
                        onTap: () => onChatTap(conversation),
                        onMore: () => _showChatOptions(context, conversation),
                      );
                    }),
                    
                    const SizedBox(height: 8),
                    if (state.hasMoreConversations)
                      _LoadMoreButton(
                        isLoading: state.isLoadingMoreConversations,
                        onTap: () => context
                            .read<ChatBloc>()
                            .add(ChatLoadMoreConversations()),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  void _showChatOptions(BuildContext context, ChatConversation conversation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit_outlined, color: sheetContext.cFg),
              title: Text('Rename', style: TextStyle(color: sheetContext.cFg)),
              onTap: () => Navigator.pop(sheetContext),
            ),
            ListTile(
              leading: Icon(Icons.star_outline_rounded, color: sheetContext.cFg),
              title: Text('Star', style: TextStyle(color: sheetContext.cFg)),
              onTap: () => Navigator.pop(sheetContext),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                context.read<ChatBloc>().add(ChatDeleteConversation(conversation.id));
                Navigator.pop(sheetContext);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatItem extends StatelessWidget {
  const _ChatItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.onMore,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? context.cCard.withValues(alpha: context.isDark ? 0.3 : 1)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 18,
                color: context.cMuted.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: context.cFg.withValues(alpha: 0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: onMore,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_horiz_rounded,
                    size: 18,
                    color: context.cMuted.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.onTap, this.isLoading = false});

  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.cMuted.withValues(alpha: 0.7),
                    ),
                  )
                : Text(
                    'Load More Chats',
                    style: TextStyle(
                      color: context.cMuted.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
