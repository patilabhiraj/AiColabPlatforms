import 'dart:convert';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(
    String firstName,
    String lastName,
    String email,
    String password,
  );
  Future<UserModel> googleLogin(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.login,
        data: {"email": email, "password": password},
      );

      // Parse JSON into UserModel
      return UserModel.fromJson(response.data);
    } catch (e) {
      // Re-throw so the Repository can catch it and convert to a Failure
      rethrow;
    }
  }

  @override
  Future<UserModel> register(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    try {
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
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> googleLogin(String token) async {
    try {
      return _parseUserFromJwt(token);
    } catch (e) {
      rethrow;
    }
  }

  UserModel _parseUserFromJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid token format');
    }
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final resp = utf8.decode(base64Url.decode(normalized));
    final payloadMap = json.decode(resp) as Map<String, dynamic>;

    return UserModel(
      id: payloadMap['id'] ?? 0,
      email: payloadMap['email'] ?? '',
      firstName: payloadMap['firstName'] ?? 'Google',
      lastName: payloadMap['lastName'] ?? 'User',
      token: token,
    );
  }
}
