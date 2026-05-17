import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class StepProgressIndicator extends StatelessWidget {
  const StepProgressIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  final int totalSteps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (i) {
        final active = i <= currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: active ? AppColors.landingPrimary : AppColors.darkRing,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
