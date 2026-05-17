import 'package:flutter/material.dart';

import 'login_page.dart';
import 'register_page.dart';

class AuthPage extends StatelessWidget {
  final bool isLogin;

  const AuthPage({super.key, this.isLogin = true});

  @override
  Widget build(BuildContext context) {
    return isLogin ? const LoginPage() : const RegisterPage();
  }
}
