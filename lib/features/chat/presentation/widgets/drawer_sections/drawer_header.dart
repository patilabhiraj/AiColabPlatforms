import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class ChatDrawerHeader extends StatelessWidget {
  const ChatDrawerHeader({
    super.key,
    required this.onClose,
  });

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.landingPrimary.withValues(alpha: 0.1),
              border: Border.all(
                color: AppColors.landingPrimary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.all_inclusive_rounded,
              color: AppColors.landingPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'COLAB',
            style: TextStyle(
              color: context.cFg,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          // Close button
          IconButton(
            onPressed: onClose,
            icon: Icon(
              Icons.close_rounded,
              color: context.cMuted,
              size: 24,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
