import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class DrawerSearchBar extends StatelessWidget {
  const DrawerSearchBar({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.darkBorder.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.darkMutedForeground.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                color: AppColors.darkForeground.withValues(alpha: 0.9),
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Search chats...',
                hintStyle: TextStyle(
                  color: AppColors.darkMutedForeground.withValues(alpha: 0.5),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
