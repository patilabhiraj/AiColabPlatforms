import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../bloc/chat_bloc.dart';
import '../../domain/entities/assistant.dart';
import 'catalog_visuals.dart';

/// Premium Empty State with Interactive Elements.
///
/// When an assistant is selected it shows the assistant's icon, name,
/// description and suggested prompts over its own (light/dark aware) gradient.
/// Otherwise it falls back to a time-based greeting.
class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({super.key, required this.onSuggestion});
  final ValueChanged<String> onSuggestion;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (a, b) => b is ChatLoaded,
      builder: (context, state) {
        final assistant =
            state is ChatLoaded ? state.selectedAssistant : null;
        return assistant == null
            ? _buildGreeting(context)
            : _buildAssistant(context, assistant);
      },
    );
  }

  // ── Default greeting ────────────────────────────────────────────────────--
  Widget _buildGreeting(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.8,
          colors: [
            AppColors.landingPrimary.withValues(alpha: 0.12),
            AppColors.landingPrimary.withValues(alpha: 0.05),
            context.cBg.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 80, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 40),
              _FadeInText(
                text: '${_getGreeting()}!',
                delay: 200,
                style: TextStyle(
                  color: context.cFg,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              _FadeInText(
                text: 'How can I help you today?',
                delay: 400,
                style: TextStyle(
                  color: context.cMuted.withValues(alpha: 0.85),
                  fontSize: 17,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 60),
              _FadeInText(
                text: 'Powered by advanced AI models',
                delay: 600,
                style: TextStyle(
                  color: context.cMuted.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Selected assistant ──────────────────────────────────────────────────--
  Widget _buildAssistant(BuildContext context, Assistant assistant) {
    final isDark = context.isDark;
    final gradient = CatalogVisuals.assistantGradient(assistant, isDark: isDark);
    final accent = CatalogVisuals.assistantAccent(assistant, isDark: isDark);
    final onTint = isDark ? Colors.white : Colors.black.withValues(alpha: 0.8);

    final prompts = assistant.suggestedPrompts.isNotEmpty
        ? assistant.suggestedPrompts
        : const ['Brainstorm ideas for…', 'Help me write a…', 'Explain how…'];

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.6,
          colors: [
            gradient.first.withValues(alpha: isDark ? 0.55 : 0.7),
            gradient.last.withValues(alpha: isDark ? 0.25 : 0.35),
            context.cBg.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 80, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              // Icon tile
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [gradient.first, gradient.last],
                  ),
                ),
                child: Icon(
                  CatalogVisuals.assistantIcon(assistant.icon),
                  size: 34,
                  color: onTint,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                assistant.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.cFg,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                assistant.description ?? 'How can I help you today?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.cMuted.withValues(alpha: 0.9),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: prompts
                    .map((p) => _PromptChip(
                          label: p,
                          accent: accent,
                          onTap: () => onSuggestion(p),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Suggested prompt chip ─────────────────────────────────────────────────────
class _PromptChip extends StatelessWidget {
  const _PromptChip({
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: context.cCard.withValues(alpha: context.isDark ? 0.5 : 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline_rounded,
                  size: 14, color: accent),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: context.cFg.withValues(alpha: 0.9),
                    fontSize: 14,
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



// ── Fade In Text ──────────────────────────────────────────────────────────────
class _FadeInText extends StatefulWidget {
  const _FadeInText({
    required this.text,
    required this.delay,
    required this.style,
  });

  final String text;
  final int delay;
  final TextStyle style;

  @override
  State<_FadeInText> createState() => _FadeInTextState();
}

class _FadeInTextState extends State<_FadeInText> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Text(
          widget.text,
          textAlign: TextAlign.center,
          style: widget.style,
        ),
      ),
    );
  }
}
