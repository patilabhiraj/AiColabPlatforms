import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/theme/app_colors.dart';
import '../../bloc/chat_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/model_response.dart';
import 'catalog_visuals.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
    this.onQuestionTap,
    this.chatId,
  });

  final ChatMessage message;
  final bool isStreaming;
  final void Function(String question)? onQuestionTap;
  final String? chatId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: message.isUser
          ? _UserBubble(message)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _AiBubble(
                  message: message,
                  isStreaming: isStreaming,
                  chatId: chatId,
                ),
                if (!isStreaming &&
                    message.suggestedQuestions != null &&
                    message.suggestedQuestions!.isNotEmpty)
                  _SuggestedQuestionsSection(
                    questions: message.suggestedQuestions!,
                    onTap: onQuestionTap,
                  ),
              ],
            ),
    );
  }
}

// ── User bubble ───────────────────────────────────────────────────────────────
class _UserBubble extends StatelessWidget {
  const _UserBubble(this.message);
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
        child: GestureDetector(
          onLongPress: () => _copy(context, message.content),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: context.isDark
                    ? const [Color(0xFF0F0308), Color(0xFF1B030D)]
                    : [AppColors.landingPrimary, AppColors.landingPrimaryHover],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.landingPrimary.withValues(alpha: 0.3),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              message.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.5,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── AI bubble ─────────────────────────────────────────────────────────────────
class _AiBubble extends StatelessWidget {
  const _AiBubble({
    required this.message,
    required this.isStreaming,
    this.chatId,
  });

  final ChatMessage message;
  final bool isStreaming;
  final String? chatId;

  @override
  Widget build(BuildContext context) {
    final fg = context.cFg;
    final muted = context.cMuted;
    final card = context.cCard;
    final border = context.cBorder;

    final multi = message.isMultiModel;

    // In multi-model mode the displayed content / status comes from the active
    // model's slot; otherwise from the message itself.
    final ModelResponse? active = multi ? _activeResponse() : null;
    final String displayContent = multi ? active!.content : message.content;
    final bool slotStreaming =
        multi && active!.status == ModelResponseStatus.streaming;
    final bool slotFailed =
        multi && active!.status == ModelResponseStatus.failed;
    // Suppress the action bar while any model in this message is still going.
    final bool anyStreaming = multi
        ? message.modelResponses
            .any((r) => r.status == ModelResponseStatus.streaming)
        : isStreaming;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.88),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Model tabs (multi-model) or single model name label.
            if (multi)
              _ModelTabs(message: message)
            else if (message.modelName != null && message.modelName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.smart_toy_outlined, size: 13, color: muted.withValues(alpha: 0.7)),
                    const SizedBox(width: 4),
                    Text(
                      message.modelName!,
                      style: TextStyle(
                        color: muted.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),

            // Bubble
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: border.withValues(alpha: 0.9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: context.isDark ? 0.1 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: displayContent.isEmpty && slotStreaming
                            ? _BlinkingCursor()
                            : MarkdownBody(
                                data: displayContent,
                                selectable: !anyStreaming,
                                styleSheet: MarkdownStyleSheet(
                                  p: TextStyle(
                                      color: slotFailed ? context.cError : fg,
                                      fontSize: 15,
                                      height: 1.6,
                                      letterSpacing: 0.1),
                                  strong: TextStyle(color: fg, fontSize: 15, fontWeight: FontWeight.bold, height: 1.6, letterSpacing: 0.1),
                                  code: TextStyle(
                                    backgroundColor: card.withValues(alpha: 0.5),
                                    color: AppColors.landingPrimary,
                                    fontSize: 14,
                                  ),
                                  codeblockDecoration: BoxDecoration(
                                    color: card.withValues(alpha: context.isDark ? 0.3 : 0.8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                      ),
                      // A trailing cursor is only needed when there is already
                      // some text to trail. `multi ? slotStreaming : isStreaming`
                      // avoids showing two cursors on a multi-model bubble, where
                      // both flags can be true at once.
                      if ((multi ? slotStreaming : isStreaming) &&
                          displayContent.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, top: 4),
                          child: _BlinkingCursor(),
                        ),
                    ],
                  ),

                  // Action bar (hidden while anything is streaming). In
                  // multi-model mode `message.content` is empty — the answer
                  // lives in the active model's slot — so pass [displayContent]
                  // as the text that copy/regenerate should act on.
                  if (!anyStreaming) ...[
                    const SizedBox(height: 10),
                    _ActionBar(
                      message: message,
                      actionContent: displayContent,
                      chatId: chatId,
                      muted: muted,
                      card: card,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The model response for the currently-active tab (falls back to first).
  ModelResponse _activeResponse() {
    return message.modelResponses.firstWhere(
      (r) => r.modelId == message.activeModelId,
      orElse: () => message.modelResponses.first,
    );
  }
}

// ── Per-model tab strip (multi-model messages) ────────────────────────────────
class _ModelTabs extends StatelessWidget {
  const _ModelTabs({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: message.modelResponses.map((mr) {
            final active = mr.modelId == message.activeModelId;
            final color = CatalogVisuals.modelColor(mr.externalId);
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => context
                    .read<ChatBloc>()
                    .add(ChatSelectModelTab(message.id, mr.modelId)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: active
                        ? color.withValues(alpha: 0.14)
                        : context.cCard.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: active
                          ? color.withValues(alpha: 0.5)
                          : context.cBorder.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CatalogVisuals.modelIcon(mr.externalId), size: 13, color: color),
                      const SizedBox(width: 5),
                      Text(
                        mr.modelName,
                        style: TextStyle(
                          color: active
                              ? context.cFg
                              : context.cMuted.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 5),
                      _StatusDot(status: mr.status, color: color),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status, required this.color});
  final ModelResponseStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ModelResponseStatus.streaming:
        return SizedBox(
          width: 8,
          height: 8,
          child: CircularProgressIndicator(strokeWidth: 1.5, color: color),
        );
      case ModelResponseStatus.failed:
        return Icon(Icons.error_outline_rounded, size: 11, color: context.cError);
      case ModelResponseStatus.completed:
        return Icon(Icons.check_circle, size: 11, color: color.withValues(alpha: 0.8));
    }
  }
}

// ── Action Bar ────────────────────────────────────────────────────────────────
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.message,
    required this.actionContent,
    required this.muted,
    required this.card,
    this.chatId,
  });

  final ChatMessage message;

  /// The text copy/share should act on. In multi-model mode this is the active
  /// model's answer (since [message.content] is empty there); in single-model
  /// mode it equals [message.content].
  final String actionContent;
  final Color muted;
  final Color card;
  final String? chatId;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Copy
        _ActionButton(
          icon: Icons.copy_rounded,
          color: muted,
          card: card,
          onTap: () => _copy(context, actionContent),
        ),
        const SizedBox(width: 6),

        // Star / bookmark
        _ActionButton(
          icon: message.isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
          color: muted,
          card: card,
          isActive: message.isStarred,
          activeColor: Colors.amber,
          onTap: () => context.read<ChatBloc>().add(ChatToggleStarMessage(message)),
        ),
        const SizedBox(width: 6),

        // Thumbs up (Like)
        _ActionButton(
          icon: Icons.thumb_up_outlined,
          color: muted,
          card: card,
          isActive: message.isLiked == true,
          activeColor: Colors.green,
          onTap: chatId != null
              ? () {
                  // Toggle like: if already liked, remove feedback; otherwise set to liked
                  final newLikeState = message.isLiked == true ? null : true;
                  context.read<ChatBloc>().add(ChatToggleLikeMessage(message, newLikeState));
                  if (newLikeState != null) {
                    context.read<ChatBloc>().add(ChatSubmitFeedback(chatId!, message.id, true));
                  }
                }
              : () {},
        ),
        const SizedBox(width: 6),

        // Thumbs down (Dislike)
        _ActionButton(
          icon: Icons.thumb_down_outlined,
          color: muted,
          card: card,
          isActive: message.isLiked == false,
          activeColor: Colors.red,
          onTap: chatId != null
              ? () {
                  // Toggle dislike: if already disliked, remove feedback; otherwise set to disliked
                  final newLikeState = message.isLiked == false ? null : false;
                  context.read<ChatBloc>().add(ChatToggleLikeMessage(message, newLikeState));
                  if (newLikeState != null) {
                    context.read<ChatBloc>().add(ChatSubmitFeedback(chatId!, message.id, false));
                  }
                }
              : () {},
        ),
        const SizedBox(width: 6),

        // Regenerate
        _ActionButton(
          icon: Icons.refresh_rounded,
          color: muted,
          card: card,
          onTap: chatId != null
              ? () => context.read<ChatBloc>().add(ChatRegenerateMessage(chatId!, message.id))
              : () {},
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.card,
    required this.onTap,
    this.isActive = false,
    this.activeColor,
  });

  final IconData icon;
  final Color color;
  final Color card;
  final VoidCallback onTap;
  final bool isActive;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isActive ? (activeColor ?? AppColors.landingPrimary) : color.withValues(alpha: 0.8);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive
              ? effectiveColor.withValues(alpha: 0.15)
              : card.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: effectiveColor),
      ),
    );
  }
}

