import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_logger.dart';
import '../../bloc/chat_bloc.dart';
import 'drawer_sections/drawer_header.dart' as custom_header;
import 'drawer_sections/drawer_search_bar.dart';
import 'drawer_sections/projects_section.dart';
import 'drawer_sections/contexts_section.dart';
import 'drawer_sections/assistants_section.dart';
import 'drawer_sections/chats_section.dart';
import 'drawer_sections/drawer_profile_footer.dart';

class ChatDrawer extends StatefulWidget {
  const ChatDrawer({super.key});

  @override
  State<ChatDrawer> createState() => _ChatDrawerState();
}

class _ChatDrawerState extends State<ChatDrawer> {
  final TextEditingController _searchController = TextEditingController();
  bool _projectsExpanded = true;
  bool _contextsExpanded = true;
  bool _assistantsExpanded = true;
  bool _chatsExpanded = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNewChat() {
    logger.info('Creating new chat from drawer');
    context.read<ChatBloc>().add(ChatStartNewConversation());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.cSidebar,
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: Column(
          children: [
            // Header with logo and close button
            custom_header.ChatDrawerHeader(
              onClose: () => Navigator.pop(context),
            ),

            // New Chat button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _NewChatButton(onTap: _onNewChat),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DrawerSearchBar(controller: _searchController),
            ),

            // Scrollable sections
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                children: [
                  // Projects section
                  ProjectsSection(
                    isExpanded: _projectsExpanded,
                    onToggle: () => setState(() => _projectsExpanded = !_projectsExpanded),
                  ),

                  const SizedBox(height: 12),

                  // Contexts section
                  ContextsSection(
                    isExpanded: _contextsExpanded,
                    onToggle: () => setState(() => _contextsExpanded = !_contextsExpanded),
                  ),

                  const SizedBox(height: 12),

                  // Assistants section
                  AssistantsSection(
                    isExpanded: _assistantsExpanded,
                    onToggle: () => setState(() => _assistantsExpanded = !_assistantsExpanded),
                  ),

                  const SizedBox(height: 12),

                  // Chats section
                  ChatsSection(
                    isExpanded: _chatsExpanded,
                    onToggle: () => setState(() => _chatsExpanded = !_chatsExpanded),
                    onChatTap: (conversation) {
                      context.read<ChatBloc>().add(ChatSelectConversation(conversation));
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // Profile footer
            Divider(color: context.cBorder, height: 1),
            const DrawerProfileFooter(),
          ],
        ),
      ),
    );
  }
}

// ── New Chat Button ───────────────────────────────────────────────────────────
class _NewChatButton extends StatelessWidget {
  const _NewChatButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: context.cCard.withValues(alpha: context.isDark ? 0 : 1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: context.cBorder.withValues(alpha: context.isDark ? 0.6 : 0.9),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.add_rounded,
                size: 20,
                color: context.cFg.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 10),
              Text(
                'New Chat',
                style: TextStyle(
                  color: context.cFg.withValues(alpha: 0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
