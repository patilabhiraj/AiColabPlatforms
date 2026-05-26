import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/app_logger.dart';
import '../../features/auth/presentation/email_verification_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/auth/presentation/splash_page.dart';
import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/chat/bloc/chat_bloc.dart';
import '../../features/chat/presentation/chat_page.dart';
import '../injection.dart' show sl;

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';
  static const String chat = '/chat';

  static late final GoRouter router;

  static void init(String initialLocation) {
    logger.info('Initializing GoRouter with route: "$initialLocation"');
    router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: register,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: forgotPassword,
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: emailVerification,
          builder: (context, state) {
            final email = state.uri.queryParameters['email'] ?? '';
            return EmailVerificationPage(email: email);
          },
        ),
        GoRoute(
          path: chat,
          builder: (context, state) => BlocProvider(
            create: (_) => sl<ChatBloc>()..add(ChatLoadConversations()),
            child: const ChatPage(),
          ),
        ),
      ],
    );
  }
}
