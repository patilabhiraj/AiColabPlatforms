import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection.dart';
import 'routes/router.dart';

import 'package:flutter/material.dart';
import '../core/theme/theme.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/forgot_password_bloc.dart';
import '../features/auth/bloc/splash_bloc.dart';

// class App extends StatelessWidget {
//   const App({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (_) => sl<SplashBloc>()),
//         BlocProvider(create: (_) => sl<AuthBloc>()),
//         BlocProvider(create: (_) => sl<ForgotPasswordBloc>()),
//       ],
//       child: MaterialApp.router(
//         title: 'ColabPlatforms AI',
//         debugShowCheckedModeBanner: false,

//         // ── Themes ──────────────────────────────────────────────────────────────
//         theme: AppTheme.light,
//         darkTheme: AppTheme.dark,
//         themeMode: ThemeMode.system, // app defaults to dark

//         // ── GoRouter Config ─────────────────────────────────────────────────────
//         routerConfig: AppRouter.router,
//       ),
//     );
//   }
// }
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<SplashBloc>()),
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<ForgotPasswordBloc>()),
      ],
      child: MaterialApp.router(
        title: 'ColabPlatforms AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,

        // ✅ This builder wraps every screen and keeps system UI in sync
        builder: (context, child) {
          final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarColor: isDark
                  ? AppColors.darkBackground   // 0xFF0F0F13
                  : AppColors.lightBackground, // 0xFFFFFFFF
              systemNavigationBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
            ),
          );

          return child!;
        },
      ),
    );
  }
}