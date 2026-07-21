import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../settings/presentation/pages/subscription_page.dart';

/// A dismissible banner shown above the composer when a send fails. When the
/// error looks like a token/quota exhaustion, it offers an "Upgrade Plan" CTA
/// that opens the subscription page; otherwise it just surfaces the message.
class ChatErrorBanner extends StatelessWidget {
  const ChatErrorBanner({
    super.key,
    required this.message,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onDismiss;

  /// Heuristic: does this error mean the user is out of tokens?
  bool get _isQuotaError {
    final m = message.toLowerCase();
    const needles = [
      'token',
      'quota',
      'limit',
      'exhaust',
      'insufficient',
      'upgrade',
      'balance',
    ];
    return needles.any(m.contains);
  }

  @override
  Widget build(BuildContext context) {
    final quota = _isQuotaError;
    final accent = quota ? context.cPrimary : context.cError;

    final title = quota ? 'You\'re out of tokens' : 'Message failed';
    final body = quota
        ? 'Your token limit is used up. Upgrade your plan to keep chatting.'
        : message;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: context.isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              quota
                  ? Icons.bolt_rounded
                  : Icons.error_outline_rounded,
              color: accent,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: context.cFg,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: TextStyle(
                      color: context.cMuted,
                      fontSize: 12.5,
                      height: 1.3,
                    ),
                  ),
                  if (quota) ...[
                    const SizedBox(height: 10),
                    _UpgradeButton(accent: accent),
                  ],
                ],
              ),
            ),
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close_rounded, size: 18),
              color: context.cMuted,
              visualDensity: VisualDensity.compact,
              tooltip: 'Dismiss',
            ),
          ],
        ),
      ),
    );
  }
}

class _UpgradeButton extends StatelessWidget {
  const _UpgradeButton({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SubscriptionPage()),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                size: 16,
                color: context.cPrimaryFg,
              ),
              const SizedBox(width: 6),
              Text(
                'Upgrade Plan',
                style: TextStyle(
                  color: context.cPrimaryFg,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
