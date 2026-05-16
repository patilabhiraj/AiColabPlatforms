import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/theme.dart';
import '../features/auth/bloc/splash_bloc.dart';
import '../features/auth/presentation/splash_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ColabPlatforms AI',
      debugShowCheckedModeBanner: false,

      // ── Themes ──────────────────────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark, // app defaults to dark

      // ── Root: provide SplashBloc and show SplashPage ──────────────────────
      home: BlocProvider(
        create: (_) => SplashBloc(),
        child: const SplashPage(),
      ),
    );
  }
}
