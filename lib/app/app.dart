import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection.dart';

import 'package:flutter/material.dart';
import '../core/theme/theme.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/splash_bloc.dart';
import '../features/auth/presentation/splash_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SplashBloc()),
        BlocProvider(create: (_) => sl<AuthBloc>()),
      ],
      child: MaterialApp(
        title: 'ColabPlatforms AI',
        debugShowCheckedModeBanner: false,

        // ── Themes ──────────────────────────────────────────────────────────────
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system, // app defaults to dark

        // ── Root: show SplashPage ───────────────────────────────────────────────
        home: const SplashPage(),
      ),
    );
  }
}
