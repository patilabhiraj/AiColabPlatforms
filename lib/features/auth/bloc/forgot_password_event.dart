part of 'forgot_password_bloc.dart';

abstract class ForgotPasswordEvent {}

class FPSendOtpRequested extends ForgotPasswordEvent {
  final String email;
  FPSendOtpRequested(this.email);
}

class FPResetPasswordRequested extends ForgotPasswordEvent {
  final String email;
  final String otp;
  final String newPassword;

  FPResetPasswordRequested({
    required this.email,
    required this.otp,
    required this.newPassword,
  });
}
