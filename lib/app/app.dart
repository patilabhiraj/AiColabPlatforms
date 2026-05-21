import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection.dart';
import 'routes/router.dart';

import 'package:flutter/material.dart';
import '../core/theme/theme.dart';
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
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<ForgotPasswordBloc>()),
      ],
      child: MaterialApp.router(
        title: 'ColabPlatforms AI',
        debugShowCheckedModeBanner: false,

        // ── Themes ──────────────────────────────────────────────────────────────
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system, // app defaults to dark

        // ── GoRouter Config ─────────────────────────────────────────────────────
        routerConfig: AppRouter.router,
      ),
    );
  }
}