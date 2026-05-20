import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A full-width gradient primary button used on the splash screen.
/// Uses the ColabPlatforms landing brand gradient (#861043 → #530929)
/// with a matching glow shadow beneath.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 54.0,
    this.borderRadius = 100.0,
  });

  final String label;
  final VoidCallback onPressed;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF861043), // landingPrimary
              Color(0xFF530929), // landingPrimaryHover
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.landingPrimary.withValues(alpha: 0.20),
              blurRadius: 2,
              spreadRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}