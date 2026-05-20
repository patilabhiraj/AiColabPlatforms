import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/router.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/forgot_password_bloc.dart';
import 'widgets/widgets.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _step = 0;
  String _email = '';
  String _otp = '';

  static const _titles = [
    'Add your email  1 / 3',
    'Verify your email  2 / 3',
    'Create your password  3 / 3',
    '',
  ];

  void _next() => setState(() => _step++);

  void _back() {
    if (_step == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() => _step--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordOtpSent) {
          _next(); // email → OTP step
        } else if (state is ForgotPasswordSuccess) {
          setState(() => _step = 3); // jump to success
        } else if (state is ForgotPasswordError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.landingPrimary,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ForgotPasswordLoading;

        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          appBar: _step < 3
              ? AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: isLoading
                      ? null
                      : IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: AppColors.darkForeground,
                          ),
                          onPressed: _back,
                        ),
                  title: Text(
                    _titles[_step],
                    style: const TextStyle(
                      color: AppColors.darkForeground,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  centerTitle: false,
                )
              : null,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_step < 3) ...[
                  const SizedBox(height: 6),
                  StepProgressIndicator(totalSteps: 3, currentStep: _step),
                  const SizedBox(height: 4),
                ],
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.06, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: anim,
                                curve: Curves.easeOut,
                              ),
                            ),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(_step),
                      child: [
                        _EmailStep(
                          isLoading: isLoading,
                          onNext: (email) {
                            _email = email;
                            context.read<ForgotPasswordBloc>().add(
                              FPSendOtpRequested(email),
                            );
                          },
                        ),
                        _OtpStep(
                          email: _email,
                          isLoading: isLoading,
                          onNext: (otp) {
                            _otp = otp;
                            _next(); // OTP → password step (no API call)
                          },
                          onChangeEmail: _back,
                        ),
                        _NewPasswordStep(
                          isLoading: isLoading,
                          onNext: (password) {
                            context.read<ForgotPasswordBloc>().add(
                              FPResetPasswordRequested(
                                email: _email,
                                otp: _otp,
                                newPassword: password,
                              ),
                            );
                          },
                        ),
                        _SuccessStep(
                          onSignIn: () => context.go(AppRouter.login),
                        ),
                      ][_step],
                    ),
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

// ── Step 1 — Email ────────────────────────────────────────────────────────────
class _EmailStep extends StatefulWidget {
  const _EmailStep({required this.isLoading, required this.onNext});
  final bool isLoading;
  final ValueChanged<String> onNext;

  @override
  State<_EmailStep> createState() => _EmailStepState();
}

class _EmailStepState extends State<_EmailStep> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          AuthTextField(
            label: 'Email',
            hint: 'you@example.com',
            controller: _ctrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 24),
          widget.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.landingPrimary,
                  ),
                )
              : GradientButton(
                  label: 'Send Code',
                  onPressed: () =>
                      widget.onNext(_ctrl.text.trim().toLowerCase()),
                ),
          const SizedBox(height: 24),
          const _TermsText(),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ── Step 2 — OTP ──────────────────────────────────────────────────────────────
class _OtpStep extends StatefulWidget {
  const _OtpStep({
    required this.email,
    required this.isLoading,
    required this.onNext,
    required this.onChangeEmail,
  });
  final String email;
  final bool isLoading;
  final ValueChanged<String> onNext;
  final VoidCallback onChangeEmail;

  @override
  State<_OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<_OtpStep> {
  String _otp = '';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            'We just sent a 6-digit code to\n${widget.email.isEmpty ? 'your email' : widget.email},\nenter it below:',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.darkMutedForeground,
              fontSize: 14,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Code',
            style: TextStyle(
              color: AppColors.darkForeground,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          OtpInputField(
            length: 6,
            onChanged: (val) => setState(() => _otp = val),
            onCompleted: (val) => setState(() => _otp = val),
          ),
          const SizedBox(height: 24),
          widget.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.landingPrimary,
                  ),
                )
              : GradientButton(
                  label: 'Verify Email',
                  onPressed: () => widget.onNext(_otp),
                ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: widget.onChangeEmail,
              child: RichText(
                text: const TextSpan(
                  text: 'Wrong email?  ',
                  style: TextStyle(
                    color: AppColors.darkMutedForeground,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: 'Send to different email',
                      style: TextStyle(
                        color: AppColors.darkForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const _TermsText(),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ── Step 3 — New password ─────────────────────────────────────────────────────
class _NewPasswordStep extends StatefulWidget {
  const _NewPasswordStep({required this.isLoading, required this.onNext});
  final bool isLoading;
  final ValueChanged<String> onNext;

  @override
  State<_NewPasswordStep> createState() => _NewPasswordStepState();
}

class _NewPasswordStepState extends State<_NewPasswordStep> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          AuthTextField(
            label: 'New Password',
            hint: 'Enter new password',
            isPassword: true,
            controller: _ctrl,
            textInputAction: TextInputAction.done,
          ),
          PasswordStrengthIndicator(password: _ctrl.text),
          const SizedBox(height: 28),
          widget.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.landingPrimary,
                  ),
                )
              : GradientButton(
                  label: 'Reset Password',
                  onPressed: () => widget.onNext(_ctrl.text),
                ),
          const SizedBox(height: 40),
          const _TermsText(),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ── Step 4 — Success ──────────────────────────────────────────────────────────
class _SuccessStep extends StatelessWidget {
  const _SuccessStep({required this.onSignIn});
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.landingPrimary.withValues(alpha: 0.15),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.landingPrimary,
              size: 42,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Password reset\nsuccessfully!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.darkForeground,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your password has been updated.\nSign in with your new password to continue.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.darkMutedForeground,
              fontSize: 14,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 40),
          GradientButton(label: 'Sign In', onPressed: onSignIn),
        ],
      ),
    );
  }
}

// ── Shared footer ─────────────────────────────────────────────────────────────
class _TermsText extends StatelessWidget {
  const _TermsText();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          text: 'By using ColabPlatforms AI, you agree to the\n',
          style: TextStyle(
            color: AppColors.darkMutedForeground,
            fontSize: 12,
            height: 1.5,
          ),
          children: [
            TextSpan(
              text: 'Terms',
              style: TextStyle(
                color: AppColors.darkForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(
                color: AppColors.darkForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}
