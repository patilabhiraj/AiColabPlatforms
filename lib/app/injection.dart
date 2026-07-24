import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../core/network/api_client.dart';
import '../core/theme/theme_controller.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/forgot_password_bloc.dart';
import '../features/auth/bloc/splash_bloc.dart';
import '../features/auth/data/datasources/auth_local_data_source.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/data/services/google_auth_service.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../features/auth/domain/usecases/get_cached_user_usecase.dart';
import '../features/auth/domain/usecases/google_login_usecase.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/auth/domain/usecases/resend_email_otp_usecase.dart';
import '../features/auth/domain/usecases/reset_password_usecase.dart';
import '../features/auth/domain/usecases/verify_email_otp_usecase.dart';
import '../features/chat/bloc/chat_bloc.dart';
import '../features/chat/data/datasources/chat_remote_data_source.dart';
import '../features/chat/data/repositories/chat_repository_impl.dart';
import '../features/chat/domain/repositories/chat_repository.dart';
import '../features/chat/domain/usecases/create_conversation_usecase.dart';
import '../features/chat/domain/usecases/get_assistants_usecase.dart';
import '../features/chat/domain/usecases/get_conversations_usecase.dart';
import '../features/chat/domain/usecases/get_messages_usecase.dart';
import '../features/chat/domain/usecases/get_models_usecase.dart';
import '../features/chat/domain/usecases/get_shared_chat_usecase.dart';
import '../features/chat/domain/usecases/send_message_usecase.dart';
import '../features/settings/bloc/account/account_bloc.dart';
import '../features/settings/bloc/archived/archived_chats_bloc.dart';
import '../features/settings/bloc/dashboard/dashboard_bloc.dart';
import '../features/settings/bloc/preferences/preferences_bloc.dart';
import '../features/settings/bloc/subscription/subscription_bloc.dart';
import '../features/settings/bloc/usage/usage_bloc.dart';
import '../features/settings/bloc/wallet/wallet_bloc.dart';
import '../features/settings/cashfree_service.dart';
import '../features/settings/data/datasources/settings_remote_data_source.dart';
import '../features/settings/data/repositories/settings_repository_impl.dart';
import '../features/settings/domain/repositories/settings_repository.dart';
import '../features/settings/domain/usecases/account_usecases.dart';
import '../features/settings/domain/usecases/archived_chats_usecases.dart';
import '../features/settings/domain/usecases/get_dashboard_summary_usecase.dart';
import '../features/settings/domain/usecases/get_usage_logs_usecase.dart';
import '../features/settings/domain/usecases/get_wallet_usecase.dart';
import '../features/settings/domain/usecases/preferences_usecases.dart';
import '../features/settings/domain/usecases/subscription_usecases.dart';

final sl = GetIt.instance;

void init() {
  // ── Core & External ──────────────────────────────────────────────────────
  sl.registerLazySingleton(() => ApiClient());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => ThemeController());
  sl.registerLazySingleton(() => GoogleAuthService());

  // ── Data Sources ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(sl<ApiClient>().dio),
  );

  // ── Repositories ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl()),
  );

  // ── Use Cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GoogleLoginUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => GetCachedUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => VerifyEmailOtpUseCase(sl()));
  sl.registerLazySingleton(() => ResendEmailOtpUseCase(sl()));
  sl.registerLazySingleton(() => GetConversationsUseCase(sl()));
  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => CreateConversationUseCase(sl()));
  sl.registerLazySingleton(() => GetModelsUseCase(sl()));
  sl.registerLazySingleton(() => GetAssistantsUseCase(sl()));
  sl.registerLazySingleton(() => GetSharedChatUseCase(sl()));

  // ── Settings Use Cases ────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetDashboardSummaryUseCase(sl()));
  sl.registerLazySingleton(() => GetWalletUseCase(sl()));
  sl.registerLazySingleton(() => GetWalletTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => GetUsageLogsUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentSubscriptionUseCase(sl()));
  sl.registerLazySingleton(() => GetPlansUseCase(sl()));
  sl.registerLazySingleton(() => CancelSubscriptionUseCase(sl()));
  // नवीन: Payment साठी
  sl.registerLazySingleton(() => CreateSubscriptionUseCase(sl()));
  sl.registerLazySingleton(() => CashfreeService());
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));
  sl.registerLazySingleton(() => GetPreferencesUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePreferencesUseCase(sl()));
  sl.registerLazySingleton(() => GetArchivedChatsUseCase(sl()));
  sl.registerLazySingleton(() => UnarchiveChatUseCase(sl()));

  // ── BLoCs ─────────────────────────────────────────────────────────────────
  sl.registerFactory(() => SplashBloc(sl()));
  sl.registerFactory(() => AuthBloc(sl(), sl(), sl(), sl(), sl()));
  sl.registerFactory(() => ForgotPasswordBloc(sl(), sl()));
  sl.registerFactory(() => ChatBloc(sl(), sl(), sl(), sl(), sl(), sl(), sl()));
  sl.registerFactory(() => DashboardBloc(sl()));
  sl.registerFactory(() => WalletBloc(sl(), sl()));
  sl.registerFactory(() => UsageBloc(sl()));
  sl.registerFactory(() => SubscriptionBloc(sl(), sl(), sl(), sl(), sl()));
  sl.registerFactory(() => AccountBloc(sl(), sl(), sl()));
  sl.registerFactory(() => PreferencesBloc(sl(), sl()));
  sl.registerFactory(() => ArchivedChatsBloc(sl(), sl()));
}
