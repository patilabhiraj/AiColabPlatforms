import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/splash_bloc.dart';
import 'widgets/widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SplashPage
//
// Responsibilities:
//   • Own animation controllers (logo, content, particles)
//   • Compose custom widgets (SplashBackground, SplashParticles,
//     SplashLogo, SplashBottomContent)
//   • Listen to SplashBloc and trigger navigation
// ─────────────────────────────────────────────────────────────────────────────
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  // ── Controllers ─────────────────────────────────────────────────────────────
  late final AnimationController _logoCtrl;
  late final AnimationController _contentCtrl;
  late final AnimationController _particleCtrl;

  // ── Logo animations ──────────────────────────────────────────────────────────
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoGlow;

  // ── Content animations ───────────────────────────────────────────────────────
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _buttonsOpacity;
  late final Animation<Offset> _buttonsSlide;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _buildAnimations();
    _runSequence();
    context.read<SplashBloc>().add(SplashStarted());
  }

  // ── Controller init ──────────────────────────────────────────────────────────
  void _initControllers() {
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  // ── Animation definitions ────────────────────────────────────────────────────
  void _buildAnimations() {
    // Logo
    _logoScale = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _logoGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // Content
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _contentCtrl,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
          ),
        );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentCtrl,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _contentCtrl,
            curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
          ),
        );

    _buttonsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentCtrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
    _buttonsSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _contentCtrl,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
          ),
        );
  }

  // ── Staggered animation sequence ─────────────────────────────────────────────
  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _contentCtrl.forward();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _contentCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  // ── BLoC navigation listener ─────────────────────────────────────────────────
  void _handleState(BuildContext context, SplashState state) {
    if (state is SplashNavigateToHome) {
      context.go(AppRouter.chat);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: _handleState,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1 ── Gradient background
            const SplashBackground(),

            // 2 ── Floating glow orbs
            AnimatedBuilder(
              animation: _particleCtrl,
              builder: (context, child) =>
                  SplashParticles(controller: _particleCtrl),
            ),

            // 3 ── Foreground layout
            SafeArea(
              child: Column(
                children: [
                  // ── Logo (top 55%) ──────────────────────────────────────────
                  Expanded(
                    flex: 55,
                    child: Center(
                      child: SplashLogo(
                        scaleAnimation: _logoScale,
                        opacityAnimation: _logoOpacity,
                        glowAnimation: _logoGlow,
                      ),
                    ),
                  ),

                  // ── Bottom content (45%) ────────────────────────────────────
                  Expanded(
                    flex: 45,
                    child: SplashBottomContent(
                      titleOpacity: _titleOpacity,
                      titleSlide: _titleSlide,
                      taglineOpacity: _taglineOpacity,
                      taglineSlide: _taglineSlide,
                      buttonsOpacity: _buttonsOpacity,
                      buttonsSlide: _buttonsSlide,
                      onCreateAccount: () => context.push(AppRouter.register),
                      onSignIn: () => context.push(AppRouter.login),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


