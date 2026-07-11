import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../app/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../bloc/archived/archived_chats_bloc.dart';
import '../widgets/settings_scaffold.dart';

class ArchivedChatsPage extends StatelessWidget {
  const ArchivedChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ArchivedChatsBloc>()..add(ArchivedChatsLoadRequested()),
      child: const _ArchivedChatsView(),
    );
  }
}

class _ArchivedChatsView extends StatelessWidget {
  const _ArchivedChatsView();

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Archived Chats',
      child: BlocConsumer<ArchivedChatsBloc, ArchivedChatsState>(
        listener: (context, state) {
          if (state is ArchivedChatsLoaded && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          if (state is ArchivedChatsLoading || state is ArchivedChatsInitial) {
            return const SettingsStateView.loading();
          }
          if (state is ArchivedChatsError) {
            return SettingsStateView.error(
              message: state.message,
              onRetry: () => context
                  .read<ArchivedChatsBloc>()
                  .add(ArchivedChatsLoadRequested()),
            );
          }

          final loaded = state as ArchivedChatsLoaded;
          if (loaded.chats.isEmpty) {
            return const SettingsStateView.empty(
              message:
                  'Chats you archive from the sidebar will appear here. You can unarchive them anytime.',
              icon: Icons.archive_rounded,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: loaded.chats.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final chat = loaded.chats[index];
              final unarchiving = loaded.unarchivingId == chat.id;

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.cCard.withValues(alpha: context.isDark ? 0.5 : 1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.cBorder.withValues(alpha: 0.6)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: context.cMuted.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.chat_bubble_outline_rounded,
                          size: 16, color: context.cMuted),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chat.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.cFg,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat.yMMMd().format(chat.updatedAt),
                            style: TextStyle(color: context.cMuted, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: unarchiving
                          ? null
                          : () => context
                              .read<ArchivedChatsBloc>()
                              .add(ArchivedChatUnarchiveRequested(chat.id)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.landingPrimary,
                        side: const BorderSide(color: AppColors.landingPrimary),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      icon: unarchiving
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.unarchive_rounded, size: 15),
                      label: const Text('Unarchive', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
