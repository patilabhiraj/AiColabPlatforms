import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('AI Colab Chat'),
        backgroundColor: AppColors.darkCard,
        elevation: 1,
      ),
      body: const Center(
        child: Text(
          'Welcome to the Chat Screen!',
          style: TextStyle(
            color: AppColors.darkForeground,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
