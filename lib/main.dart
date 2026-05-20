import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'app/injection.dart' as di;
import 'app/routes/router.dart';
import 'features/auth/domain/usecases/get_cached_user_usecase.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   di.init();

//   // Force portrait orientation
//   SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);

//   // Transparent status bar — lets splash gradient show through
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.light,
//       systemNavigationBarColor: Color(0xFF0F0F13),
//       systemNavigationBarIconBrightness: Brightness.light,
//     ),
//   );

//   // ── Session Auto-Routing check before starting the app ────────────────────
//   String initialRoute = AppRouter.splash;
//   try {
//     final getCachedUser = di.sl<GetCachedUserUseCase>();
//     final result = await getCachedUser();
//     result.fold(
//       (_) => initialRoute = AppRouter.splash,
//       (user) {
//         if (user != null) {
//           print('DEBUG main(): Active session found for ${user.email}. Setting initial route directly to Chat!');
//           initialRoute = AppRouter.chat;
//         } else {
//           print('DEBUG main(): No cached session. Setting initial route to Splash Page.');
//         }
//       },
//     );
//   } catch (e) {
//     print('DEBUG ERROR in main() check: $e');
//   }

//   // Initialize router with the correct initial location
//   AppRouter.init(initialRoute);

//   runApp(const App());
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  di.init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ✅ Remove the hardcoded SystemUiOverlayStyle from here entirely
  // Handle it in App widget instead

  String initialRoute = AppRouter.splash;
  try {
    final getCachedUser = di.sl<GetCachedUserUseCase>();
    final result = await getCachedUser();
    result.fold(
      (_) => initialRoute = AppRouter.splash,
      (user) {
        if (user != null) {
          initialRoute = AppRouter.chat;
        }
      },
    );
  } catch (e) {
    print('DEBUG ERROR in main() check: $e');
  }

  AppRouter.init(initialRoute);
  runApp(const App());
}