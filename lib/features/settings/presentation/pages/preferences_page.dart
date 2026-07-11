import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../bloc/preferences/preferences_bloc.dart';
import '../widgets/settings_scaffold.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PreferencesBloc>()..add(PreferencesLoadRequested()),
      child: const _PreferencesView(),
    );
  }
}

class _PreferencesView extends StatelessWidget {
  const _PreferencesView();

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Preferences',
      child: BlocConsumer<PreferencesBloc, PreferencesState>(
        listener: (context, state) {
          if (state is PreferencesLoaded && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          if (state is PreferencesLoading || state is PreferencesInitial) {
            return const SettingsStateView.loading();
          }
          if (state is PreferencesError) {
            return SettingsStateView.error(
              message: state.message,
              onRetry: () => context
                  .read<PreferencesBloc>()
                  .add(PreferencesLoadRequested()),
            );
          }

          final loaded = state as PreferencesLoaded;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Customize your chat experience and AI behaviour',
                style: TextStyle(color: context.cMuted, fontSize: 13.5),
              ),
              const SizedBox(height: 16),
              SettingsCard(
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded,
                        color: AppColors.landingPrimary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Suggested Follow-up Questions',
                            style: TextStyle(
                              color: context.cFg,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Automatically generate 4 context-aware questions at the end of each AI response.',
                            style: TextStyle(color: context.cMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: loaded.enableFollowUpQuestions,
                      activeThumbColor: AppColors.landingPrimary,
                      onChanged: loaded.updating
                          ? null
                          : (value) => context
                              .read<PreferencesBloc>()
                              .add(PreferencesFollowUpToggled(value)),
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
