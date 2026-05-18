import 'package:colabplatforms_ai/features/auth/presentation/widgets/auth_logo.dart';
import 'package:flutter/material.dart';



/// Animated brand logo for the splash screen.
///
/// Accepts pre-built animation objects from the parent [State] so this widget
/// stays purely presentational and has zero animation controller ownership.
class SplashLogo extends StatelessWidget {
  const SplashLogo({
    super.key,
    required this.scaleAnimation,
    required this.opacityAnimation,
    required this.glowAnimation,
  });

  /// Scale: 0.3 → 1.0 (elasticOut)
  final Animation<double> scaleAnimation;

  /// Opacity: 0.0 → 1.0
  final Animation<double> opacityAnimation;

  /// Glow intensity: 0.0 → 1.0 (drives box-shadow opacity)
  final Animation<double> glowAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        scaleAnimation,
        opacityAnimation,
        glowAnimation,
      ]),
      builder: (context, child) {
        return Opacity(
          opacity: opacityAnimation.value,
          child: Transform.scale(
            scale: scaleAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Icon container with gradient + glow ──────────────────────
                // Container(
                //   width: 120,
                //   height: 120,
                //   // decoration: BoxDecoration(
                //   //   shape: BoxShape.circle,
                //   //   boxShadow: [
                //   //     BoxShadow(
                //   //       color: AppColors.landingPrimary
                //   //           .withValues(alpha: 0.45 * glowAnimation.value),
                //   //       blurRadius: 50,
                //   //       spreadRadius: 12,
                //   //     ),
                //   //     BoxShadow(
                //   //       color: AppColors.darkSidebarPrimary
                //   //           .withValues(alpha: 0.30 * glowAnimation.value),
                //   //       blurRadius: 30,
                //   //       spreadRadius: 6,
                //   //     ),
                //   //   ],
                //   //   gradient: const LinearGradient(
                //   //     begin: Alignment.topLeft,
                //   //     end: Alignment.bottomRight,
                //   //     colors: [
                //   //       Color(0xFF861043), // landingPrimary
                //   //       Color(0xFF530929), // landingPrimaryHover
                //   //       Color(0xFF3B1F5E), // deep purple accent
                //   //     ],
                //   //   ),
                //   // ),
                //   child: const Icon(
                //     Icons.auto_awesome,
                //     color: Colors.white,
                //     size: 54,
                //   ),
                // ),
                 AuthLogo(),
                const SizedBox(height: 20),

                // ── App name with gradient shader ────────────────────────────
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFD4A0B8), // soft pink tint
                      Color(0xFFAD88C6), // lavender
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    'ColabPlatforms',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white, // overridden by shader
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // ── "AI" sub-label ───────────────────────────────────────────
                const Text(
                  'AI',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9393A5), // darkMutedForeground
                    letterSpacing: 6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
