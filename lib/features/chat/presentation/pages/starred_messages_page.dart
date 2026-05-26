import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/theme/app_colors.dart';
import '../../bloc/chat_bloc.dart';
import '../../domain/entities/chat_message.dart';

class StarredMessagesPage extends StatelessWidget {
  const StarredMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cBg,
      appBar: AppBar(
        backgroundColor: context.cBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.cFg),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(Icons.star_rounded, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text(
              'Starred Messages',
              style: TextStyle(color: context.cFg, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: context.cBorder.withValues(alpha: 0.4), height: 1),
        ),
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        buildWhen: (prev, curr) {
          if (prev is ChatLoaded && curr is ChatLoaded) {
            return prev.starredMessages != curr.starredMessages;
          }
          return true;
        },
        builder: (context, state) {
          if (state is! ChatLoaded) {
            return Center(child: CircularProgressIndicator(color: AppColors.landingPrimary));
          }

          final starred = state.starredMessages;

          if (starred.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_outline_rounded, size: 56, color: context.cMuted.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text(
                    'No starred messages yet',
                    style: TextStyle(color: context.cMuted, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the star icon on any AI response\nto save it here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.cMuted.withValues(alpha: 0.6), fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: starred.length,
            separatorBuilder: (_, i) =>
                Divider(color: context.cBorder.withValues(alpha: 0.3), height: 24),
            itemBuilder: (context, index) =>
                _StarredMessageTile(message: starred[index]),
          );
        },
      ),
    );
  }
}

class _StarredMessageTile extends StatelessWidget {
  const _StarredMessageTile({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final card = context.cCard;
    final border = context.cBorder;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card.withValues(alpha: context.isDark ? 0.3 : 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Model label + timestamp row
          Row(
            children: [
              if (message.modelName != null && message.modelName!.isNotEmpty) ...[
                Icon(Icons.smart_toy_outlined, size: 13, color: context.cMuted.withValues(alpha: 0.7)),
                const SizedBox(width: 4),
                Text(
                  message.modelName!,
                  style: TextStyle(color: context.cMuted.withValues(alpha: 0.7), fontSize: 12),
                ),
                const SizedBox(width: 8),
              ],
              const Spacer(),
              Text(
                _formatTime(message.timestamp),
                style: TextStyle(color: context.cMuted.withValues(alpha: 0.5), fontSize: 11),
              ),
              const SizedBox(width: 8),
              // Unstar button
              GestureDetector(
                onTap: () => context.read<ChatBloc>().add(ChatToggleStarMessage(message)),
                child: const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Message content
          MarkdownBody(
            data: message.content,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(color: context.cFg, fontSize: 14, height: 1.6),
              strong: TextStyle(color: context.cFg, fontWeight: FontWeight.bold, fontSize: 14, height: 1.6),
              code: TextStyle(
                backgroundColor: card.withValues(alpha: 0.5),
                color: AppColors.landingPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dt.weekday - 1];
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }
}