// ── Suggested Questions (Perplexity style — BELOW bubble) ─────────────────────
class _SuggestedQuestionsSection extends StatelessWidget {
  const _SuggestedQuestionsSection({required this.questions, this.onTap});

  final List<String> questions;
  final void Function(String)? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Suggested follow-up questions:',
            style: TextStyle(
              color: context.cMuted.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: questions.map((q) => _QuestionChip(question: q, onTap: onTap)).toList(),
          ),
        ],
      ),
    );
  }
}

class _QuestionChip extends StatelessWidget {
  const _QuestionChip({required this.question, this.onTap});

  final String question;
  final void Function(String)? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(question),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: context.cCard.withValues(alpha: context.isDark ? 0.25 : 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.landingPrimary.withValues(alpha: context.isDark ? 0.3 : 0.25),
          ),
        ),
        child: Text(
          question,
          style: TextStyle(
            color: context.cFg.withValues(alpha: 0.9),
            fontSize: 13,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
void _copy(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Copied to clipboard'),
      duration: Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// ── Typing indicator ──────────────────────────────────────────────────────────
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.landingPrimary.withValues(alpha: 0.15),
                  AppColors.landingPrimary.withValues(alpha: 0.08),
                ],
              ),
              border: Border.all(color: AppColors.landingPrimary.withValues(alpha: 0.3), width: 1.5),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: AppColors.landingPrimary, size: 18),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: context.cCard.withValues(alpha: 0.6),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: context.cBorder.withValues(alpha: 0.4)),
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final phase = ((_ctrl.value - i * 0.25) % 1.0).clamp(0.0, 1.0);
                  final t = phase < 0.5 ? phase * 2 : (1.0 - phase) * 2;
                  return Container(
                    margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.landingPrimary.withValues(alpha: 0.3 + 0.7 * t),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Blinking Cursor ───────────────────────────────────────────────────────────
class _BlinkingCursor extends StatefulWidget {
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 530))..repeat(reverse: true);
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
          opacity: _controller.value,
          child: Container(
            width: 2,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.landingPrimary,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );
      },
    );
  }
}
