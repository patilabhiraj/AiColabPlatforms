import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../app/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../bloc/usage/usage_bloc.dart';
import '../../domain/entities/usage_log_entity.dart';
import '../widgets/settings_scaffold.dart';

class UsagePage extends StatelessWidget {
  const UsagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : '';

    return BlocProvider(
      create: (_) => sl<UsageBloc>()..add(UsageLoadRequested(userId: userId)),
      child: const _UsageView(),
    );
  }
}

class _UsageView extends StatelessWidget {
  const _UsageView();

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'My Usage',
      child: BlocBuilder<UsageBloc, UsageState>(
        builder: (context, state) {
          if (state is UsageLoading || state is UsageInitial) {
            return const SettingsStateView.loading();
          }
          if (state is UsageError) {
            return SettingsStateView.error(message: state.message);
          }

          final loaded = state as UsageLoaded;
          if (loaded.logs.isEmpty && !loaded.loading) {
            return const SettingsStateView.empty(
              message: 'No usage history yet.',
              icon: Icons.query_stats_rounded,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Your token usage history',
                style: TextStyle(color: context.cMuted, fontSize: 13.5),
              ),
              const SizedBox(height: 16),
              ...loaded.logs.map((log) => _UsageLogTile(log: log)),
              if (loaded.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.landingPrimary,
                    ),
                  ),
                ),
              if (loaded.totalPages > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: loaded.page > 1
                            ? () => context
                                .read<UsageBloc>()
                                .add(UsagePageRequested(page: loaded.page - 1))
                            : null,
                        icon: const Icon(Icons.chevron_left_rounded),
                        color: context.cFg,
                      ),
                      Text(
                        'Page ${loaded.page} of ${loaded.totalPages}',
                        style: TextStyle(color: context.cMuted, fontSize: 12.5),
                      ),
                      IconButton(
                        onPressed: loaded.page < loaded.totalPages
                            ? () => context
                                .read<UsageBloc>()
                                .add(UsagePageRequested(page: loaded.page + 1))
                            : null,
                        icon: const Icon(Icons.chevron_right_rounded),
                        color: context.cFg,
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _UsageLogTile extends StatelessWidget {
  const _UsageLogTile({required this.log});
  final UsageLogGroupEntity log;

  @override
  Widget build(BuildContext context) {
    final tokenFormat = NumberFormat.decimalPattern();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: log.subLogs.length > 1 ? () => _showBreakdown(context) : null,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.cCard.withValues(alpha: context.isDark ? 0.5 : 1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.cBorder.withValues(alpha: 0.6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: log.models
                            .map((m) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: context.cBorder),
                                  ),
                                  child: Text(
                                    m.name,
                                    style: TextStyle(
                                        color: context.cFg, fontSize: 11),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    if (log.subLogs.length > 1)
                      Icon(Icons.chevron_right_rounded,
                          color: context.cMuted, size: 18),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: context.cMuted.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        log.capability.replaceAll('_', ' '),
                        style: TextStyle(
                          color: context.cMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat.yMMMd().add_jm().format(log.createdAt),
                      style: TextStyle(color: context.cMuted, fontSize: 11.5),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _TokenStat(label: 'Prompt', value: log.billablePromptTokens, formatter: tokenFormat),
                    const SizedBox(width: 16),
                    _TokenStat(label: 'Completion', value: log.billableCompletionTokens, formatter: tokenFormat),
                    const SizedBox(width: 16),
                    _TokenStat(
                      label: 'Total',
                      value: log.billableTotalTokens,
                      formatter: tokenFormat,
                      emphasize: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBreakdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Usage Breakdown',
                style: TextStyle(
                  color: sheetContext.cFg,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ...log.subLogs.map((sub) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            sub.model?.name ?? 'Unknown',
                            style: TextStyle(
                              color: sheetContext.cFg,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          NumberFormat.decimalPattern().format(sub.billableTotalTokens),
                          style: TextStyle(
                            color: sheetContext.cMuted,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _TokenStat extends StatelessWidget {
  const _TokenStat({
    required this.label,
    required this.value,
    required this.formatter,
    this.emphasize = false,
  });

  final String label;
  final int value;
  final NumberFormat formatter;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: context.cMuted, fontSize: 10.5),
        ),
        const SizedBox(height: 2),
        Text(
          formatter.format(value),
          style: TextStyle(
            color: emphasize ? AppColors.landingPrimary : context.cFg,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
