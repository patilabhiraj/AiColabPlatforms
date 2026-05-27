import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'app/injection.dart' as di;
import 'app/routes/router.dart';
import 'core/error/error_handler.dart';
import 'core/utils/app_logger.dart';
import 'features/auth/domain/usecases/get_cached_user_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ── Initialize Logger ─────────────────────────────────────────────────────
  // building the Production only print error log
  const isProduction = bool.fromEnvironment('dart.vm.product');
  logger.init(isProduction: isProduction);
  
  logger.info('🚀 App starting... (Production: $isProduction)');
  
  // ── Initialize Dependency Injection ───────────────────────────────────────
  di.init();

  // Force portrait orientation                               
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar — lets splash gradient show through
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F0F13),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // ── Session Auto-Routing check before starting the app ────────────────────
  String initialRoute = AppRouter.splash;
  
  try {
    final getCachedUser = di.sl<GetCachedUserUseCase>();
    final result = await getCachedUser();
    
    result.fold(
      (failure) {
        logger.warning('No cached session found: ${failure.toString()}');
        initialRoute = AppRouter.splash;
      },
      (user) {
        if (user != null) {
          logger.info('✅ Active session found for ${user.email}. Routing to Chat.');
          initialRoute = AppRouter.chat;
        } else {
          logger.info('No cached user. Routing to Splash.');
          initialRoute = AppRouter.splash;
        }
      },
    );
  } catch (e, stackTrace) {
    ErrorHandler.logError('Session Check', e, stackTrace);
    // Fallback to splash on any error
    initialRoute = AppRouter.splash;
  }

  // Initialize router with the correct initial location
  AppRouter.init(initialRoute);

  runApp(const App());
}
