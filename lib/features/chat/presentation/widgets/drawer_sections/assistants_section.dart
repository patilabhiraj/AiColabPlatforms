import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import 'section_header.dart';

class AssistantsSection extends StatelessWidget {
  const AssistantsSection({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  final bool isExpanded;
  final VoidCallback onToggle;

  // Mock assistant data
  static const List<Map<String, dynamic>> _assistants = [
    {'icon': Icons.code_rounded, 'title': 'Software Engineer'},
    {'icon': Icons.edit_rounded, 'title': 'Content Writer'},
    {'icon': Icons.gavel_rounded, 'title': 'Legal Advisor'},
    {'icon': Icons.campaign_rounded, 'title': 'Marketing'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SectionHeader(
            title: 'ASSISTANTS',
            isExpanded: isExpanded,
            onToggle: onToggle,
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
              size: 20,
              color: AppColors.darkMutedForeground.withValues(alpha: 0.6),
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 8),
            ..._assistants.map((assistant) => _AssistantItem(
              icon: assistant['icon'] as IconData,
              title: assistant['title'] as String,
              onTap: () {},
            )),
            const SizedBox(height: 8),
            _LoadMoreButton(onTap: () {}),
          ],
        ],
      ),
    );
  }
}

class _AssistantItem extends StatelessWidget {
  const _AssistantItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: AppColors.darkMutedForeground.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.darkForeground.withValues(alpha: 0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
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

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Center(
            child: Text(
              'Load More Assistants',
              style: TextStyle(
                color: AppColors.darkMutedForeground.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
