import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../app/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../bloc/subscription/subscription_bloc.dart';
import '../../domain/entities/subscription_entity.dart';
import '../widgets/settings_scaffold.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SubscriptionBloc>()..add(SubscriptionLoadRequested()),
      child: const _SubscriptionView(),
    );
  }
}

class _SubscriptionView extends StatelessWidget {
  const _SubscriptionView();

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Subscription',
      child: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionLoaded && state.cancelError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.cancelError!)),
            );
          }

          // ── Payment Success ───────────────────────────────────────────────
          if (state is PaymentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎉 Payment Successful! Order ID: ${state.orderId}'),
                backgroundColor: const Color(0xFF10B981),
                duration: const Duration(seconds: 4),
              ),
            );
          }

          // ── Payment Failure ───────────────────────────────────────────────
          if (state is PaymentFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ ${state.message}'),
                backgroundColor: context.cError,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SubscriptionLoading || state is SubscriptionInitial) {
            return const SettingsStateView.loading();
          }
          if (state is SubscriptionError) {
            return SettingsStateView.error(
              message: state.message,
              onRetry: () => context
                  .read<SubscriptionBloc>()
                  .add(SubscriptionLoadRequested()),
            );
          }

          // If payment flow state is active, keep displaying current loaded plans
          SubscriptionLoaded? loaded;
          if (state is SubscriptionLoaded) {
            loaded = state;
          }

          if (loaded == null) {
            return const SettingsStateView.loading();
          }

          final subscription = loaded.summary.subscription;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Manage your plan and billing',
                style: TextStyle(color: context.cMuted, fontSize: 13.5),
              ),
              const SizedBox(height: 16),

              if (subscription != null)
                _CurrentPlanCard(
                  subscription: subscription,
                  cancelling: loaded.cancelling,
                  onCancel: () => _confirmCancel(context),
                )
              else
                SettingsCard(
                  child: Text(
                    'No active plans',
                    style: TextStyle(color: context.cMuted, fontSize: 13),
                  ),
                ),
              const SizedBox(height: 20),

              const SettingsSectionHeader(
                title: 'Available Plans',
                subtitle: 'Choose the plan that works for you',
              ),
              ...loaded.plans.map((plan) => _PlanTile(
                    plan: plan,
                    isCurrent: subscription?.planId == plan.id,
                    isFreeTaken: plan.monthlyPrice == 0 &&
                        loaded!.summary.freePlanTaken &&
                        subscription?.planId != plan.id,
                    isPurchasing: loaded!.paymentInitiating &&
                        loaded.purchasingPlanId == plan.id,
                  )),
            ],
          );
        },
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.cCard,
        title: Text('Cancel subscription?', style: TextStyle(color: dialogContext.cFg)),
        content: Text(
          'You will lose access to your current plan benefits.',
          style: TextStyle(color: dialogContext.cMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Keep plan'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<SubscriptionBloc>().add(SubscriptionCancelRequested());
            },
            child: Text('Cancel plan', style: TextStyle(color: dialogContext.cError)),
          ),
        ],
      ),
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({
    required this.subscription,
    required this.cancelling,
    required this.onCancel,
  });

  final SubscriptionEntity subscription;
  final bool cancelling;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final isActive = subscription.status == 'ACTIVE';
    return SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${subscription.plan?.name ?? 'Unknown'} Plan',
                      style: TextStyle(
                        color: context.cFg,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${subscription.billingCycle} billing',
                      style: TextStyle(color: context.cMuted, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF10B981).withValues(alpha: 0.12)
                      : context.cMuted.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  subscription.status,
                  style: TextStyle(
                    color: isActive ? const Color(0xFF10B981) : context.cMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (subscription.expiresAt != null) ...[
            const SizedBox(height: 10),
            Text(
              'Expires: ${DateFormat.yMMMd().format(subscription.expiresAt!)}',
              style: TextStyle(color: context.cMuted, fontSize: 12.5),
            ),
          ],
          if (isActive) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: cancelling ? null : onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.cError,
                  side: BorderSide(color: context.cError.withValues(alpha: 0.4)),
                ),
                child: cancelling
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Cancel subscription'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.plan,
    required this.isCurrent,
    required this.isFreeTaken,
    this.isPurchasing = false,
  });

  final PlanEntity plan;
  final bool isCurrent;
  final bool isFreeTaken;
  final bool isPurchasing;

  @override
  Widget build(BuildContext context) {
    final isFree = plan.monthlyPrice == 0;
    final maxModels = plan.features?['maxModels'];
    final hasAttachments = plan.features?['attachments'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: SettingsCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: TextStyle(
                      color: context.cFg,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  isFree ? 'Free' : '₹${plan.monthlyPrice}/mo',
                  style: const TextStyle(
                    color: AppColors.landingPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '🎯 ${(plan.tokenLimit / 1000).toStringAsFixed(0)}k tokens / month',
              style: TextStyle(color: context.cMuted, fontSize: 13),
            ),
            if (maxModels != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '🤖 ${maxModels == -1 ? 'Unlimited' : maxModels} model${maxModels != 1 ? 's' : ''}',
                  style: TextStyle(color: context.cMuted, fontSize: 13),
                ),
              ),
            if (hasAttachments)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '📎 File attachments',
                  style: TextStyle(color: context.cMuted, fontSize: 13),
                ),
              ),
            const SizedBox(height: 12),
            if (isCurrent)
              const _Badge(label: 'Current plan', color: AppColors.landingPrimary)
            else if (isFreeTaken)
              _Badge(label: 'Already taken', color: context.cMuted)
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isPurchasing
                      ? null
                      : () {
                          // BLoC ला plan purchase करण्यासाठी event पाठवतो
                          context.read<SubscriptionBloc>().add(
                                SubscriptionPurchaseRequested(plan.id),
                              );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.landingPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isPurchasing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isFree ? 'Start Free' : 'Subscribe with Cashfree',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w700),
      ),
    );
  }
}

