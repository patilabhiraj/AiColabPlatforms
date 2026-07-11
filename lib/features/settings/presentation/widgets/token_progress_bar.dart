import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';

final _tokenFormat = NumberFormat.decimalPattern();

class TokenProgressBar extends StatelessWidget {
  const TokenProgressBar({
    super.key,
    required this.tokensUsed,
    required this.totalTokens,
    required this.usagePercent,
  });

  final int tokensUsed;
  final int totalTokens;
  final double usagePercent;

  @override
  Widget build(BuildContext context) {
    final clamped = usagePercent.clamp(0, 100).toDouble();
    final isHigh = usagePercent >= 90;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Used',
              style: TextStyle(color: context.cMuted, fontSize: 13),
            ),
            Text(
              '${_tokenFormat.format(tokensUsed)} / ${_tokenFormat.format(totalTokens)}',
              style: TextStyle(
                color: context.cFg,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 8,
                    width: double.infinity,
                    color: context.cMuted.withValues(alpha: 0.18),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    height: 8,
                    width: constraints.maxWidth * (clamped / 100),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isHigh
                            ? [
                                AppColors.darkDestructive,
                                AppColors.darkDestructive.withValues(alpha: 0.7),
                              ]
                            : [
                                AppColors.landingPrimary,
                                AppColors.landingPrimary.withValues(alpha: 0.6),
                              ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${usagePercent.toStringAsFixed(1)}% used',
              style: TextStyle(color: context.cMuted.withValues(alpha: 0.8), fontSize: 12),
            ),
            Text(
              '${_tokenFormat.format(totalTokens - tokensUsed)} remaining',
              style: TextStyle(color: context.cMuted.withValues(alpha: 0.8), fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

/// Compact stat tile used in the Dashboard grid ("Tokens Remaining", etc).
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cCard.withValues(alpha: context.isDark ? 0.55 : 1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cBorder.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: context.cMuted.withValues(alpha: 0.85),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    color: context.cFg,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 19),
          ),
        ],
      ),
    );
  }
}
