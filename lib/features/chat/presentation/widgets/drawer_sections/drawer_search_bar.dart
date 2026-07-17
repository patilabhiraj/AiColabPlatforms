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
        // Sit a hair above the sidebar surface in both themes.
        color: context.cCard.withValues(alpha: context.isDark ? 0.6 : 1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.cBorder.withValues(alpha: context.isDark ? 0.4 : 0.8),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 20,
            color: context.cMuted.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                color: context.cFg.withValues(alpha: 0.9),
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Search chats...',
                hintStyle: TextStyle(
                  color: context.cMuted.withValues(alpha: 0.6),
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
