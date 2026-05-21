import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

/// Advanced Empty State with AI Fiesta style
/// Features:
/// - Animated gradient background
/// - Prompt suggestions with icons
/// - Smooth hover effects
/// - Better visual hierarchy
class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({super.key, required this.onSuggestion});
  final ValueChanged<String> onSuggestion;

  // static const _suggestions = [
  //   (
  //     Icons.lightbulb_outline_rounded,
  //     'Brainstorm ideas for...',
  //     'Creative suggestions and plans',
  //     'Help me brainstorm ideas for a mobile app'
  //   ),
  //   (
  //     Icons.edit_note_rounded,
  //     'Help me write a...',
  //     'Essays, emails, or stories',
  //     'Help me write a professional email'
  //   ),
  //   (
  //     Icons.code_rounded,
  //     'Explain how...',
  //     'Technical concepts simplified',
  //     'Explain how async/await works in Dart'
  //   ),
  //   (
  //     Icons.quiz_outlined,
  //     'Solve this problem...',
  //     'Math, logic, or debugging',
  //     'Help me debug this Flutter error'
  //   ),
  // ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.5,
          colors: [
            AppColors.landingPrimary.withValues(alpha: 0.08),
            AppColors.darkBackground.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Animated Logo ────────────────────────────────────────────
              _AnimatedLogo(),
              const SizedBox(height: 24),

              // ── Title ────────────────────────────────────────────────────
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    AppColors.darkForeground,
                    AppColors.darkMutedForeground,
                  ],
                ).createShader(bounds),
                child: const Text(
                  'AI Colab Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                'How can I help you today?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.darkMutedForeground.withValues(alpha: 0.85),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // // ── Horizontal Scrollable Suggestion Cards ──────────────────
              // SizedBox(
              //   height: 180,
              //   child: ListView.builder(
              //     scrollDirection: Axis.horizontal,
              //     padding: const EdgeInsets.symmetric(horizontal: 4),
              //     itemCount: _suggestions.length,
              //     itemBuilder: (context, index) {
              //       final suggestion = _suggestions[index];
              //       return Padding(
              //         padding: EdgeInsets.only(
              //           left: index == 0 ? 0 : 8,
              //           right: index == _suggestions.length - 1 ? 0 : 8,
              //         ),
              //         child: _SuggestionCard(
              //           icon: suggestion.$1,
              //           title: suggestion.$2,
              //           subtitle: suggestion.$3,
              //           prompt: suggestion.$4,
              //           onTap: () => onSuggestion(suggestion.$4),
              //         ),
              //       );
              //     },
              //   ),
              // ),
            
            ],
          ),
        ),
      ),
    );
  }
}

// ── Animated Logo ─────────────────────────────────────────────────────────────
class _AnimatedLogo extends StatefulWidget {
  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulseAnim,
      child: Container(
        width: 810,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.landingPrimary.withValues(alpha: 0.2),
              AppColors.landingPrimary.withValues(alpha: 0.1),
            ],
          ),
          // border: Border.all(
          //   color: AppColors.landingPrimary.withValues(alpha: 0.4),
          //   width: 2,
          // ),
          // boxShadow: [
          //   BoxShadow(
          //     color: AppColors.landingPrimary.withValues(alpha: 0.2),
          //     blurRadius: 24,
          //     spreadRadius: 4,
          //   ),
          // ],
        ),
        child: const Icon(
          Icons.auto_awesome_rounded,
          color: AppColors.landingPrimary,
          size: 38,
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatefulWidget {
  const _SuggestionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.prompt,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String prompt;
  final VoidCallback onTap;

  @override
  State<_SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends State<_SuggestionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 200,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -4.0 : 0.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: AppRadius.borderXl,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.darkCard.withValues(alpha: 0.5),
                borderRadius: AppRadius.borderXl,
                border: Border.all(
                  color: _isHovered
                      ? AppColors.landingPrimary.withValues(alpha: 0.4)
                      : AppColors.darkBorder.withValues(alpha: 0.3),
                  width: _isHovered ? 1.5 : 1.0,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: AppColors.landingPrimary.withValues(alpha: 0.1),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.landingPrimary.withValues(alpha: 0.15),
                          AppColors.landingPrimary.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: AppRadius.borderMd,
                    ),
                    child: Icon(
                      widget.icon,
                      color: AppColors.landingPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: AppColors.darkForeground,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.darkMutedForeground.withValues(alpha: 0.8),
                      fontSize: 12,
                      height: 1.4,
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
