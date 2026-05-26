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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
        if (state is AuthError) {
          CustomSnackBar.showError(context, state.message);
        } else if (state is AuthAuthenticated) {
          CustomSnackBar.showSuccess(context, "Account created successfully");
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
                    'Create account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.landingPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Get started with AI Colab Chat',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.landingPrimary,
                          ),
                        )
                      : GradientButton(
                          label: 'Create account',
                          onPressed: () {
                            // Unfocus keyboard
                            FocusScope.of(context).unfocus();

                            // Trigger registration event
                            context.read<AuthBloc>().add(
                              AuthRegisterRequested(
                                firstName: _firstNameCtrl.text.trim(),
                                lastName: _lastNameCtrl.text.trim(),
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
                  const SizedBox(height: 20),

                  // ── Sign in link ──────────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go(AppRouter.login);
                        },
                        child: Text(
                          'Sign in',
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
