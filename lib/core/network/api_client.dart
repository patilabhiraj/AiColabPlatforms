import 'package:dio/dio.dart';
import '../../app/injection.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../constants/api_constants.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ── Auth Token Injection Interceptor ──────────────────────────────────────
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            // Lazily resolve AuthLocalDataSource to bypass circular dependency during DI
            if (sl.isRegistered<AuthLocalDataSource>()) {
              final localDataSource = sl<AuthLocalDataSource>();
              final token = await localDataSource.getToken();
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            }
          } catch (_) {
            // Gracefully ignore token extraction issues on boot
          }
          return handler.next(options);
        },
      ),
    );

    // ── Logging Interceptor ──────────────────────────────────────────────────
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
      ),
    );
  }
}
