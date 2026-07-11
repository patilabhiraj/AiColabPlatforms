import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../app/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../bloc/dashboard/dashboard_bloc.dart';
import '../widgets/settings_scaffold.dart';
import '../widgets/token_progress_bar.dart';
import '../widgets/usage_line_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DashboardBloc>()..add(DashboardLoadRequested()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final firstName =
        authState is AuthAuthenticated ? authState.user.firstName.trim() : '';

    return SettingsScaffold(
      title: 'Dashboard',
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const SettingsStateView.loading();
          }
          if (state is DashboardError) {
            return SettingsStateView.error(
              message: state.message,
              onRetry: () => context
                  .read<DashboardBloc>()
                  .add(DashboardLoadRequested()),
            );
          }

          final summary = (state as DashboardLoaded).summary;
          final wallet = summary.wallet;
          final total = wallet?.totalTokens ?? 0;
          final usagePercent = wallet?.usagePercent ?? 0;
          final tokenFormat = NumberFormat.decimalPattern();

          return RefreshIndicator(
            color: AppColors.landingPrimary,
            onRefresh: () async {
              context.read<DashboardBloc>().add(DashboardLoadRequested());
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  firstName.isNotEmpty
                      ? 'Welcome back, $firstName'
                      : 'Welcome back',
                  style: TextStyle(
                    color: context.cFg,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Here's your account overview",
                  style: TextStyle(color: context.cMuted, fontSize: 13.5),
                ),
                const SizedBox(height: 20),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    StatTile(
                      label: 'Tokens Remaining',
                      value: tokenFormat.format(wallet?.tokensRemaining ?? 0),
                      icon: Icons.savings_rounded,
                      accent: const Color(0xFF34D399),
                    ),
                    StatTile(
                      label: 'Tokens Used',
                      value: tokenFormat.format(wallet?.tokensUsed ?? 0),
                      icon: Icons.trending_up_rounded,
                      accent: const Color(0xFF6366F1),
                    ),
                    StatTile(
                      label: 'Current Plan',
                      value: summary.subscription?.plan?.name ?? 'None',
                      icon: Icons.credit_card_rounded,
                      accent: const Color(0xFFA855F7),
                    ),
                    StatTile(
                      label: 'Wallet Balance',
                      value: '${usagePercent.toStringAsFixed(1)}% used',
                      icon: Icons.account_balance_wallet_rounded,
                      accent: const Color(0xFFEAB308),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (wallet != null)
                  SettingsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SettingsSectionHeader(title: 'Token Usage'),
                        TokenProgressBar(
                          tokensUsed: wallet.tokensUsed,
                          totalTokens: total,
                          usagePercent: usagePercent,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                SettingsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SettingsSectionHeader(
                        title: 'Usage by model',
                        subtitle: wallet?.currentPeriodStart != null
                            ? 'Total tokens per day by model since your current plan renewed (UTC).'
                            : 'Total tokens per day by model — last ${summary.chartDays} days (UTC).',
                      ),
                      UsageLineChart(
                        rows: summary.dailyByModel,
                        days: summary.chartDays,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
