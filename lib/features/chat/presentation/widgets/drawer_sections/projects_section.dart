import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import 'section_header.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SectionHeader(
            title: 'PROJECTS',
            isExpanded: isExpanded,
            onToggle: onToggle,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.folder_open_outlined,
                  size: 18,
                  color: AppColors.darkMutedForeground.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
                  size: 20,
                  color: AppColors.darkMutedForeground.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 8),
            _ProjectItem(
              icon: Icons.folder_outlined,
              title: 'Restaurant',
              onTap: () {},
              onMore: () {},
            ),
          ],
        ],
      ),
    );
  }
}

class _ProjectItem extends StatelessWidget {
  const _ProjectItem({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.onMore,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.darkMutedForeground.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onMore,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_horiz_rounded,
                    size: 18,
                    color: AppColors.darkMutedForeground.withValues(alpha: 0.6),
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
