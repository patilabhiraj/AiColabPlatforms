import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'login_page.dart';
import 'widgets/widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkForeground),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              // ── Logo ──────────────────────────────────────────────────────────
              const Center(child: AuthLogo()),
              const SizedBox(height: 32),

              // ── Title ─────────────────────────────────────────────────────────
              const Text(
                'Create account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.landingPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Get started with AI Colab Chat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.darkMutedForeground,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              // ── First name + Last name ─────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AuthTextField(
                      label: 'First name',
                      hint: 'Abhiraj',
                      controller: _firstNameCtrl,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AuthTextField(
                      label: 'Last name',
                      hint: 'patil',
                      controller: _lastNameCtrl,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Email ─────────────────────────────────────────────────────────
              AuthTextField(
                label: 'Email',
                hint: 'you@example.com',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // ── Password ──────────────────────────────────────────────────────
              AuthTextField(
                label: 'Password',
                hint: 'Min 6 characters',
                isPassword: true,
                controller: _passwordCtrl,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),

              // ── Create account button ─────────────────────────────────────────
              GradientButton(
                label: 'Create account',
                onPressed: () {
                  // TODO: register with email & password
                },
              ),
              const SizedBox(height: 24),

              // ── OR divider ────────────────────────────────────────────────────
              const OrDivider(),
              const SizedBox(height: 24),

              // ── Google button ─────────────────────────────────────────────────
              GoogleSignInButton(
                onPressed: () {
                  // TODO: sign up with Google
                },
              ),
              const SizedBox(height: 20),

              // ── Sign in link ──────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?',
                    style: TextStyle(
                      color: AppColors.darkMutedForeground,
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        color: AppColors.darkForeground,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
