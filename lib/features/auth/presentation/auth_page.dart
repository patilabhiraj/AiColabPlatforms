import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AuthPage extends StatelessWidget {
  final bool isLogin;
  
  const AuthPage({super.key, this.isLogin = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkForeground),
      ),
      body: Center(
        child: Text(
          isLogin ? 'Sign In Page\n(Coming Soon)' : 'Create Account Page\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.darkForeground,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
