import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({super.key, required this.onSuggestion});
  final ValueChanged<String> onSuggestion;

  static const _cards = [
    (Icons.lightbulb_outline_rounded, 'Explain a concept',
        'Get clear explanations on any topic'),
    (Icons.code_rounded, 'Write or review code',
        'Any language or framework'),
    (Icons.bug_report_outlined, 'Debug an issue',
        'Find and fix errors fast'),
    (Icons.auto_awesome_outlined, 'Brainstorm ideas',
        'Creative suggestions and plans'),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.landingPrimary.withValues(alpha: 0.10),
                border: Border.all(
                  color: AppColors.landingPrimary.withValues(alpha: 0.30),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.all_inclusive_rounded,
                color: AppColors.landingPrimary,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),

            const Text(
              'AI Colab',
              style: TextStyle(
                color: AppColors.darkForeground,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'How can I help you today?',
              style: TextStyle(
                color: AppColors.darkMutedForeground,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 34),

            // 2 × 2 suggestion grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.2,
              children: _cards
                  .map((c) => _SuggestionCard(
                        icon: c.$1,
                        title: c.$2,
                        subtitle: c.$3,
                        onTap: () => onSuggestion(c.$2),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderXl,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: AppRadius.borderXl,
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.landingPrimary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderMd,
                ),
                child: Icon(icon, color: AppColors.landingPrimary, size: 18),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.darkForeground,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.darkMutedForeground,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
