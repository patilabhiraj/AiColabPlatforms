import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Premium Empty State with Interactive Elements
/// Features:
/// - Animated gradient background
/// - Pulsing logo with rotating particles
/// - Time-based greeting
/// - Fade-in animations
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
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.8,
          colors: [
            AppColors.landingPrimary.withValues(alpha: 0.12),
            AppColors.landingPrimary.withValues(alpha: 0.05),
            AppColors.darkBackground.withValues(alpha: 0.0),
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

              // ── Greeting ─────────────────────────────────────────────────
              _FadeInText(
                text: '${_getGreeting()}!',
                delay: 200,
                style: const TextStyle(
                  color: AppColors.darkForeground,
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
                  color: AppColors.darkMutedForeground.withValues(alpha: 0.85),
                  fontSize: 17,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 60),
              
              // ── Feature Pills ────────────────────────────────────────────
              _FadeInText(
                text: 'Powered by advanced AI models',
                delay: 600,
                style: TextStyle(
                  color: AppColors.darkMutedForeground.withValues(alpha: 0.6),
                  fontSize: 13,
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
