import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../bloc/account/account_bloc.dart';
import '../widgets/settings_scaffold.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccountBloc>()..add(AccountLoadRequested()),
      child: const _AccountView(),
    );
  }
}

class _AccountView extends StatefulWidget {
  const _AccountView();

  @override
  State<_AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<_AccountView> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _pickedImagePath;
  bool _initialized = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (file != null) {
      setState(() => _pickedImagePath = file.path);
    }
  }

  void _save(BuildContext context) {
    context.read<AccountBloc>().add(AccountUpdateRequested(
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          phoneNumber: _phoneCtrl.text.trim(),
          profileImagePath: _pickedImagePath,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'My Account',
      child: BlocConsumer<AccountBloc, AccountState>(
        listener: (context, state) {
          if (state is AccountLoaded) {
            if (!_initialized) {
              _initialized = true;
              _firstNameCtrl.text = state.account.firstName;
              _lastNameCtrl.text = state.account.lastName;
              _phoneCtrl.text = state.account.phoneNumber ?? '';
            }
            if (state.saved) {
              setState(() => _pickedImagePath = null);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated!')),
              );
            }
            if (state.saveError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.saveError!)),
              );
            }
            if (state.deleteError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.deleteError!)),
              );
            }
          }
          if (state is AccountDeleted) {
            context.read<AuthBloc>().add(AuthLogoutRequested());
          }
        },
        builder: (context, state) {
          if (state is AccountLoading || state is AccountInitial) {
            return const SettingsStateView.loading();
          }
          if (state is AccountError) {
            return SettingsStateView.error(
              message: state.message,
              onRetry: () =>
                  context.read<AccountBloc>().add(AccountLoadRequested()),
            );
          }
          if (state is AccountDeleted) {
            return const SettingsStateView.loading();
          }

          final loaded = state as AccountLoaded;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Manage your profile and settings',
                style: TextStyle(color: context.cMuted, fontSize: 13.5),
              ),
              const SizedBox(height: 16),

              SettingsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SettingsSectionHeader(
                      title: 'Personal Information',
                      subtitle: 'Update your name, photo and contact details',
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: context.cBorder, width: 2),
                                  image: _pickedImagePath != null
                                      ? DecorationImage(
                                          image: FileImage(File(_pickedImagePath!)),
                                          fit: BoxFit.cover,
                                        )
                                      : (loaded.account.profileImage != null
                                          ? DecorationImage(
                                              image: NetworkImage(loaded.account.profileImage!),
                                              fit: BoxFit.cover,
                                            )
                                          : null),
                                ),
                                child: (_pickedImagePath == null &&
                                        loaded.account.profileImage == null)
                                    ? Center(
                                        child: Text(
                                          '${loaded.account.firstName.isNotEmpty ? loaded.account.firstName[0] : ''}${loaded.account.lastName.isNotEmpty ? loaded.account.lastName[0] : ''}',
                                          style: const TextStyle(
                                            color: AppColors.landingPrimary,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.landingPrimary,
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded,
                                      size: 13, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Profile photo',
                                style: TextStyle(
                                  color: context.cFg,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap the avatar to upload a new photo. Max 10MB.',
                                style: TextStyle(color: context.cMuted, fontSize: 11.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _FieldLabel(
                            label: 'First name',
                            child: TextField(
                              controller: _firstNameCtrl,
                              style: TextStyle(color: context.cFg),
                              decoration: _inputDecoration(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FieldLabel(
                            label: 'Last name',
                            child: TextField(
                              controller: _lastNameCtrl,
                              style: TextStyle(color: context.cFg),
                              decoration: _inputDecoration(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _FieldLabel(
                      label: 'Email',
                      child: TextField(
                        controller: TextEditingController(text: loaded.account.email),
                        enabled: false,
                        style: TextStyle(color: context.cMuted),
                        decoration: _inputDecoration(context),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FieldLabel(
                      label: 'Phone number',
                      child: TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: context.cFg),
                        decoration: _inputDecoration(context, hint: '+1234567890'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: loaded.saving ? null : () => _save(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.landingPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: loaded.saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_rounded, size: 18),
                        label: const Text('Save changes'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              SettingsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SettingsSectionHeader(title: 'Appearance'),
                    OutlinedButton.icon(
                      onPressed: () {}, // theme toggle lives in the drawer footer
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.cFg,
                        side: BorderSide(color: context.cBorder),
                      ),
                      icon: Icon(context.isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded),
                      label: Text('Switch to ${context.isDark ? 'light' : 'dark'} mode'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: context.cCard.withValues(alpha: context.isDark ? 0.55 : 1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.cError.withValues(alpha: 0.3)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Danger Zone',
                      style: TextStyle(
                        color: context.cError,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Permanently delete your account and all associated data',
                      style: TextStyle(color: context.cMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: loaded.deleting
                            ? null
                            : () => _confirmDeleteStep1(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.cError,
                          side: BorderSide(color: context.cError.withValues(alpha: 0.5)),
                        ),
                        icon: loaded.deleting
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: context.cError,
                                ),
                              )
                            : const Icon(Icons.delete_outline_rounded, size: 18),
                        label: const Text('Delete Account'),
                      ),
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

  InputDecoration _inputDecoration(BuildContext context, {String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: context.cMuted.withValues(alpha: 0.6)),
      filled: true,
      fillColor: context.cMuted.withValues(alpha: 0.06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: context.cBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: context.cBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.landingPrimary),
      ),
    );
  }

  void _confirmDeleteStep1(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.cCard,
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: dialogContext.cError, size: 20),
            const SizedBox(width: 8),
            Text('Delete your account?', style: TextStyle(color: dialogContext.cError, fontSize: 16)),
          ],
        ),
        content: Text(
          'This action is permanent and cannot be undone. The following will be deleted:\n\n'
          '• All your chats and conversation history\n'
          '• All your folders and organization\n'
          '• Your profile and personal data',
          style: TextStyle(color: dialogContext.cMuted, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _confirmDeleteStep2(context);
            },
            child: Text('Continue', style: TextStyle(color: dialogContext.cError)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteStep2(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.cCard,
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: dialogContext.cError, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Are you absolutely sure?',
                  style: TextStyle(color: dialogContext.cError, fontSize: 16)),
            ),
          ],
        ),
        content: Text(
          'By deleting your account:\n\n'
          '• Any active subscription will be cancelled immediately\n'
          '• You will lose access to all premium features\n'
          '• Remaining tokens and wallet balance will be forfeited\n\n'
          'This cannot be reversed.',
          style: TextStyle(color: dialogContext.cMuted, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AccountBloc>().add(AccountDeleteRequested());
            },
            child: Text('Delete my account', style: TextStyle(color: dialogContext.cError)),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.cFg,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
