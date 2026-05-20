import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../core/network/api_client.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/forgot_password_bloc.dart';
import '../features/auth/bloc/splash_bloc.dart';
import '../features/auth/data/datasources/auth_local_data_source.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../features/auth/domain/usecases/get_cached_user_usecase.dart';
import '../features/auth/domain/usecases/google_login_usecase.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/auth/domain/usecases/reset_password_usecase.dart';
import '../features/chat/bloc/chat_bloc.dart';
import '../features/chat/data/datasources/chat_remote_data_source.dart';
import '../features/chat/data/repositories/chat_repository_impl.dart';
import '../features/chat/domain/repositories/chat_repository.dart';
import '../features/chat/domain/usecases/get_conversations_usecase.dart';
import '../features/chat/domain/usecases/get_messages_usecase.dart';
import '../features/chat/domain/usecases/send_message_usecase.dart';

final sl = GetIt.instance;

void init() {
  // ── Core & External ──────────────────────────────────────────────────────
  sl.registerLazySingleton(() => ApiClient());
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // ── Data Sources ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(),
  );

  // ── Repositories ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(sl()),
  );

  // ── Use Cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GoogleLoginUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => GetCachedUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetConversationsUseCase(sl()));
  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));

  // ── BLoCs ─────────────────────────────────────────────────────────────────
  sl.registerFactory(() => SplashBloc(sl()));
  sl.registerFactory(() => AuthBloc(sl(), sl(), sl()));
  sl.registerFactory(() => ForgotPasswordBloc(sl(), sl()));
  sl.registerFactory(() => ChatBloc(sl(), sl(), sl()));
}
