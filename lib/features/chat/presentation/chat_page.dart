import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xC7C9C9CF),
      appBar: AppBar(
        title: const Text('AI Colab Chat',style: TextStyle(color: Colors.white,)),
        backgroundColor: AppColors.darkCard,
        elevation: 1,
      ),
      body: const Center(
        child: Text(
          'Welcome to the Chat Screen!',
          style: TextStyle(
            color: Color.fromARGB(255, 248, 246, 246),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
