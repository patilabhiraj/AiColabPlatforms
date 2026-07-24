import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../pages/account_page.dart';
import '../pages/archived_chats_page.dart';
import '../pages/preferences_page.dart';
import '../pages/subscription_page.dart';
import '../pages/usage_page.dart';
import '../pages/wallet_page.dart';

/// Side menu for the Settings area (opened from the Dashboard's hamburger
/// icon): profile header up top, then Wallet / Subscription / My Usage /
/// My Account / Archived Chats / Preferences below.
class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_DrawerItem>[
      _DrawerItem(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Wallet',
        subtitle: 'Token balance & transactions',
        accent: const Color(0xFFEAB308),
        builder: (_) => const WalletPage(),
      ),
      _DrawerItem(
        icon: Icons.credit_card_rounded,
        label: 'Subscription',
        subtitle: 'Your plan & billing',
        accent: const Color(0xFFA855F7),
        builder: (_) => const SubscriptionPage(),
      ),
      _DrawerItem(
        icon: Icons.bar_chart_rounded,
        label: 'My Usage',
        subtitle: 'Token usage history',
        accent: const Color(0xFF6366F1),
        builder: (_) => const UsagePage(),
      ),
      _DrawerItem(
        icon: Icons.person_outline_rounded,
        label: 'My Account',
        subtitle: 'Profile & personal details',
        accent: const Color(0xFF34D399),
        builder: (_) => const AccountPage(),
      ),
      _DrawerItem(
        icon: Icons.archive_outlined,
        label: 'Archived Chats',
        subtitle: 'Restore archived conversations',
        accent: const Color(0xFF38BDF8),
        builder: (_) => const ArchivedChatsPage(),
      ),
      _DrawerItem(
        icon: Icons.tune_rounded,
        label: 'Preferences',
        subtitle: 'Customize your chat experience',
        accent: const Color(0xFFF472B6),
        builder: (_) => const PreferencesPage(),
      ),
    ];

    return Drawer(
      backgroundColor: context.cSidebar,
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: Column(
          children: [
            const _DrawerProfileHeader(),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _DrawerTile(item: item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerProfileHeader extends StatelessWidget {
  const _DrawerProfileHeader();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String displayName = 'User';
        String displayEmail = '';
        String? profileImageUrl;

        if (state is AuthAuthenticated) {
          displayName = '${state.user.firstName} ${state.user.lastName}'.trim();
          if (displayName.isEmpty) displayName = 'User';
          displayEmail = state.user.email;
          profileImageUrl = state.user.profileImageUrl;
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.landingPrimary.withValues(alpha: 0.3),
                      AppColors.landingPrimary.withValues(alpha: 0.15),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.landingPrimary.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: profileImageUrl != null && profileImageUrl.isNotEmpty
                      ? Image.network(
                          profileImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person_rounded,
                            color: AppColors.landingPrimary.withValues(alpha: 0.8),
                            size: 26,
                          ),
                        )
                      : Icon(
                          Icons.person_rounded,
                          color: AppColors.landingPrimary.withValues(alpha: 0.8),
                          size: 26,
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        color: context.cFg,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (displayEmail.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        displayEmail,
                        style: TextStyle(
                          color: context.cMuted.withValues(alpha: 0.75),
                          fontSize: 12.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DrawerItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color accent;
  final WidgetBuilder builder;

  _DrawerItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.accent,
    required this.builder,
  });
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({required this.item});

  final _DrawerItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: item.builder),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: item.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(item.icon, color: item.accent, size: 19),
              ),
              const SizedBox(width: 13),
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
                    const SizedBox(height: 1),
                    Text(
                      item.subtitle,
                      style: TextStyle(color: context.cMuted, fontSize: 11.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.cMuted.withValues(alpha: 0.5),
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
