import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/usecases/forgot_password_usecase.dart';
import '../domain/usecases/reset_password_usecase.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final ForgotPasswordUseCase _forgotPassword;
  final ResetPasswordUseCase _resetPassword;

  ForgotPasswordBloc(this._forgotPassword, this._resetPassword)
      : super(ForgotPasswordInitial()) {
    on<FPSendOtpRequested>(_onSendOtp);
    on<FPResetPasswordRequested>(_onResetPassword);
  }

  Future<void> _onSendOtp(
    FPSendOtpRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordLoading());
    final result = await _forgotPassword(event.email);
    result.fold(
      (failure) => emit(ForgotPasswordError(failure.message)),
      (_) => emit(ForgotPasswordOtpSent()),
    );
  }

  Future<void> _onResetPassword(
    FPResetPasswordRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordLoading());
    final result = await _resetPassword(
      email: event.email,
      otp: event.otp,
      newPassword: event.newPassword,
    );
    result.fold(
      (failure) => emit(ForgotPasswordError(failure.message)),
      (_) => emit(ForgotPasswordSuccess()),
    );
  }
}
