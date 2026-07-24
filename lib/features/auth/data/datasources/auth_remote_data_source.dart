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

  // Native Google Sign-In: the app obtains a Google ID token via the SDK and
  // exchanges it here. The backend verifies it, creates the account if needed,
  // and returns { user, token, isNewUser } — the same JWT shape as email login.
  @override
  Future<UserModel> googleLogin(String idToken) async {
    final response = await apiClient.dio.post(
      ApiConstants.googleMobile,
      data: {"idToken": idToken},
    );
    return UserModel.fromJson(response.data);
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
}
