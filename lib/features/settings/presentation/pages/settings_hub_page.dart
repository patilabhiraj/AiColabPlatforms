import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'account_page.dart';
import 'archived_chats_page.dart';
import 'dashboard_page.dart';
import 'preferences_page.dart';
import 'subscription_page.dart';
import 'usage_page.dart';
import 'wallet_page.dart';

class SettingsHubPage extends StatelessWidget {
  const SettingsHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_SettingsItem>[
      _SettingsItem(
        icon: Icons.dashboard_rounded,
        label: 'Dashboard',
        subtitle: 'Overview of your account & usage',
        builder: (_) => const DashboardPage(),
      ),
      _SettingsItem(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Wallet',
        subtitle: 'Token balance & transactions',
        builder: (_) => const WalletPage(),
      ),
      _SettingsItem(
        icon: Icons.credit_card_rounded,
        label: 'Subscription',
        subtitle: 'Your plan & billing',
        builder: (_) => const SubscriptionPage(),
      ),
      _SettingsItem(
        icon: Icons.bar_chart_rounded,
        label: 'My Usage',
        subtitle: 'Token usage history',
        builder: (_) => const UsagePage(),
      ),
      _SettingsItem(
        icon: Icons.person_outline_rounded,
        label: 'My Account',
        subtitle: 'Profile & personal details',
        builder: (_) => const AccountPage(),
      ),
      _SettingsItem(
        icon: Icons.archive_outlined,
        label: 'Archived Chats',
        subtitle: 'Restore archived conversations',
        builder: (_) => const ArchivedChatsPage(),
      ),
      _SettingsItem(
        icon: Icons.settings_outlined,
        label: 'Preferences',
        subtitle: 'Customize your chat experience',
        builder: (_) => const PreferencesPage(),
      ),
    ];

    return Scaffold(
      backgroundColor: context.cBg,
      appBar: AppBar(
        backgroundColor: context.cBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.cFg),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: context.cFg,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: item.builder),
              ),
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.landingPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: AppColors.landingPrimary, size: 19),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: TextStyle(
                              color: context.cFg,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle,
                            style: TextStyle(color: context.cMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: context.cMuted.withValues(alpha: 0.6), size: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final WidgetBuilder builder;

  _SettingsItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.builder,
  });
}
