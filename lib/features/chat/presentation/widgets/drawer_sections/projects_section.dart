import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import 'section_header.dart';

/// Projects section in the sidebar drawer.
///
/// Currently shows a clean empty state while the backend projects API is
/// not yet available. The structure is ready to plug real data in once
/// a projects repository is wired.
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  color: context.cMuted.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_right_rounded,
                  size: 20,
                  color: context.cMuted.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 8),
            _ProjectsEmptyState(),
          ],
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _ProjectsEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Row(
        children: [
          Icon(
            Icons.folder_off_outlined,
            size: 15,
            color: context.cMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Text(
            'No projects yet',
            style: TextStyle(
              color: context.cMuted.withValues(alpha: 0.55),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
