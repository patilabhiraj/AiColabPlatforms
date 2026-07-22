import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/bloc/auth_bloc.dart';
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
        final assistant = state is ChatLoaded ? state.selectedAssistant : null;
        return assistant == null
            ? _buildGreeting(context)
            : _buildAssistant(context, assistant);
      },
    );
  }

  // ── Default greeting ────────────────────────────────────────────────────--
  /// A calm, ChatGPT/Claude-style welcome: a small labelled greeting, a bold
  /// headline, and (when one exists) a "Continue" card to resume the most
  /// recent conversation.
  Widget _buildGreeting(BuildContext context) {
    // First name for the greeting label (falls back to a plain greeting).
    final authState = context.watch<AuthBloc>().state;
    final firstName = authState is AuthAuthenticated
        ? authState.user.firstName.trim()
        : '';

    final greeting = firstName.isNotEmpty
        ? '${_getGreeting()}, $firstName'
        : _getGreeting();

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
      // A Stack lets us paint soft, drifting ambient orbs *behind* the welcome
      // text so the otherwise-empty lower half feels alive and "filled" —
      // without adding any actual content the user has to read or tap.
      child: Stack(
        children: [
          const Positioned.fill(child: _AmbientOrbs()),

          // Anchor the welcome block toward the upper third of the screen rather
          // than dead-centre. With only the greeting + headline present,
          // `Center` left a large, unbalanced empty gap above and below;
          // aligning it high (fixed top offset that clears the floating header)
          // keeps it visually tied to the header and reads as intentional.
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                MediaQuery.of(context).padding.top + 96,
                24,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                // ── Small labelled greeting (orb + "Good afternoon, Abhiraj 👋") ─
                _FadeInSlide(
                  delay: 150,
                  child: Row(
                    children: [
                      const _MiniOrb(),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          greeting,
                          style: TextStyle(
                            color: context.cMuted.withValues(alpha: 0.9),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('👋', style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Headline + mascot ────────────────────────────────────────────
                _FadeInSlide(
                  delay: 300,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          // Extra bottom room so the squiggle underline (drawn
                          // 10px below the text) never clips into the mascot row.
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Soft glow directly behind the headline so the
                              // text feels lit from within rather than floating
                              // on a flat background.
                              Positioned(
                                left: -12,
                                top: 6,
                                child: Container(
                                  width: 150,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [
                                        AppColors.landingPrimary.withValues(
                                          alpha: context.isDark ? 0.22 : 0.12,
                                        ),
                                        AppColors.landingPrimary.withValues(
                                          alpha: 0.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Headline: first two lines in the foreground
                              // colour, and "together?" painted with a
                              // magenta→violet gradient (via a WidgetSpan that
                              // shader-masks only that word) for a richer,
                              // premium finish.
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: context.cFg,
                                    fontSize: 33,
                                    fontWeight: FontWeight.w800,
                                    height: 1.18,
                                    letterSpacing: -0.9,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'What should\nwe figure out\n',
                                    ),
                                    WidgetSpan(
                                      child: ShaderMask(
                                        shaderCallback: (bounds) =>
                                            const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                AppColors.landingPrimary,
                                                Color(0xFFC2185B),
                                                Color(0xFF8B5CF6),
                                              ],
                                            ).createShader(bounds),
                                        child: const Text(
                                          'together?',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 33,
                                            fontWeight: FontWeight.w800,
                                            height: 1.18,
                                            letterSpacing: -0.9,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                left: 2,
                                bottom: -2,
                                child: CustomPaint(
                                  size: const Size(96, 10),
                                  painter: _SquigglePainter(
                                    color: AppColors.landingPrimary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const _MascotOrb(),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Selected assistant ──────────────────────────────────────────────────--
  Widget _buildAssistant(BuildContext context, Assistant assistant) {
    final isDark = context.isDark;
    final gradient = CatalogVisuals.assistantGradient(
      assistant,
      isDark: isDark,
    );
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
                    .map(
                      (p) => _PromptChip(
                        label: p,
                        accent: accent,
                        onTap: () => onSuggestion(p),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Ambient background orbs ───────────────────────────────────────────────────
/// Soft, blurred, slowly drifting colour orbs painted behind the welcome text.
/// They fill the otherwise-empty lower half of the home screen with a living,
/// premium glow — purely decorative, never interactive, and adding no content.
class _AmbientOrbs extends StatefulWidget {
  const _AmbientOrbs();

  @override
  State<_AmbientOrbs> createState() => _AmbientOrbsState();
}

class _AmbientOrbsState extends State<_AmbientOrbs>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = AppColors.landingPrimary;
    const violet = Color(0xFF8B5CF6);
    const blue = Color(0xFF3B82F6);
    final isDark = context.isDark;
    // Keep the glow gentle in light mode so text stays crisp.
    final k = isDark ? 1.0 : 0.55;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_ctrl.value);
          return Stack(
            children: [
              // Large brand orb drifting on the left, mid-screen.
              Positioned(
                left: -70 + t * 24,
                top: 200 + t * 30,
                child: _blurCircle(260, primary.withValues(alpha: 0.16 * k)),
              ),
              // Violet orb, lower-right, drifts the opposite way.
              Positioned(
                right: -80 - t * 20,
                bottom: 120 + t * 40,
                child: _blurCircle(240, violet.withValues(alpha: 0.14 * k)),
              ),
              // Small cool-blue accent orb, upper-right.
              Positioned(
                right: 10 + t * 18,
                top: 150 - t * 20,
                child: _blurCircle(150, blue.withValues(alpha: 0.10 * k)),
              ),
              // Faint deep orb near the bottom to ground the composer area.
              Positioned(
                left: 40 - t * 16,
                bottom: 30 + t * 20,
                child: _blurCircle(200, primary.withValues(alpha: 0.10 * k)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _blurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }
}

// ── Mini orb (inline greeting badge) ──────────────────────────────────────────
/// A small static version of the AI orb used beside the greeting label.
class _MiniOrb extends StatelessWidget {
  const _MiniOrb();

  @override
  Widget build(BuildContext context) {
    const primary = AppColors.landingPrimary;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(primary, Colors.white, 0.25)!, primary],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome_rounded,
        color: Colors.white,
        size: 15,
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
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.easeOut,
  );
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: context.isDark
                    ? context.cCard.withValues(alpha: 0.5)
                    : context.cCard.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accent.withValues(alpha: context.isDark ? 0.3 : 0.4),
                  width: context.isDark ? 1 : 1.5,
                ),
                boxShadow: !context.isDark
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 14,
                    color: accent,
                  ),
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
        ),
      ),
    );
  }
}

// ── Mascot (AI assistant Lottie animation) ───────────────────────────────────
/// A friendly, self-animating AI assistant rendered from a Lottie file, sitting
/// inside a soft breathing glow that ties it to the brand colour.
class _MascotOrb extends StatefulWidget {
  const _MascotOrb();

  @override
  State<_MascotOrb> createState() => _MascotOrbState();
}

class _MascotOrbState extends State<_MascotOrb>
    with SingleTickerProviderStateMixin {
  // Drives only the soft glow halo; the Lottie file animates on its own.
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = AppColors.landingPrimary;
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_glow.value);
        return Container(
          width: 116,
          height: 116,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                primary.withValues(alpha: 0.12 + t * 0.12),
                primary.withValues(alpha: 0.0),
              ],
            ),
          ),
          child: child,
        );
      },
      child: Lottie.asset(
        'assets/animations/ai_assistant.json',
        width: 104,
        height: 104,
        fit: BoxFit.contain,
        // If the asset ever fails to load, fall back to a simple sparkle
        // so the layout never breaks.
        errorBuilder: (context, error, stack) =>
            const Icon(Icons.auto_awesome_rounded, size: 44, color: primary),
      ),
    );
  }
}

// ── Squiggle underline under the headline ────────────────────────────────────
class _SquigglePainter extends CustomPainter {
  const _SquigglePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final waves = 4;
    final segment = size.width / waves;
    path.moveTo(0, size.height / 2);
    for (var i = 0; i < waves; i++) {
      final startX = i * segment;
      final midX = startX + segment / 2;
      final endX = startX + segment;
      final dir = i.isEven ? -1.0 : 1.0;
      path.quadraticBezierTo(
        midX,
        size.height / 2 + dir * (size.height / 2),
        endX,
        size.height / 2,
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SquigglePainter old) => old.color != color;
}
