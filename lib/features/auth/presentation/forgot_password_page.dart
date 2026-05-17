import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'login_page.dart';
import 'widgets/widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ForgotPasswordPage — 3-step flow: email → OTP → new password → success
// ─────────────────────────────────────────────────────────────────────────────
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _step = 0;
  String _email = '';

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
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      // Hide AppBar on success screen
      appBar: _step < 3
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
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
            // ── Step progress pills ──────────────────────────────────────────
            if (_step < 3) ...[
              const SizedBox(height: 6),
              StepProgressIndicator(totalSteps: 3, currentStep: _step),
              const SizedBox(height: 4),
            ],

            // ── Animated step content ────────────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.06, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: anim,
                      curve: Curves.easeOut,
                    )),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: [
                    _EmailStep(onNext: (email) {
                      _email = email;
                      _next();
                    }),
                    _OtpStep(
                      email: _email,
                      onNext: _next,
                      onChangeEmail: _back,
                    ),
                    _NewPasswordStep(onNext: _next),
                    _SuccessStep(
                      onSignIn: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      ),
                    ),
                  ][_step],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 — Enter email
// ─────────────────────────────────────────────────────────────────────────────
class _EmailStep extends StatefulWidget {
  const _EmailStep({required this.onNext});
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AuthTextField(
            label: 'Email',
            hint: 'you@example.com',
            controller: _ctrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
          ),
        ),

        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GradientButton(
            label: 'Send Code',
            onPressed: () => widget.onNext(_ctrl.text.trim()),
          ),
        ),

        const Spacer(),
        const _TermsText(),
        const SizedBox(height: 28),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 — Verify OTP
// ─────────────────────────────────────────────────────────────────────────────
class _OtpStep extends StatefulWidget {
  const _OtpStep({
    required this.email,
    required this.onNext,
    required this.onChangeEmail,
  });

  final String email;
  final VoidCallback onNext;
  final VoidCallback onChangeEmail;

  @override
  State<_OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<_OtpStep> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),

        // Description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'We just sent a 5-digit code to\n${widget.email.isEmpty ? 'your email' : widget.email},\nenter it below:',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.darkMutedForeground,
              fontSize: 14,
              height: 1.55,
            ),
          ),
        ),

        const SizedBox(height: 28),

        // "Code" label
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Code',
            style: TextStyle(
              color: AppColors.darkForeground,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // OTP boxes
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: OtpInputField(
            length: 5,
            onChanged: (_) {},
            onCompleted: (_) {},
          ),
        ),

        const SizedBox(height: 24),

        // Verify button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GradientButton(
            label: 'Verify Email',
            onPressed: widget.onNext,
          ),
        ),

        const SizedBox(height: 16),

        // Wrong email link
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

        const Spacer(),
        const _TermsText(),
        const SizedBox(height: 28),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3 — Create new password
// ─────────────────────────────────────────────────────────────────────────────
class _NewPasswordStep extends StatefulWidget {
  const _NewPasswordStep({required this.onNext});
  final VoidCallback onNext;

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
            label: 'Password',
            hint: 'Enter new password',
            isPassword: true,
            controller: _ctrl,
            textInputAction: TextInputAction.done,
          ),

          PasswordStrengthIndicator(password: _ctrl.text),

          const SizedBox(height: 28),

          GradientButton(
            label: 'Reset Password',
            onPressed: widget.onNext,
          ),

          const SizedBox(height: 40),
          const _TermsText(),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 4 — Success
// ─────────────────────────────────────────────────────────────────────────────
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
          // ── Checkmark icon ─────────────────────────────────────────────────
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

          // ── Title ──────────────────────────────────────────────────────────
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

          // ── Sign in button ─────────────────────────────────────────────────
          GradientButton(label: 'Sign In', onPressed: onSignIn),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared — Terms & Privacy footer
// ─────────────────────────────────────────────────────────────────────────────
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
