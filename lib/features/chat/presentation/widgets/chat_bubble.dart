import 'dart:ui';

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
    // Debug logging
    if (!message.isUser) {
      print('🎨 UI DEBUG: Rendering AI message');
      print('🎨 UI DEBUG: isStreaming: $isStreaming');
      print('🎨 UI DEBUG: suggestedQuestions: ${message.suggestedQuestions}');
      print('🎨 UI DEBUG: suggestedQuestions isEmpty: ${message.suggestedQuestions?.isEmpty ?? true}');
    }
    
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
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
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

    // Multi-model messages get a dedicated swipeable card comparison instead of
    // the single-answer bubble below.
    if (multi) {
      return _MultiModelCards(message: message, chatId: chatId);
    }

    final String displayContent = message.content;
    final bool anyStreaming = isStreaming;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.88,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Single model name label.
            if (message.modelName != null && message.modelName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.smart_toy_outlined,
                      size: 13,
                      color: muted.withValues(alpha: 0.7),
                    ),
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

            // Bubble with Glassmorphism Effect ✨
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: context.isDark ? 12 : 8,
                  sigmaY: context.isDark ? 12 : 8,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? card.withValues(alpha: 0.7)
                        : card.withValues(alpha: 0.85),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(
                      color: border.withValues(
                        alpha: context.isDark ? 0.9 : 1.0,
                      ),
                      width: context.isDark ? 1 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: context.isDark ? 0.1 : 0.06,
                        ),
                        blurRadius: context.isDark ? 8 : 12,
                        offset: Offset(0, context.isDark ? 2 : 3),
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
                        child: displayContent.isEmpty && isStreaming
                            ? _BlinkingCursor()
                            : MarkdownBody(
                                data: displayContent,
                                selectable: !anyStreaming,
                                styleSheet: MarkdownStyleSheet(
                                  p: TextStyle(
                                    color: fg,
                                    fontSize: 15,
                                    height: 1.6,
                                    letterSpacing: 0.1,
                                  ),
                                  strong: TextStyle(
                                    color: fg,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    height: 1.6,
                                    letterSpacing: 0.1,
                                  ),
                                  code: TextStyle(
                                    backgroundColor: context.isDark
                                        ? card.withValues(alpha: 0.5)
                                        : AppColors.lightMuted,
                                    // Dark maroon reads poorly on the dark card,
                                    // so use a lighter pink there.
                                    color: context.isDark
                                        ? const Color(0xFFFF6FA5)
                                        : AppColors.landingPrimary,
                                    fontSize: 14,
                                  ),
                                  codeblockDecoration: BoxDecoration(
                                    color: context.isDark
                                        ? card.withValues(alpha: 0.3)
                                        : AppColors.lightMuted,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: border.withValues(
                                        alpha: context.isDark ? 0.3 : 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      // A trailing cursor only when there is already some text
                      // to trail.
                      if (isStreaming && displayContent.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, top: 4),
                          child: _BlinkingCursor(),
                        ),
                    ],
                  ),

                  // Action bar (hidden while streaming).
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Multi-model comparison (swipeable per-model cards) ────────────────────────
/// Shows each model's answer as its own card that the user swipes between to
/// compare. Each card is outlined in that model's brand colour. A small pill
/// strip above doubles as a page indicator and lets the user jump directly to
/// a model.
class _MultiModelCards extends StatefulWidget {
  const _MultiModelCards({required this.message, this.chatId});

  final ChatMessage message;
  final String? chatId;

  @override
  State<_MultiModelCards> createState() => _MultiModelCardsState();
}

class _MultiModelCardsState extends State<_MultiModelCards> {
  final _topKey = GlobalKey();

  List<ModelResponse> get _responses => widget.message.modelResponses;

  int get _activeIndex {
    if (_responses.isEmpty) return 0;
    final i = _responses.indexWhere(
      (r) => r.modelId == widget.message.activeModelId,
    );
    return i < 0 ? 0 : i;
  }

  @override
  void didUpdateWidget(_MultiModelCards old) {
    super.didUpdateWidget(old);
    // When the active model changes (swipe or pill tap), the new card can be
    // a very different height than the old one, and the surrounding chat
    // ListView keeps whatever scroll offset it already had — landing the user
    // somewhere in the middle (often near the bottom) of the new answer
    // instead of its start. Scroll this message's top back into view so every
    // model switch reliably starts the reader at the top of the new answer.
    if (old.message.activeModelId != widget.message.activeModelId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _topKey.currentContext;
        if (ctx == null || !mounted) return;
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: 0,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = _activeIndex;
    final active = _responses.isEmpty ? null : _responses[index];

    return Column(
      key: _topKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Page-indicator pill strip (also tappable → switches the shown card).
        _ModelPills(
          responses: _responses,
          activeModelId: widget.message.activeModelId,
          onTap: _selectModel,
        ),
        const SizedBox(height: 8),

        // Only the active model's card is ever built — never all of them —
        // so a message with many models (9+) stays cheap no matter how many
        // there are; that eager-building is what caused an ANR in earlier
        // Row/ListView/PageView attempts. The card takes its own natural
        // height (no inner scroll, no fixed height), so the *chat list*
        // scrolls it like any other message — matching how ChatGPT etc. show
        // a full response inline instead of trapping it in a scrollable box.
        // A horizontal swipe here switches to the next/previous model; a
        // vertical drag is left alone so it reaches the chat list untouched.
        if (active != null)
          GestureDetector(
            key: ValueKey(active.modelId),
            behavior: HitTestBehavior.translucent,
            onHorizontalDragEnd: (details) {
              final v = details.primaryVelocity ?? 0;
              if (v < -200) {
                _selectByOffset(index, 1);
              } else if (v > 200) {
                _selectByOffset(index, -1);
              }
            },
            child: _ModelCard(
              response: active,
              messageId: widget.message.id,
              chatId: widget.chatId,
            ),
          ),

        // Swipe hint (only when more than one card).
        if (_responses.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 4),
            child: Center(
              child: Text(
                'Swipe to compare  ·  ${_responses.length} models',
                style: TextStyle(
                  color: context.cMuted.withValues(alpha: 0.45),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _selectByOffset(int currentIndex, int delta) {
    final next = (currentIndex + delta).clamp(0, _responses.length - 1);
    if (next == currentIndex) return;
    _selectModel(_responses[next].modelId);
  }

  void _selectModel(int modelId) {
    if (modelId == widget.message.activeModelId) return;
    context.read<ChatBloc>().add(
      ChatSelectModelTab(widget.message.id, modelId),
    );
  }
}

// ── Single model card ─────────────────────────────────────────────────────────
class _ModelCard extends StatefulWidget {
  const _ModelCard({
    required this.response,
    required this.messageId,
    this.chatId,
  });

  final ModelResponse response;
  final String messageId;
  final String? chatId;

  @override
  State<_ModelCard> createState() => _ModelCardState();
}

class _ModelCardState extends State<_ModelCard> {
  // Per-card feedback state. ModelResponse carries no isLiked/isStarred, so we
  // track the user's choice locally for instant visual feedback while the
  // backend call fires in the background. null = no feedback, true = liked.
  bool? _isLiked;
  bool _isStarred = false;

  ModelResponse get response => widget.response;
  String get messageId => widget.messageId;
  String? get chatId => widget.chatId;

  @override
  Widget build(BuildContext context) {
    final color = CatalogVisuals.modelColor(response.externalId);
    final streaming = response.status == ModelResponseStatus.streaming;
    final failed = response.status == ModelResponseStatus.failed;
    final fg = context.cFg;

    return Container(
      decoration: BoxDecoration(
        color: context.cCard.withValues(alpha: context.isDark ? 0.3 : 0.6),
        borderRadius: BorderRadius.circular(16),
        // A calm, thin border in the model's colour — enough to identify the
        // model without the heavy glow the previous design had.
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        // IntrinsicHeight lets the accent-bar Row stretch to match the
        // content column's natural height without needing a bounded height
        // from its parent (there isn't one now that the card sizes itself).
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thin colour accent down the left edge — subtle model identity.
              Container(width: 3, color: color.withValues(alpha: 0.7)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 14, 10, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header: avatar + name + status ──────────────────────
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: CatalogVisuals.modelAvatar(
                                response.externalId,
                                size: 19,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              response.modelName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: fg,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusDot(status: response.status, color: color),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ── Content — natural height, no inner scroll. The card
                      //    grows to fit the whole answer, and the surrounding
                      //    chat list (a ListView) is what scrolls — exactly like
                      //    a normal single-model bubble, so a long response
                      //    reads inline instead of being trapped in a box.
                      response.content.isEmpty && streaming
                          ? Row(children: [_BlinkingCursor()])
                          : MarkdownBody(
                              data: response.content,
                              selectable: !streaming,
                              styleSheet: MarkdownStyleSheet(
                                p: TextStyle(
                                  color: failed ? context.cError : fg,
                                  fontSize: 14.5,
                                  height: 1.55,
                                  letterSpacing: 0.1,
                                ),
                                strong: TextStyle(
                                  color: fg,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  height: 1.55,
                                ),
                                code: TextStyle(
                                  backgroundColor: context.cCard.withValues(
                                    alpha: 0.5,
                                  ),
                                  color: color,
                                  fontSize: 13.5,
                                ),
                                codeblockDecoration: BoxDecoration(
                                  color: context.cCard.withValues(
                                    alpha: context.isDark ? 0.3 : 0.8,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                      if (!streaming && response.suggestedQuestions.isNotEmpty)
                        _ModelSuggestedQuestions(
                          questions: response.suggestedQuestions,
                          color: color,
                        ),

                      // ── Footer: full action row + "Use this" (hidden while
                      //    streaming). The actions scroll horizontally so they
                      //    never overflow the card.
                      if (!streaming) ...[
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const ClampingScrollPhysics(),
                          child: Row(
                            children: [
                              _ActionButton(
                                icon: Icons.copy_rounded,
                                color: context.cMuted,
                                card: context.cCard,
                                onTap: () => _copy(context, response.content),
                              ),
                              const SizedBox(width: 6),
                              _ActionButton(
                                icon: _isStarred
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: context.cMuted,
                                card: context.cCard,
                                isActive: _isStarred,
                                activeColor: Colors.amber,
                                onTap: () {
                                  setState(() => _isStarred = !_isStarred);
                                  context.read<ChatBloc>().add(
                                    ChatToggleStarMessage(_messageForActions()),
                                  );
                                },
                              ),
                              const SizedBox(width: 6),
                              _ActionButton(
                                icon: Icons.thumb_up_outlined,
                                color: context.cMuted,
                                card: context.cCard,
                                isActive: _isLiked == true,
                                activeColor: Colors.green,
                                onTap: () => _toggleFeedback(context, true),
                              ),
                              const SizedBox(width: 6),
                              _ActionButton(
                                icon: Icons.thumb_down_outlined,
                                color: context.cMuted,
                                card: context.cCard,
                                isActive: _isLiked == false,
                                activeColor: Colors.red,
                                onTap: () => _toggleFeedback(context, false),
                              ),
                              const SizedBox(width: 6),
                              _ActionButton(
                                icon: Icons.ios_share_rounded,
                                color: context.cMuted,
                                card: context.cCard,
                                onTap: () => _copy(context, response.content),
                              ),
                              const SizedBox(width: 6),
                              _ActionButton(
                                icon: Icons.refresh_rounded,
                                color: context.cMuted,
                                card: context.cCard,
                                onTap: chatId != null
                                    ? () => context.read<ChatBloc>().add(
                                        ChatRegenerateMessage(
                                          chatId!,
                                          messageId,
                                        ),
                                      )
                                    : () {},
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A lightweight [ChatMessage] representing this model's slot, so the star
  /// action (which operates on messages) can target the right content.
  ChatMessage _messageForActions() => ChatMessage(
    id: messageId,
    content: response.content,
    isUser: false,
    timestamp: DateTime.now(),
    modelName: response.modelName,
  );

  /// Toggles like/dislike for this model's response, mirroring the single-model
  /// action bar: tapping the active choice again clears it. Updates the local
  /// state for instant visual feedback and submits to the backend when set.
  void _toggleFeedback(BuildContext context, bool positive) {
    // Tapping the already-selected choice removes the feedback.
    final next = _isLiked == positive ? null : positive;
    setState(() => _isLiked = next);

    // Only send a value to the backend; clearing is a UI-only reset here since
    // the feedback endpoint takes a definite positive/negative.
    if (next != null && chatId != null) {
      context.read<ChatBloc>().add(
        ChatSubmitFeedback(chatId!, messageId, next),
      );
    }
  }
}

// ── Per-model suggested follow-up questions (inside a model card) ─────────────
class _ModelSuggestedQuestions extends StatefulWidget {
  const _ModelSuggestedQuestions({
    required this.questions,
    required this.color,
  });

  final List<String> questions;
  final Color color;

  @override
  State<_ModelSuggestedQuestions> createState() =>
      _ModelSuggestedQuestionsState();
}

class _ModelSuggestedQuestionsState extends State<_ModelSuggestedQuestions> {
  // Guards against a fast double-tap (or tapping two different questions in
  // quick succession) sending more than one message: the whole section locks
  // as soon as the first tap fires.
  bool _sent = false;

  List<String> get questions => widget.questions;
  Color get color => widget.color;

  void _send(String question) {
    if (_sent) return;
    setState(() => _sent = true);
    context.read<ChatBloc>().add(ChatSendMessageStreaming(question));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      // Dims the whole section once a question has been sent, as a visual
      // confirmation that the tap registered (and that it's now inert).
      opacity: _sent ? 0.4 : 1,
      duration: const Duration(milliseconds: 150),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtle divider so the questions read as a distinct section below
            // the answer rather than running into it.
            Divider(
              height: 1,
              thickness: 1,
              color: context.cBorder.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 13,
                  color: color.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 6),
                Text(
                  'Suggested follow-ups',
                  style: TextStyle(
                    color: context.cMuted.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < questions.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i == questions.length - 1 ? 0 : 8,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _sent ? null : () => _send(questions[i]),
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                questions[i],
                                style: TextStyle(
                                  color: context.cFg.withValues(alpha: 0.92),
                                  fontSize: 13.5,
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 15,
                                color: color,
                              ),
                            ),
                          ],
                        ),
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

// ── Model pill strip (page indicator for the cards) ───────────────────────────
class _ModelPills extends StatelessWidget {
  const _ModelPills({
    required this.responses,
    required this.activeModelId,
    required this.onTap,
  });

  final List<ModelResponse> responses;
  final int? activeModelId;
  final void Function(int modelId) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(left: 2),
        itemCount: responses.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final mr = responses[i];
          final active = mr.modelId == activeModelId;
          final color = CatalogVisuals.modelColor(mr.externalId);
          return GestureDetector(
            onTap: () => onTap(mr.modelId),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: active
                    ? color.withValues(alpha: 0.16)
                    : context.cCard.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: active
                      ? color.withValues(alpha: 0.6)
                      : context.cBorder.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CatalogVisuals.modelAvatar(mr.externalId, size: 13),
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
          );
        },
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
        return Icon(
          Icons.error_outline_rounded,
          size: 11,
          color: context.cError,
        );
      case ModelResponseStatus.completed:
        return Icon(
          Icons.check_circle,
          size: 11,
          color: color.withValues(alpha: 0.8),
        );
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
          icon: message.isStarred
              ? Icons.star_rounded
              : Icons.star_outline_rounded,
          color: muted,
          card: card,
          isActive: message.isStarred,
          activeColor: Colors.amber,
          onTap: () =>
              context.read<ChatBloc>().add(ChatToggleStarMessage(message)),
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
                  context.read<ChatBloc>().add(
                    ChatToggleLikeMessage(message, newLikeState),
                  );
                  if (newLikeState != null) {
                    context.read<ChatBloc>().add(
                      ChatSubmitFeedback(chatId!, message.id, true),
                    );
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
                  context.read<ChatBloc>().add(
                    ChatToggleLikeMessage(message, newLikeState),
                  );
                  if (newLikeState != null) {
                    context.read<ChatBloc>().add(
                      ChatSubmitFeedback(chatId!, message.id, false),
                    );
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
              ? () => context.read<ChatBloc>().add(
                  ChatRegenerateMessage(chatId!, message.id),
                )
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
    final effectiveColor = isActive
        ? (activeColor ?? AppColors.landingPrimary)
        : color.withValues(alpha: 0.8);
    final isDark = context.isDark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive
              ? effectiveColor.withValues(alpha: isDark ? 0.15 : 0.1)
              : card.withValues(alpha: isDark ? 0.4 : 0.05),
          borderRadius: BorderRadius.circular(6),
          border: !isDark
              ? Border.all(
                  color: context.cBorder.withValues(alpha: 0.3),
                  width: 0.5,
                )
              : null,
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
            children: questions
                .map((q) => _QuestionChip(question: q, onTap: onTap))
                .toList(),
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
    final isDark = context.isDark;
    return GestureDetector(
      onTap: () => onTap?.call(question),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isDark
                  ? context.cCard.withValues(alpha: 0.25)
                  : AppColors.lightAccent.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.landingPrimary.withValues(
                  alpha: isDark ? 0.3 : 0.4,
                ),
                width: isDark ? 1 : 1.5,
              ),
              boxShadow: !isDark
                  ? [
                      BoxShadow(
                        color: AppColors.landingPrimary.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              question,
              style: TextStyle(
                color: context.cFg.withValues(alpha: 0.9),
                fontSize: 13,
                height: 1.3,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
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
              border: Border.all(
                color: AppColors.landingPrimary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.landingPrimary,
              size: 18,
            ),
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
                  final phase = ((_ctrl.value - i * 0.25) % 1.0).clamp(
                    0.0,
                    1.0,
                  );
                  final t = phase < 0.5 ? phase * 2 : (1.0 - phase) * 2;
                  return Container(
                    margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.landingPrimary.withValues(
                        alpha: 0.3 + 0.7 * t,
                      ),
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
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
