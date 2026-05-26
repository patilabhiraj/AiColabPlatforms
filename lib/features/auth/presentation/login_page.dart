import 'package:colabplatforms_ai/core/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../../../app/routes/router.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            CustomSnackBar.showError(context, state.message);
          } else if (state is AuthAuthenticated) {
            // CustomSnackBar.showSuccess(context, "Signed in successfully");
            context.go(AppRouter.chat);
          } else if (state is AuthEmailVerificationRequired) {
            CustomSnackBar.showInfo(
              context,
              'Please verify your email. OTP sent to ${state.email}',
            );
            context.go('${AppRouter.emailVerification}?email=${Uri.encodeComponent(state.email)}');
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
                  Text(
                    'Sign in to AI Colab Chat',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                          url:
                              '${ApiConstants.baseUrl}${ApiConstants.googleStart}',
                          callbackUrlScheme: 'colabplatforms',
                        );
                        final token = Uri.parse(
                          result,
                        ).queryParameters['token'];
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
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // ── Sign up link ──────────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go(AppRouter.register);
                        },
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
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
