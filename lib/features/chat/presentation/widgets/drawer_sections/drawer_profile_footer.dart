import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../app/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/theme_controller.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../auth/bloc/auth_bloc.dart';
import '../../../../settings/presentation/pages/dashboard_page.dart';

class DrawerProfileFooter extends StatelessWidget {
  const DrawerProfileFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Debug logging
        logger.info('🔍 DrawerProfileFooter - AuthState: ${state.runtimeType}');
        
        String displayName = 'Super Admin';
        String displayEmail = 'superadmin@aicolab.com';
        String? profileImageUrl;

        if (state is AuthAuthenticated) {
          // Combine firstName and lastName
          final firstName = state.user.firstName;
          final lastName = state.user.lastName;
          displayName = '$firstName $lastName'.trim();
          if (displayName.isEmpty) {
            displayName = 'User';
          }
          displayEmail = state.user.email;
          profileImageUrl = state.user.profileImageUrl;
          
          logger.info('✅ Authenticated user: $displayName ($displayEmail)');
        } else {
          logger.warning('⚠️ User not authenticated - showing fallback');
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Profile avatar
              Container(
                width: 44,
                height: 44,
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
                          errorBuilder: (context, error, stackTrace) {
                            logger.warning('Failed to load profile image: $error');
                            return Icon(
                              Icons.person_rounded,
                              color: AppColors.landingPrimary.withValues(alpha: 0.8),
                              size: 24,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                color: AppColors.landingPrimary,
                              ),
                            );
                          },
                        )
                      : Icon(
                          Icons.person_rounded,
                          color: AppColors.landingPrimary.withValues(alpha: 0.8),
                          size: 24,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Name and email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        color: context.cFg,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayEmail,
                      style: TextStyle(
                        color: context.cMuted.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Quick light/dark toggle
              ListenableBuilder(
                listenable: sl<ThemeController>(),
                builder: (context, _) {
                  final isDark = sl<ThemeController>().isDark;
                  return IconButton(
                    tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
                    onPressed: () => sl<ThemeController>().toggle(context),
                    icon: Icon(
                      isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: AppColors.landingPrimary.withValues(alpha: 0.9),
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  );
                },
              ),
              const SizedBox(width: 4),

              // More options button
              IconButton(
                onPressed: () => _showProfileOptions(context),
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: context.cMuted.withValues(alpha: 0.7),
                  size: 22,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ListTile(
            //   leading: const Icon(Icons.person_outline_rounded, color: AppColors.darkForeground),
            //   title: const Text('Profile', style: TextStyle(color: AppColors.darkForeground)),
            //   onTap: () {
            //     Navigator.pop(context);
            //     logger.info('Navigate to profile');
            //   },
            // ),
            ListTile(
              leading: Icon(Icons.settings_outlined, color: sheetContext.cFg),
              title: Text('Settings', style: TextStyle(color: sheetContext.cFg)),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                );
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.help_outline_rounded, color: AppColors.darkForeground),
            //   title: const Text('Help & Support', style: TextStyle(color: AppColors.darkForeground)),
            //   onTap: () {
            //     Navigator.pop(context);
            //     logger.info('Navigate to help');
            //   },
            // ),
            // Light / dark mode switch
            // ListenableBuilder(
            //   listenable: sl<ThemeController>(),
            //   builder: (context, _) {
            //     final isDark = sl<ThemeController>().isDark;
                // return SwitchListTile(
                //   secondary: Icon(
                //     isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                //     color: AppColors.darkForeground,
                //   ),
                //   title: const Text('Dark mode',
                //       style: TextStyle(color: AppColors.darkForeground)),
                //   value: isDark,
                //   activeThumbColor: AppColors.landingPrimary,
                //   onChanged: (wantDark) => sl<ThemeController>()
                //       .setMode(wantDark ? ThemeMode.dark : ThemeMode.light),
                // );
            //   },
            // ),
            Divider(color: sheetContext.cBorder, height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(sheetContext);
                logger.info('🚪 Logout button clicked');
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
            ),
          ],
        ),
      ),
    );
  }
}
