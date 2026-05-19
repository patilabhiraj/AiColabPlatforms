import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  static const String _tokenKey = 'auth_token';

  @override
  Future<void> saveToken(String token) async {
    try {
      // Try writing to SecureStorage first
      await secureStorage.write(key: _tokenKey, value: token);
      print('DEBUG: Token saved successfully in FlutterSecureStorage');
    } catch (secureError) {
      print('DEBUG WARNING: SecureStorage write failed ($secureError). Falling back to SharedPreferences...');
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        print('DEBUG: Token saved successfully in SharedPreferences fallback');
      } catch (prefsError) {
        print('DEBUG ERROR: SharedPreferences write failed ($prefsError)');
      }
    }
  }

  @override
  Future<String?> getToken() async {
    // 1. Try reading from SecureStorage first
    try {
      final token = await secureStorage.read(key: _tokenKey);
      if (token != null && token.isNotEmpty) {
        print('DEBUG: Token read successfully from FlutterSecureStorage');
        return token;
      }
    } catch (secureError) {
      print('DEBUG WARNING: SecureStorage read failed ($secureError). Checking SharedPreferences fallback...');
    }

    // 2. Fallback to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null && token.isNotEmpty) {
        print('DEBUG: Token retrieved from SharedPreferences fallback');
        return token;
      }
    } catch (prefsError) {
      print('DEBUG ERROR: SharedPreferences read failed ($prefsError)');
    }

    print('DEBUG: No token found in any local storage.');
    return null;
  }

  @override
  Future<void> deleteToken() async {
    try {
      await secureStorage.delete(key: _tokenKey);
      print('DEBUG: Token deleted from FlutterSecureStorage');
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      print('DEBUG: Token deleted from SharedPreferences');
    } catch (_) {}
  }
}
