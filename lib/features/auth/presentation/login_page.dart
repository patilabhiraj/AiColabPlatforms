import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../bloc/auth_bloc.dart';
import 'widgets/widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
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
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.landingPrimary,
              ),
            );
          } else if (state is AuthAuthenticated) {
            context.go(AppRouter.chat);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
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
                'Welcome back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.landingPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign in to AI Colab Chat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.darkMutedForeground,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

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
                hint: '••••••••',
                isPassword: true,
                controller: _passwordCtrl,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),

              // ── Sign in button ────────────────────────────────────────────────
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.landingPrimary,
                      ),
                    )
                  : GradientButton(
                      label: 'Sign in',
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        context.read<AuthBloc>().add(
                              AuthLoginRequested(
                                email: _emailCtrl.text.trim().toLowerCase(),
                                password: _passwordCtrl.text,
                              ),
                            );
                      },
                    ),
              const SizedBox(height: 24),

              // ── OR divider ────────────────────────────────────────────────────
              const OrDivider(),
              const SizedBox(height: 24),

              // ── Google button ─────────────────────────────────────────────────
              GoogleSignInButton(
                onPressed: () async {
                  try {
                    final result = await FlutterWebAuth2.authenticate(
                      url: '${ApiConstants.baseUrl}${ApiConstants.googleStart}',
                      callbackUrlScheme: 'colabplatforms',
                    );
                    final token = Uri.parse(result).queryParameters['token'];
                    if (token != null && context.mounted) {
                      context.read<AuthBloc>().add(
                        AuthGoogleSignInRequested(token: token),
                      );
                    }
                  } catch (_) {
                    // user cancelled
                  }
                },
              ),
              const SizedBox(height: 8),

              // ── Forgot password ───────────────────────────────────────────────
              TextButton(
                onPressed: () {
                  context.push(AppRouter.forgotPassword);
                },
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    color: AppColors.darkForeground,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // ── Sign up link ──────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(
                      color: AppColors.darkMutedForeground,
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.go(AppRouter.register);
                    },
                    child: const Text(
                      'Sign up',
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
      );
    },
      ),
    );
  }
}
