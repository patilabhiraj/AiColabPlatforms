import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'injection.dart';
import 'routes/router.dart';

import 'package:flutter/material.dart';
import '../core/theme/theme.dart';
import '../core/theme/theme_controller.dart';
import '../core/utils/app_logger.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/forgot_password_bloc.dart';
import '../features/auth/bloc/splash_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<SplashBloc>()),
        BlocProvider(create: (_) => sl<AuthBloc>()..add(AuthCheckRequested())),
        BlocProvider(create: (_) => sl<ForgotPasswordBloc>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        // Only react to a genuine logout: a transition INTO AuthInitial from
        // some other state. This avoids firing on app startup (where the bloc
        // already starts in AuthInitial before AuthCheckRequested runs).
        listenWhen: (previous, current) =>
            current is AuthInitial && previous is! AuthInitial,
        listener: (context, state) {
          // Go straight to login. Routing through the splash page would
          // re-trigger SplashBloc's cached-session check and its auto-nav,
          // which races with this navigation and causes the app to hang/crash
          // right after logout.
          logger.info('🚪 User logged out - navigating to login');
          context.go(AppRouter.login);
        },
        // Rebuild MaterialApp whenever the user toggles the theme so the whole
        // app switches between light and dark instantly.
        child: ListenableBuilder(
          listenable: sl<ThemeController>(),
          builder: (context, _) {
            return MaterialApp.router(
              title: 'ColabPlatforms AI',
              debugShowCheckedModeBanner: false,

              // ── Themes ──────────────────────────────────────────────────────────
              // `theme` is what ThemeMode.light resolves to — it must be the
              // light theme, otherwise the toggle switches modes but the UI
              // stays dark.
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: sl<ThemeController>().mode,
              // ── GoRouter Config ─────────────────────────────────────────────────
              routerConfig: AppRouter.router,
            );
          },
        ),
      ),
    );
  }
}
