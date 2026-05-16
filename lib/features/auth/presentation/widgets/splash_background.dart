import 'package:flutter/material.dart';

/// Full-screen background gradient for the splash screen.
/// Uses the ColabPlatforms dark + landing primary color blend.
class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F0F13), // darkBackground
            Color(0xFF1A0A12), // dark + landing primary tint
            Color(0xFF200C18), // mid blend
            Color(0xFF0F0F13), // darkBackground
          ],
          stops: [0.0, 0.35, 0.65, 1.0],
        ),
      ),
    );
  }
}
