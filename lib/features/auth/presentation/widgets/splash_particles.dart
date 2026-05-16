import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'glow_orb.dart';

/// Animated floating orb layer for the splash screen.
/// Requires a looping [AnimationController] passed from the parent.
class SplashParticles extends StatelessWidget {
  const SplashParticles({
    super.key,
    required this.controller,
  });

  /// Looping animation controller (0.0 → 1.0 → repeat)
  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final t = controller.value;

    return Stack(
      children: [
        // ── Top-right orb ── landing primary (rose/crimson) ──────────────────
        Positioned(
          top: size.height * 0.08 + math.sin(t * 2 * math.pi) * 20,
          right: size.width * 0.05 + math.cos(t * 2 * math.pi) * 15,
          child: GlowOrb(
            radius: 130,
            color: AppColors.landingPrimary.withValues(alpha: 0.18),
          ),
        ),

        // ── Bottom-left orb ── sidebar primary (indigo) ──────────────────────
        Positioned(
          bottom: size.height * 0.15 + math.cos(t * 2 * math.pi) * 18,
          left: -size.width * 0.1 + math.sin(t * 2 * math.pi) * 12,
          child: GlowOrb(
            radius: 160,
            color: AppColors.darkSidebarPrimary.withValues(alpha: 0.12),
          ),
        ),

        // ── Centre hint orb ── landing primary hover (deep rose) ─────────────
        Positioned(
          top: size.height * 0.3,
          left: size.width * 0.2,
          child: GlowOrb(
            radius: 80,
            color: AppColors.landingPrimaryHover.withValues(alpha: 0.10),
          ),
        ),
      ],
    );
  }
}
