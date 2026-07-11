import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../app/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../bloc/wallet/wallet_bloc.dart';
import '../../domain/entities/wallet_entity.dart';
import '../widgets/settings_scaffold.dart';
import '../widgets/token_progress_bar.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WalletBloc>()..add(WalletLoadRequested()),
      child: const _WalletView(),
    );
  }
}

class _WalletView extends StatelessWidget {
  const _WalletView();

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Wallet',
      child: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading || state is WalletInitial) {
            return const SettingsStateView.loading();
          }
          if (state is WalletError) {
            return SettingsStateView.error(
              message: state.message,
              onRetry: () =>
                  context.read<WalletBloc>().add(WalletLoadRequested()),
            );
          }

          final loaded = state as WalletLoaded;
          final wallet = loaded.wallet;
          final tokenFormat = NumberFormat.decimalPattern();

          return RefreshIndicator(
            color: AppColors.landingPrimary,
            onRefresh: () async {
              context.read<WalletBloc>().add(WalletLoadRequested());
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Track your token balance and usage',
                  style: TextStyle(color: context.cMuted, fontSize: 13.5),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        label: 'Tokens Remaining',
                        value: tokenFormat.format(wallet.tokensRemaining),
                        icon: Icons.savings_rounded,
                        accent: const Color(0xFF34D399),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        label: 'Tokens Used',
                        value: tokenFormat.format(wallet.tokensUsed),
                        icon: Icons.trending_up_rounded,
                        accent: const Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SettingsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SettingsSectionHeader(
                        title: 'Usage Progress',
                        subtitle: 'Period: '
                            '${wallet.currentPeriodStart != null ? DateFormat.yMMMd().format(wallet.currentPeriodStart!) : 'N/A'}'
                            ' — '
                            '${wallet.currentPeriodEnd != null ? DateFormat.yMMMd().format(wallet.currentPeriodEnd!) : 'N/A'}',
                      ),
                      TokenProgressBar(
                        tokensUsed: wallet.tokensUsed,
                        totalTokens: wallet.totalTokens,
                        usagePercent: wallet.usagePercent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const SettingsSectionHeader(
                  title: 'Transactions',
                  subtitle: 'History of your token deductions, recharges, and refunds',
                ),
                if (loaded.transactions.isEmpty && !loaded.transactionsLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No transactions yet',
                        style: TextStyle(color: context.cMuted, fontSize: 13),
                      ),
                    ),
                  )
                else ...[
                  ...loaded.transactions.map(
                    (tx) => _TransactionTile(transaction: tx),
                  ),
                  if (loaded.transactionsLoading)
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
                      child: _Pagination(
                        page: loaded.page,
                        totalPages: loaded.totalPages,
                        onChanged: (page) => context
                            .read<WalletBloc>()
                            .add(WalletTransactionsPageRequested(page: page)),
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});
  final WalletTransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final color = isCredit ? const Color(0xFF10B981) : const Color(0xFFF43F5E);
    final sign = isCredit ? '+' : '-';
    final tokenFormat = NumberFormat.decimalPattern();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showDetails(context),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.cCard.withValues(alpha: context.isDark ? 0.5 : 1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.cBorder.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    transaction.type.replaceAll('_', ' '),
                    style: TextStyle(
                      color: color,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    DateFormat.yMMMd().add_jm().format(transaction.createdAt),
                    style: TextStyle(color: context.cMuted, fontSize: 12.5),
                  ),
                ),
                Text(
                  '$sign${tokenFormat.format(transaction.amount.abs())}',
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
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
                'Transaction Details',
                style: TextStyle(
                  color: sheetContext.cFg,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _DetailRow(label: 'Type', value: transaction.type.replaceAll('_', ' ')),
              _DetailRow(
                label: 'Amount',
                value: '${transaction.isCredit ? '+' : '-'}${transaction.amount.abs()}',
              ),
              _DetailRow(label: 'Reference ID', value: transaction.referenceId ?? 'N/A'),
              _DetailRow(
                label: 'Date',
                value: DateFormat.yMMMd().add_jm().format(transaction.createdAt),
              ),
              if (transaction.meta != null && transaction.meta!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Metadata',
                  style: TextStyle(
                    color: sheetContext.cMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: sheetContext.cMuted.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    transaction.meta.toString(),
                    style: TextStyle(
                      color: sheetContext.cMuted,
                      fontSize: 11.5,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: context.cMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: context.cFg, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.page,
    required this.totalPages,
    required this.onChanged,
  });

  final int page;
  final int totalPages;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: page > 1 ? () => onChanged(page - 1) : null,
          icon: const Icon(Icons.chevron_left_rounded),
          color: context.cFg,
        ),
        Text(
          'Page $page of $totalPages',
          style: TextStyle(color: context.cMuted, fontSize: 12.5),
        ),
        IconButton(
          onPressed: page < totalPages ? () => onChanged(page + 1) : null,
          icon: const Icon(Icons.chevron_right_rounded),
          color: context.cFg,
        ),
      ],
    );
  }
}
