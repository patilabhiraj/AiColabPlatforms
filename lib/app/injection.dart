import 'package:get_it/get_it.dart';

import '../core/network/api_client.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/google_login_usecase.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';

final sl = GetIt.instance; // sl = service locator

void init() {
  // ── Core ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => ApiClient());

  // ── Data Sources ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // ── Repositories ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // ── Use Cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GoogleLoginUseCase(sl()));

  // ── BLoCs ─────────────────────────────────────────────────────────────────
  // Factory means a new instance is created every time it's requested (good for Blocs if needed), 
  // but registering as LazySingleton is also fine for global Auth state. Let's use Factory.
  sl.registerFactory(() => AuthBloc(sl(), sl(), sl()));
}
