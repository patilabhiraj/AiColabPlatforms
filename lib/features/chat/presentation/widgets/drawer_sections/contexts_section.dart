import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../bloc/chat_bloc.dart';
import '../../../domain/entities/user_context.dart';
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
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (prev, curr) {
        if (curr is ChatLoaded && prev is ChatLoaded) {
          return prev.sidebarContexts != curr.sidebarContexts ||
              prev.activeContextIds != curr.activeContextIds;
        }
        return curr is ChatLoaded;
      },
      builder: (context, state) {
        final contexts =
            state is ChatLoaded ? state.sidebarContexts : const <UserContext>[];
        final activeIds =
            state is ChatLoaded ? state.activeContextIds : const <String>{};

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'CONTEXTS',
                isExpanded: isExpanded,
                onToggle: onToggle,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Add context button
                    GestureDetector(
                      onTap: () => _showAddContextDialog(context),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.add_rounded,
                          size: 18,
                          color: context.cMuted.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
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
                if (contexts.isEmpty)
                  _ContextsEmptyState()
                else
                  ...contexts.map(
                    (ctx) => _ContextItem(
                      context: ctx,
                      isChecked: activeIds.contains(ctx.id),
                      onToggle: () {
                        context
                            .read<ChatBloc>()
                            .add(ChatToggleContext(ctx.id));
                      },
                      onDelete: () {
                        context
                            .read<ChatBloc>()
                            .add(ChatDeleteContext(ctx.id));
                      },
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showAddContextDialog(BuildContext context) {
    final nameController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.add_circle_outline_rounded,
                    color: sheetCtx.cPrimary, size: 22),
                const SizedBox(width: 10),
                Text(
                  'New Context',
                  style: TextStyle(
                    color: sheetCtx.cFg,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SheetField(
              controller: nameController,
              label: 'Name',
              hint: 'e.g. My Name, Work Role, Preferences…',
              context: sheetCtx,
            ),
            const SizedBox(height: 14),
            _SheetField(
              controller: contentController,
              label: 'Content',
              hint: 'Describe what you want the AI to know…',
              context: sheetCtx,
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: sheetCtx.cPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final name = nameController.text.trim();
                  final content = contentController.text.trim();
                  if (name.isEmpty || content.isEmpty) return;
                  // Dismiss — context create flow TBD in phase 2
                  Navigator.pop(sheetCtx);
                },
                child: const Text(
                  'Save Context',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _ContextsEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 15,
            color: context.cMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Text(
            'No contexts yet — tap + to add one',
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

// ── Single context row ────────────────────────────────────────────────────────
class _ContextItem extends StatelessWidget {
  const _ContextItem({
    required this.context,
    required this.isChecked,
    required this.onToggle,
    required this.onDelete,
  });

  final UserContext context;
  final bool isChecked;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext ctx) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Checkbox indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isChecked
                      ? ctx.cPrimary.withValues(alpha: 0.85)
                      : Colors.transparent,
                  border: Border.all(
                    color: isChecked
                        ? ctx.cPrimary
                        : ctx.cMuted.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isChecked
                    ? const Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.name,
                      style: TextStyle(
                        color: ctx.cFg.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (context.content.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        context.content,
                        style: TextStyle(
                          color: ctx.cMuted.withValues(alpha: 0.55),
                          fontSize: 11.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // More menu
              GestureDetector(
                onTap: () => _showOptions(ctx),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_horiz_rounded,
                    size: 18,
                    color: ctx.cMuted.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: ctx.cCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                isChecked
                    ? Icons.check_box_outline_blank_rounded
                    : Icons.check_box_rounded,
                color: sheetCtx.cFg,
              ),
              title: Text(
                isChecked ? 'Deactivate' : 'Activate',
                style: TextStyle(color: sheetCtx.cFg),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                onToggle();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
              ),
              title: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper: form field ────────────────────────────────────────────────────────
class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.context,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final BuildContext context;
  final int maxLines;

  @override
  Widget build(BuildContext ctx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: ctx.cMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: ctx.cFg, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: ctx.cMuted.withValues(alpha: 0.45),
              fontSize: 13,
            ),
            filled: true,
            fillColor: ctx.cSidebar,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: ctx.cBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: ctx.cBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: ctx.cPrimary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
