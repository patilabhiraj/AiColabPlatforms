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
  String _selectedModel = 'Sonnet 4.6';
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

  void _showModelSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ModelSelectorSheet(
        selectedModel: _selectedModel,
        onSelect: (model) {
          setState(() => _selectedModel = model);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.viewPaddingOf(context).bottom;
    
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkBackground,
      ),
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad > 0 ? bottomPad + 8 : 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkCard.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _isFocused
                ? AppColors.darkBorder.withValues(alpha: 0.35)
                : AppColors.darkBorder.withValues(alpha: 0.2),
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
                style: const TextStyle(
                  color: AppColors.darkForeground,
                  fontSize: 15,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: widget.enabled
                      ? 'Chat with Claude...'
                      : 'AI is thinking…',
                  hintStyle: TextStyle(
                    color: AppColors.darkMutedForeground.withValues(alpha: 0.45),
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
                  
                  // Model selector pill (center)
                  GestureDetector(
                    onTap: widget.enabled ? _showModelSelector : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(
                        color: AppColors.darkBackground.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppColors.darkBorder.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedModel,
                            style: TextStyle(
                              color: AppColors.darkForeground.withValues(alpha: 0.95),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Adaptive',
                            style: TextStyle(
                              color: AppColors.darkMutedForeground.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.darkForeground,
                          ),
                          child: const Icon(
                            Icons.arrow_upward_rounded,
                            color: AppColors.darkBackground,
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
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Icon(
          icon,
          color: onTap != null
              ? AppColors.darkMutedForeground.withValues(alpha: 0.75)
              : AppColors.darkMutedForeground.withValues(alpha: 0.35),
          size: 24,
        ),
      ),
    );
  }
}

// ── Model Selector Sheet ──────────────────────────────────────────────────────
class _ModelSelectorSheet extends StatelessWidget {
  const _ModelSelectorSheet({
    required this.selectedModel,
    required this.onSelect,
  });

  final String selectedModel;
  final ValueChanged<String> onSelect;

  static const _models = [
    ('Sonnet 4.6', 'Most capable model'),
    ('Sonnet 3.5', 'Fast and efficient'),
    ('Opus 3', 'Maximum intelligence'),
    ('Haiku 3', 'Lightning fast'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.darkMutedForeground.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          const Text(
            'Select Model',
            style: TextStyle(
              color: AppColors.darkForeground,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          ..._models.map((model) => _ModelTile(
            name: model.$1,
            description: model.$2,
            isSelected: model.$1 == selectedModel,
            onTap: () => onSelect(model.$1),
          )),
        ],
      ),
    );
  }
}

// ── Model Tile ────────────────────────────────────────────────────────────────
class _ModelTile extends StatelessWidget {
  const _ModelTile({
    required this.name,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.landingPrimary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.landingPrimary.withValues(alpha: 0.3)
                  : AppColors.darkBorder.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.landingPrimary
                            : AppColors.darkForeground,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        color: AppColors.darkMutedForeground.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.landingPrimary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
