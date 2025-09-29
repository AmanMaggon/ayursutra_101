import 'package:flutter/material.dart';

class ProgressStepperWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressStepperWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  static const List<String> _stepLabels = [
    'Personal',
    'ABHA ID',
    'Security',
    'Role',
    'Consent',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress Bar
          Row(
            children: List.generate(totalSteps * 2 - 1, (index) {
              if (index.isEven) {
                // Step indicator
                final stepIndex = index ~/ 2;
                final isCompleted = stepIndex < currentStep;
                final isCurrent = stepIndex == currentStep;

                return Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : isCurrent
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.3),
                    border: Border.all(
                      color: isCompleted || isCurrent
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(
                            Icons.check,
                            size: 16,
                            color: Theme.of(context).colorScheme.onPrimary,
                          )
                        : Text(
                            '${stepIndex + 1}',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isCurrent
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                ),
                          ),
                  ),
                );
              } else {
                // Connection line
                final stepIndex = index ~/ 2;
                final isCompleted = stepIndex < currentStep;

                return Expanded(
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                );
              }
            }),
          ),

          const SizedBox(height: 12),

          // Step Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(totalSteps, (index) {
              final isCompleted = index < currentStep;
              final isCurrent = index == currentStep;

              return Expanded(
                child: Text(
                  _stepLabels[index],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.w400,
                        color: isCompleted || isCurrent
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
