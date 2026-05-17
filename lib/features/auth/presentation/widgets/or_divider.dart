import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.darkBorder, thickness: 1),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.darkBackground,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'OR CONTINUE WITH',
            style: TextStyle(
              color: AppColors.darkMutedForeground,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.darkBorder, thickness: 1),
        ),
      ],
    );
  }
}
