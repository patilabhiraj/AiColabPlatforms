import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Claude-style Chat Input Bar
/// Features:
/// - Model selector pill (center)
/// - Attachment button (left)
/// - Voice/Audio button (right)
/// - Clean, minimal design
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key, required this.onSend, this.enabled = true});
  final ValueChanged<String> onSend;
  final bool enabled;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;
  bool _isFocused = false;
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final has = _ctrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
    
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    _animCtrl.forward().then((_) => _animCtrl.reverse());
    _ctrl.clear();
    widget.onSend(text);
  }


  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.viewPaddingOf(context).bottom;
    
    return Container(
      decoration: BoxDecoration(color: context.cBg),
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad > 0 ? bottomPad + 8 : 16),
      child: Container(
        decoration: BoxDecoration(
          color: context.cCard.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _isFocused
                ? context.cBorder.withValues(alpha: 0.55)
                : context.cBorder.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Text field ─────────────────────────────────────────────────
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: TextField(
                controller: _ctrl,
                focusNode: _focusNode,
                enabled: widget.enabled,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: TextStyle(
                  color: context.cFg,
                  fontSize: 15,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: widget.enabled ? 'Chat with Claude...' : 'AI is thinking…',
                  hintStyle: TextStyle(
                    color: context.cMuted.withValues(alpha: 0.6),
                    fontSize: 15,
                  ),
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                ),
              ),
            ),

            // ── Bottom action row ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Row(
                children: [
                  // Attachment button
                  _IconButton(
                    icon: Icons.add_rounded,
                    onTap: widget.enabled ? () {} : null,
                  ),
                  
                  const Spacer(),
                                    
                  // Voice/Send button
                  if (!_hasText)
                    _IconButton(
                      icon: Icons.graphic_eq_rounded,
                      onTap: widget.enabled ? () {} : null,
                    )
                  else
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: GestureDetector(
                        onTap: _send,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.cFg,
                          ),
                          child: Icon(
                            Icons.arrow_upward_rounded,
                            color: context.cBg,
                            size: 20,
                          ),
                        ),
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

// ── Icon Button ───────────────────────────────────────────────────────────────
class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.transparent),
        child: Icon(
          icon,
          color: context.cMuted.withValues(alpha: onTap != null ? 0.75 : 0.35),
          size: 24,
        ),
      ),
    );
  }
}

