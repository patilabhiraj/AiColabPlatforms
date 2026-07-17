import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Shared page shell for every Settings screen: a back button, a title, and
/// a themed background — keeps all settings pages visually consistent.
class SettingsScaffold extends StatelessWidget {
  const SettingsScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cBg,
      appBar: AppBar(
        backgroundColor: context.cBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.cFg),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: context.cFg,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: actions,
      ),
      body: child,
    );
  }
}

/// Rounded card container matching the app's chat-bubble/drawer card style.
class SettingsCard extends StatelessWidget {
  const SettingsCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: context.cCard.withValues(alpha: context.isDark ? 0.55 : 1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cBorder.withValues(alpha: 0.6)),
        // Soft lift so cards read as raised surfaces (esp. in light mode).
        boxShadow: context.softShadow,
      ),
      child: child,
    );
  }
}

class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.cFg,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: context.cMuted.withValues(alpha: 0.85),
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Full-bleed centered loading / error / empty state used across screens.
class SettingsStateView extends StatelessWidget {
  const SettingsStateView.loading({super.key})
      : icon = null,
        message = null,
        isLoading = true,
        onRetry = null;

  const SettingsStateView.error({
    super.key,
    required String this.message,
    this.onRetry,
  })  : icon = Icons.error_outline_rounded,
        isLoading = false;

  const SettingsStateView.empty({
    super.key,
    required String this.message,
    this.icon = Icons.inbox_rounded,
  })  : isLoading = false,
        onRetry = null;

  final bool isLoading;
  final IconData? icon;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: AppColors.landingPrimary,
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: context.cMuted.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            Text(
              message ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.cMuted,
                fontSize: 14,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.cFg,
                  side: BorderSide(color: context.cBorder),
                ),
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
