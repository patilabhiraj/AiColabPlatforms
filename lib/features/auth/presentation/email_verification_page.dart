import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../../../app/routes/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../app/injection.dart';
import '../domain/usecases/verify_email_otp_usecase.dart';
import '../domain/usecases/resend_email_otp_usecase.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;

  /// The password entered during register/login. When present, the page
  /// auto-logs the user in after a successful OTP verification so they land
  /// on home directly instead of the login screen. Empty when the page was
  /// reached without credentials (e.g. deep link) — then we fall back to login.
  final String password;

  const EmailVerificationPage({
    super.key,
    required this.email,
    this.password = '',
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    if (_otpCode.length != 6) {
      CustomSnackBar.showError(context, 'Please enter complete OTP');
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final verifyUseCase = sl<VerifyEmailOtpUseCase>();
      final result = await verifyUseCase(widget.email, _otpCode);

      result.fold(
        (failure) {
          if (mounted) {
            CustomSnackBar.showError(context, failure.message);
          }
        },
        (loggedIn) async {
          logger.info('✅ Email verified successfully (loggedIn: $loggedIn)');
          if (!mounted) return;

          if (loggedIn) {
            // Backend auto-logged the user in on verification. Refresh the auth
            // state from the freshly saved token and go straight to home.
            CustomSnackBar.showSuccess(context, 'Email verified! Welcome 🎉');
            context.read<AuthBloc>().add(AuthCheckRequested());
            context.go(AppRouter.chat);
          } else if (widget.password.isNotEmpty) {
            // Backend confirmed the OTP but didn't issue a session. We still
            // have the password from registration, so log the user in silently
            // and let AuthBloc drive navigation to home — no re-typing needed.
            CustomSnackBar.showSuccess(context, 'Email verified! Welcome 🎉');
            context.read<AuthBloc>().add(
              AuthLoginRequested(
                email: widget.email,
                password: widget.password,
              ),
            );
          } else {
            // No session and no cached password (e.g. deep-linked here) — the
            // user must log in manually.
            CustomSnackBar.showSuccess(context, 'Email verified! Please login.');
            context.go(AppRouter.login);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Failed to verify OTP');
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isResending = true);

    try {
      final resendUseCase = sl<ResendEmailOtpUseCase>();
      final result = await resendUseCase(widget.email);

      result.fold(
        (failure) {
          if (mounted) {
            CustomSnackBar.showError(context, failure.message);
          }
        },
        (_) {
          if (mounted) {
            CustomSnackBar.showSuccess(context, 'OTP sent to ${widget.email}');
          }
        },
      );
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Failed to resend OTP');
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      // React to the silent auto-login fired after OTP verification.
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRouter.chat);
        } else if (state is AuthError) {
          // Verified but auto-login failed — send the user to login to retry
          // manually rather than leaving them stuck on this page.
          CustomSnackBar.showError(context, state.message);
          context.go(AppRouter.login);
        }
      },
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.cFg),
          onPressed: () => context.go(AppRouter.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.landingPrimary.withValues(alpha: 0.3),
                      AppColors.landingPrimary.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.email_outlined,
                  size: 40,
                  color: AppColors.landingPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Verify Your Email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.landingPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'We sent a verification code to\n${widget.email}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.cMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),

              // OTP Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        color: context.cFg,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: context.cCard,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.cBorder.withValues(alpha: context.isDark ? 0.3 : 0.7),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.cBorder.withValues(alpha: context.isDark ? 0.3 : 0.7),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.landingPrimary,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        
                        // Auto-verify when all 6 digits are entered
                        if (index == 5 && value.isNotEmpty) {
                          _verifyOtp();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Verify Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.landingPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Verify Email',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive code? ",
                    style: TextStyle(
                      color: context.cMuted,
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: _isResending ? null : _resendOtp,
                    child: _isResending
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.landingPrimary,
                            ),
                          )
                        : const Text(
                            'Resend',
                            style: TextStyle(
                              color: AppColors.landingPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
