import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import 'section_header.dart';

class ContextsSection extends StatelessWidget {
  const ContextsSection({
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
            title: 'CONTEXTS',
            isExpanded: isExpanded,
            onToggle: onToggle,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_rounded,
                  size: 18,
                  color: context.cMuted.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
                  size: 20,
                  color: context.cMuted.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 8),
            _ContextItem(
              title: 'My Name',
              isChecked: true,
              onTap: () {},
              onMore: () {},
            ),
          ],
        ],
      ),
    );
  }
}

class _ContextItem extends StatelessWidget {
  const _ContextItem({
    required this.title,
    required this.isChecked,
    required this.onTap,
    required this.onMore,
  });

  final String title;
  final bool isChecked;
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
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isChecked 
                      ? context.cMuted.withValues(alpha: 0.3)
                      : Colors.transparent,
                  border: Border.all(
                    color: context.cMuted.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isChecked
                    ? Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: context.cFg.withValues(alpha: 0.9),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: context.cFg.withValues(alpha: 0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onMore,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_horiz_rounded,
                    size: 18,
                    color: context.cMuted.withValues(alpha: 0.6),
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
