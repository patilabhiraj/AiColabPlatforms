import 'package:flutter/material.dart';

class CustomSnackBar {

  static void showError(
    BuildContext context,
    String message,
  ) {
    _show(
      context,
      message,
      Icons.error_outline_rounded,
      const Color(0xFFFF4D4F),
    );
  }

  static void showSuccess(
    BuildContext context,
    String message,
  ) {
    _show(
      context,
      message,
      Icons.check_circle_outline_rounded,
      const Color(0xFF22C55E),
    );
  }

  static void showInfo(
    BuildContext context,
    String message,
  ) {
    _show(
      context,
      message,
      Icons.info_outline_rounded,
      const Color(0xFF3B82F6),
    );
  }

  static void showWarning(
    BuildContext context,
    String message,
  ) {
    _show(
      context,
      message,
      Icons.warning_amber_rounded,
      const Color(0xFFF59E0B),
    );
  }

  static void _show(
    BuildContext context,
    String message,
    IconData icon,
    Color color,
  ) {

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          duration: const Duration(seconds: 3),

          content: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),

            decoration: BoxDecoration(
              color: const Color(0xFF1C1C2E),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: color.withValues(alpha: 0.25),
              ),
            
            ),

            child: Row(
              children: [

                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}