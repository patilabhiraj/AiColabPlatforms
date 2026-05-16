import 'package:flutter/material.dart';

import 'gradient_button.dart';

/// Bottom content section of the splash screen.
///
/// Contains the animated heading, tagline, and CTA buttons.
/// All animations are passed in from the parent [State] — this widget
/// is purely presentational with no animation controller ownership.
class SplashBottomContent extends StatelessWidget {
  const SplashBottomContent({
    super.key,
    required this.titleOpacity,
    required this.titleSlide,
    required this.taglineOpacity,
    required this.taglineSlide,
    required this.buttonsOpacity,
    required this.buttonsSlide,
    required this.onCreateAccount,
    required this.onSignIn,
  });

  // ── Animations ──────────────────────────────────────────────────────────────
  final Animation<double> titleOpacity;
  final Animation<Offset> titleSlide;
  final Animation<double> taglineOpacity;
  final Animation<Offset> taglineSlide;
  final Animation<double> buttonsOpacity;
  final Animation<Offset> buttonsSlide;

  // ── Callbacks ───────────────────────────────────────────────────────────────
  final VoidCallback onCreateAccount;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 29),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Welcome heading ─────────────────────────────────────────────────
          SlideTransition(
            position: titleSlide,
            child: FadeTransition(
              opacity: titleOpacity,
              child: const Text(
                'Welcome to\nColabPlatforms AI',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFAFAFA), // darkForeground
                  height: 1.25,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Tagline ─────────────────────────────────────────────────────────
          SlideTransition(
            position: taglineSlide,
            child: FadeTransition(
              opacity: taglineOpacity,
              child: const Text(
                'Chat with 15+ AI models in one place.\nGPT-4, Claude, Gemini & more.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9393A5), // darkMutedForeground
                  height: 1.55,
                ),
              ),
            ),
          ),

          const SizedBox(height: 36),

          // ── CTA Buttons ─────────────────────────────────────────────────────
          SlideTransition(
            position: buttonsSlide,
            child: FadeTransition(
              opacity: buttonsOpacity,
              child: Column(
                children: [
                  // Primary — Create account
                  GradientButton(
                    label: 'Get Started',
                    onPressed: onCreateAccount,
                  ),

                  const SizedBox(height: 10),

                  // Secondary — Sign In
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 54,
                  //   child: OutlinedButton(
                  //     onPressed: onSignIn,
                  //     style: OutlinedButton.styleFrom(
                  //       side: const BorderSide(
                  //         color: Color(0x33FFFFFF), // white 20%
                  //       ),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(14),
                  //       ),
                  //     ),
                  //     child: const Text(
                  //       'Already have an account?  Sign In',
                  //       style: TextStyle(
                  //         fontSize: 15,
                  //         fontWeight: FontWeight.w500,
                  //         color: Color(0xFFD4D4D8),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
