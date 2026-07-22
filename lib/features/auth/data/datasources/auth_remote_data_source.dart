import 'dart:convert';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String firstName, String lastName, String email, String password);
  Future<UserModel> googleLogin(String token);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String email, String otp, String newPassword);

  /// Verifies the email OTP. Returns the JWT token if the backend auto-logs the
  /// user in on verification, or an empty string if it only confirms the OTP.
  Future<String> verifyEmailOtp(String email, String otp);
  Future<void> resendEmailOtp(String email);
  Future<UserModel> getProfile();
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
    
    // Check if email verification is required
    final data = response.data['data'];
    if (data != null && data['requiresEmailVerification'] == true) {
      final userEmail = data['email'] ?? email;
      throw EmailVerificationRequiredException(
        email: userEmail,
        message: 'Email verification required',
      );
    }
    
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
    
    // Check if email verification is required
    final data = response.data['data'];
    if (data != null && data['requiresEmailVerification'] == true) {
      final userEmail = data['email'] ?? email;
      throw EmailVerificationRequiredException(
        email: userEmail,
        message: 'Email verification required',
      );
    }
    
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
  Future<String> verifyEmailOtp(String email, String otp) async {
    final response = await apiClient.dio.post(
      ApiConstants.verifyEmailOtp,
      data: {"email": email, "otp": otp},
    );

    // If the backend auto-logs the user in on verification, it returns a JWT.
    // Reuse UserModel's tolerant token extraction (handles token/accessToken,
    // top-level or nested under `data`). Empty string means "verified only".
    try {
      return UserModel.fromJson(response.data).token;
    } catch (_) {
      return '';
    }
  }

  @override
  Future<void> resendEmailOtp(String email) async {
    await apiClient.dio.post(
      ApiConstants.resendEmailOtp,
      data: {"email": email},
    );
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await apiClient.dio.get(ApiConstants.userProfile);
    return UserModel.fromJson(response.data);
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
