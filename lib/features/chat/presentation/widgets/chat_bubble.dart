import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/chat_message.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: message.isUser ? _UserBubble(message) : _AiBubble(message),
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
          maxWidth: MediaQuery.sizeOf(context).width * 0.76,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onLongPress: () => _copy(context, message.content),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: AppColors.landingPrimary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(5),
                  ),
                ),
                child: Text(
                  message.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 2),
              child: Text(
                _fmtTime(message.timestamp),
                style: const TextStyle(
                  color: AppColors.darkMutedForeground,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── AI bubble ─────────────────────────────────────────────────────────────────
class _AiBubble extends StatelessWidget {
  const _AiBubble(this.message);
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.86,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 10, top: 2),
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
                size: 16,
              ),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: SelectableText(
                      message.content,
                      style: const TextStyle(
                        color: AppColors.darkForeground,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, left: 2),
                    child: Row(
                      children: [
                        Text(
                          _fmtTime(message.timestamp),
                          style: const TextStyle(
                            color: AppColors.darkMutedForeground,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => _copy(context, message.content),
                          child: const Icon(
                            Icons.copy_rounded,
                            size: 13,
                            color: AppColors.darkMutedForeground,
                          ),
                        ),
                      ],
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

// ── Helpers ───────────────────────────────────────────────────────────────────
String _fmtTime(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(right: 10),
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
              size: 16,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final phase =
                      ((_ctrl.value - i * 0.22) % 1.0).clamp(0.0, 1.0);
                  final t =
                      phase < 0.5 ? phase * 2 : (1.0 - phase) * 2;
                  return Container(
                    margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.darkMutedForeground
                          .withValues(alpha: 0.3 + 0.7 * t),
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
