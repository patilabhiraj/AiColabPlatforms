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
    // Quick-start prompts mirror the web new-chat screen (Brainstorm / Write /
    // Explain) — tapping one pre-fills the composer via [onSuggestion].
    const quickStarts = <_QuickStart>[
      _QuickStart(
        icon: Icons.auto_awesome_rounded,
        title: 'Brainstorm ideas',
        subtitle: 'Spark creativity for your next project',
        prompt: 'Brainstorm ideas for ',
      ),
      _QuickStart(
        icon: Icons.edit_note_rounded,
        title: 'Help me write',
        subtitle: 'Draft an email, post or document',
        prompt: 'Help me write a ',
      ),
      _QuickStart(
        icon: Icons.school_rounded,
        title: 'Explain a concept',
        subtitle: 'Understand any topic clearly',
        prompt: 'Explain how ',
      ),
    ];

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
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const _AiOrb(),
              const SizedBox(height: 32),
              _FadeInText(
                text: '${_getGreeting()}!',
                delay: 200,
                style: TextStyle(
                  color: context.cFg,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              _FadeInText(
                text: 'How can I help you today?',
                delay: 350,
                style: TextStyle(
                  color: context.cMuted.withValues(alpha: 0.85),
                  fontSize: 17,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),
              // Quick-start cards
              for (var i = 0; i < quickStarts.length; i++) ...[
                _FadeInSlide(
                  delay: 500 + i * 120,
                  child: _QuickStartCard(
                    data: quickStarts[i],
                    onTap: () => onSuggestion(quickStarts[i].prompt),
                  ),
                ),
                if (i != quickStarts.length - 1) const SizedBox(height: 12),
              ],
              const SizedBox(height: 28),
              _FadeInText(
                text: 'Powered by advanced AI models',
                delay: 900,
                style: TextStyle(
                  color: context.cMuted.withValues(alpha: 0.55),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
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

// ── Quick-start data ──────────────────────────────────────────────────────────
class _QuickStart {
  const _QuickStart({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.prompt,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String prompt;
}

// ── Animated AI orb ───────────────────────────────────────────────────────────
/// A softly breathing, glowing gradient orb — the signature "AI" visual that
/// anchors the welcome screen.
class _AiOrb extends StatefulWidget {
  const _AiOrb();

  @override
  State<_AiOrb> createState() => _AiOrbState();
}

class _AiOrbState extends State<_AiOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = AppColors.landingPrimary;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_ctrl.value);
        final scale = 0.94 + t * 0.06;
        final glow = 0.35 + t * 0.35;
        return Container(
          width: 96,
          height: 96,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: glow * 0.5),
                blurRadius: 40 + t * 20,
                spreadRadius: 4 + t * 6,
              ),
            ],
          ),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(primary, Colors.white, 0.25)!,
                    primary,
                    Color.lerp(primary, Colors.black, 0.25)!,
                  ],
                ),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white.withValues(alpha: 0.95),
                size: 34,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Quick-start card ──────────────────────────────────────────────────────────
class _QuickStartCard extends StatelessWidget {
  const _QuickStartCard({required this.data, required this.onTap});

  final _QuickStart data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.landingPrimary;
    final isDark = context.isDark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: context.cCard.withValues(alpha: isDark ? 0.45 : 0.85),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.cBorder.withValues(alpha: 0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                // Icon tile
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent.withValues(alpha: 0.9),
                        accent.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                  child: Icon(data.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: TextStyle(
                          color: context.cFg,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        data.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.cMuted.withValues(alpha: 0.75),
                          fontSize: 12.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_outward_rounded,
                  size: 18,
                  color: context.cMuted.withValues(alpha: 0.55),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Fade + slide entrance ─────────────────────────────────────────────────────
class _FadeInSlide extends StatefulWidget {
  const _FadeInSlide({required this.child, required this.delay});

  final Widget child;
  final int delay;

  @override
  State<_FadeInSlide> createState() => _FadeInSlideState();
}

class _FadeInSlideState extends State<_FadeInSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final Animation<double> _fade =
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.18),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
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
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
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
