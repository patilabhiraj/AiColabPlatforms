import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../bloc/chat_bloc.dart';
import '../../../domain/entities/assistant.dart';
import '../catalog_visuals.dart';
import 'section_header.dart';

/// Lists the assistants from `/api/assistants`. Each assistant carries its own
/// gradient colours, so its icon tile and selected highlight use that colour —
/// every assistant looks distinct (and adapts to light/dark mode).
class AssistantsSection extends StatelessWidget {
  const AssistantsSection({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (a, b) => b is ChatLoaded,
      builder: (context, state) {
        final assistants =
            state is ChatLoaded ? state.assistants : const <Assistant>[];
        final selectedId =
            state is ChatLoaded ? state.selectedAssistant?.id : null;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SectionHeader(
                title: 'ASSISTANTS',
                isExpanded: isExpanded,
                onToggle: onToggle,
                trailing: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_right_rounded,
                  size: 20,
                  color: context.cMuted.withValues(alpha: 0.6),
                ),
              ),
              if (isExpanded) ...[
                const SizedBox(height: 8),
                if (assistants.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Loading assistants…',
                      style: TextStyle(
                        color: context.cMuted.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  )
                else
                  ...assistants.map((a) => _AssistantItem(
                        assistant: a,
                        selected: a.id == selectedId,
                        onTap: () {
                          context.read<ChatBloc>().add(ChatSelectAssistant(a));
                          Navigator.of(context).pop(); // close drawer
                        },
                      )),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AssistantItem extends StatelessWidget {
  const _AssistantItem({
    required this.assistant,
    required this.selected,
    required this.onTap,
  });

  final Assistant assistant;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final accent = CatalogVisuals.assistantAccent(assistant, isDark: isDark);
    final gradient = CatalogVisuals.assistantGradient(assistant, isDark: isDark);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: selected ? accent.withValues(alpha: 0.16) : null,
              border: selected
                  ? Border.all(color: accent.withValues(alpha: 0.45))
                  : null,
            ),
            child: Row(
              children: [
                // Icon tile tinted with the assistant's own gradient
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        gradient.first.withValues(alpha: isDark ? 0.9 : 1),
                        gradient.last.withValues(alpha: isDark ? 0.9 : 1),
                      ],
                    ),
                  ),
                  child: Icon(
                    CatalogVisuals.assistantIcon(assistant.icon),
                    size: 17,
                    color: isDark ? Colors.white : Colors.black.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    assistant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.cFg.withValues(alpha: 0.9),
                      fontSize: 15,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle_rounded,
                      size: 16, color: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
