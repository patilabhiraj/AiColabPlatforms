import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../bloc/chat_bloc.dart';
import '../../domain/entities/assistant.dart';
import '../../domain/entities/chat_conversation.dart';
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
  /// A calm, ChatGPT/Claude-style welcome: a small labelled greeting, a bold
  /// headline, and (when one exists) a "Continue" card to resume the most
  /// recent conversation.
  Widget _buildGreeting(BuildContext context) {
    // First name for the greeting label (falls back to a plain greeting).
    final authState = context.watch<AuthBloc>().state;
    final firstName =
        authState is AuthAuthenticated ? authState.user.firstName.trim() : '';

    // Most recent conversation, if the list has loaded, for the Continue card.
    final chatState = context.watch<ChatBloc>().state;
    final recent = chatState is ChatLoaded && chatState.conversations.isNotEmpty
        ? chatState.conversations.first
        : null;

    final greeting =
        firstName.isNotEmpty ? '${_getGreeting()}, $firstName' : _getGreeting();

    // Recent conversations (top 1 shown, "View all" opens the drawer).
    final recentList = chatState is ChatLoaded ? chatState.conversations : const <ChatConversation>[];

    const categories = [
      _CategorySeed('Brainstorm', Icons.psychology_alt_outlined,
          'Ideas & insights', Color(0xFF8B5CF6)),
      _CategorySeed('Learn', Icons.school_outlined, 'Explain anything',
          Color(0xFF10B981)),
      _CategorySeed('Create', Icons.auto_awesome_rounded, 'Write & design',
          Color(0xFFF59E0B)),
      _CategorySeed('Search', Icons.search_rounded, 'Find anything',
          Color(0xFF3B82F6)),
    ];

    const defaultPrompts = [
      _SuggestionSeed(
        'Give me ideas for a',
        Icons.auto_awesome_rounded,
        'weekend project',
        Color(0xFF8B5CF6),
      ),
      _SuggestionSeed(
        'Explain quantum',
        Icons.description_outlined,
        'computing simply',
        Color(0xFF10B981),
      ),
      _SuggestionSeed(
        'Write a short story',
        Icons.edit_outlined,
        'about space travel',
        Color(0xFFF59E0B),
      ),
      _SuggestionSeed(
        'Help me debug',
        Icons.code_rounded,
        'this code',
        Color(0xFF3B82F6),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 78),
            // ── Small labelled greeting (orb + "Good afternoon, Colab 👋") ────
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
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('👋', style: TextStyle(fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Headline + mascot ──────────────────────────────────────────────
            _FadeInSlide(
              delay: 300,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: context.cFg,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                              letterSpacing: -0.8,
                            ),
                            children: [
                              const TextSpan(text: 'What should\nwe figure out\n'),
                              TextSpan(
                                text: 'together?',
                                style: const TextStyle(
                                  color: AppColors.landingPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 0,
                          bottom: -10,
                          child: CustomPaint(
                            size: const Size(88, 10),
                            painter: _SquigglePainter(
                              color: AppColors.landingPrimary
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const _MascotOrb(),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Category pills row ───────────────────────────────────────────
            _FadeInSlide(
              delay: 380,
              child: SizedBox(
                height: 68,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, i) => _CategoryPill(
                    seed: categories[i],
                    onTap: () => onSuggestion(categories[i].label),
                  ),
                ),
              ),
            ),

            // ── Recent conversations ─────────────────────────────────────────
            if (recent != null) ...[
              const SizedBox(height: 24),
              _FadeInSlide(
                delay: 440,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? context.cCard.withValues(alpha: 0.35)
                        : context.cCard.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: context.cBorder.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent conversations',
                            style: TextStyle(
                              color: context.cFg,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (recentList.length > 1)
                            GestureDetector(
                              onTap: () => Scaffold.of(context).openDrawer(),
                              child: const Text(
                                'View all',
                                style: TextStyle(
                                  color: AppColors.landingPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _ContinueCard(
                        conversation: recent,
                        onTap: () => context
                            .read<ChatBloc>()
                            .add(ChatSelectConversation(recent)),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // ── Suggestion cards to fill the space & invite a first message ──
            const SizedBox(height: 28),
            _FadeInSlide(
              delay: 500,
              child: Text(
                'Try asking something',
                style: TextStyle(
                  color: context.cFg.withValues(alpha: 0.85),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _FadeInSlide(
              delay: 550,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 10.0;
                  final cardWidth = (constraints.maxWidth - gap) / 2;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final seed in defaultPrompts)
                        SizedBox(
                          width: cardWidth,
                          child: _SuggestionCard(
                            seed: seed,
                            onTap: () =>
                                onSuggestion('${seed.title} ${seed.subtitle}'),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
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
          colors: [
            Color.lerp(primary, Colors.white, 0.25)!,
            primary,
          ],
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

// ── Continue card (resume most recent chat) ───────────────────────────────────
class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.conversation, required this.onTap});

  final ChatConversation conversation;
  final VoidCallback onTap;

  /// Short "2m ago" / "3h ago" / "5d ago" style relative time.
  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.landingPrimary;
    final isDark = context.isDark;
    final title = conversation.title.trim().isNotEmpty
        ? conversation.title.trim()
        : 'Untitled chat';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Ink(
              decoration: BoxDecoration(
                color: isDark
                    ? context.cCard.withValues(alpha: 0.45)
                    : context.cCard.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: context.cBorder.withValues(alpha: isDark ? 0.5 : 0.7),
                  width: isDark ? 1 : 1.5,
                ),
                boxShadow: !isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Small "in progress" dot
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Continue — $title',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.cFg,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _relativeTime(conversation.updatedAt),
                        style: TextStyle(
                          color: context.cMuted.withValues(alpha: 0.7),
                          fontSize: 12.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: context.cMuted.withValues(alpha: 0.55),
                ),
              ],
            ),
          ),
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
        ),
      ),
    );
  }
}

// ── Default suggestion seed data ──────────────────────────────────────────────
class _SuggestionSeed {
  const _SuggestionSeed(this.title, this.icon, this.subtitle, this.color);
  final String title;
  final IconData icon;
  final String subtitle;
  final Color color;
}

// ── Category seed data (Brainstorm / Learn / Create / Search) ────────────────
class _CategorySeed {
  const _CategorySeed(this.label, this.icon, this.subtitle, this.color);
  final String label;
  final IconData icon;
  final String subtitle;
  final Color color;
}

// ── Default suggestion card (2-column grid, matches reference) ───────────────
class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.seed, required this.onTap});

  final _SuggestionSeed seed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                seed.color.withValues(alpha: isDark ? 0.16 : 0.10),
                seed.color.withValues(alpha: isDark ? 0.06 : 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: seed.color.withValues(alpha: isDark ? 0.28 : 0.20),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: seed.color.withValues(alpha: isDark ? 0.22 : 0.15),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(seed.icon, size: 20, color: seed.color),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${seed.title}\n${seed.subtitle}',
                      maxLines: 2,
                      style: TextStyle(
                        color: context.cFg,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: context.cMuted.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Category pill (horizontal scroller under the headline) ───────────────────
class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.seed, required this.onTap});

  final _CategorySeed seed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? context.cCard.withValues(alpha: 0.4)
                : context.cCard.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.cBorder.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: seed.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(seed.icon, size: 18, color: seed.color),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seed.label,
                    style: TextStyle(
                      color: context.cFg,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    seed.subtitle,
                    style: TextStyle(
                      color: context.cMuted.withValues(alpha: 0.75),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
            ],
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
        errorBuilder: (context, error, stack) => const Icon(
          Icons.auto_awesome_rounded,
          size: 44,
          color: primary,
        ),
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


