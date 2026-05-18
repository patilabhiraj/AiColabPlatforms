import 'dart:convert';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String firstName, String lastName, String email, String password);
  Future<UserModel> googleLogin(String token);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String email, String otp, String newPassword);
  Future<void> verifyEmailOtp(String email, String otp);
  Future<void> resendEmailOtp(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await apiClient.dio.post(
      ApiConstants.login,
      data: {"email": email, "password": password},
    );
    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel> register(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    final response = await apiClient.dio.post(
      ApiConstants.register,
      data: {
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "password": password,
      },
    );
    return UserModel.fromJson(response.data);
  }

  // Google OAuth is server-side: the WebView returns a JWT from the backend's
  // /auth/google/callback redirect. We decode it locally to build UserModel.
  @override
  Future<UserModel> googleLogin(String token) async {
    return _userFromJwt(token);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await apiClient.dio.post(
      ApiConstants.forgotPassword,
      data: {"email": email},
    );
  }

  @override
  Future<void> resetPassword(String email, String otp, String newPassword) async {
    await apiClient.dio.post(
      ApiConstants.resetPassword,
      data: {"email": email, "otp": otp, "newPassword": newPassword},
    );
  }

  @override
  Future<void> verifyEmailOtp(String email, String otp) async {
    await apiClient.dio.post(
      ApiConstants.verifyEmailOtp,
      data: {"email": email, "otp": otp},
    );
  }

  @override
  Future<void> resendEmailOtp(String email) async {
    await apiClient.dio.post(
      ApiConstants.resendEmailOtp,
      data: {"email": email},
    );
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  UserModel _userFromJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw const FormatException('Invalid JWT');
    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final map = json.decode(payload) as Map<String, dynamic>;
    return UserModel(
      id: (map['id'] ?? map['sub'] ?? '').toString(),
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? map['given_name'] ?? 'Google',
      lastName: map['lastName'] ?? map['family_name'] ?? 'User',
      token: token,
    );
  }
}
