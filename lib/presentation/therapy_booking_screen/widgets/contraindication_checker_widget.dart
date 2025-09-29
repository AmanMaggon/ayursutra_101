import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class ContraindicationCheckerWidget extends StatelessWidget {
  final List<ContraindicationWarning> warnings;
  final VoidCallback? onConsultDoctor;
  final VoidCallback? onDismiss;

  const ContraindicationCheckerWidget({
    super.key,
    required this.warnings,
    this.onConsultDoctor,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'warning',
                  color: theme.colorScheme.error,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Health Considerations',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                if (onDismiss != null) ...[
                  IconButton(
                    onPressed: onDismiss,
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: theme.colorScheme.onErrorContainer
                          .withValues(alpha: 0.7),
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Warnings list
          ...warnings.map((warning) => _buildWarningItem(context, warning)),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onConsultDoctor,
                    icon: CustomIconWidget(
                      iconName: 'medical_services',
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                    label: Text(
                      'Consult Doctor',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(color: theme.colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      _showDetailedWarnings(context);
                    },
                    child: Text(
                      'Learn More',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(
      BuildContext context, ContraindicationWarning warning) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Severity indicator
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: _getSeverityColor(theme, warning.severity),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          // Warning content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  warning.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  warning.description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: theme.colorScheme.onErrorContainer
                        .withValues(alpha: 0.8),
                    height: 1.3,
                  ),
                ),
                if (warning.recommendation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'lightbulb',
                          color: theme.colorScheme.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            warning.recommendation,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(ThemeData theme, WarningSeverity severity) {
    switch (severity) {
      case WarningSeverity.low:
        return Colors.orange;
      case WarningSeverity.medium:
        return theme.colorScheme.error;
      case WarningSeverity.high:
        return Colors.red.shade700;
    }
  }

  void _showDetailedWarnings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetailedWarningsSheet(warnings: warnings),
    );
  }
}

class _DetailedWarningsSheet extends StatelessWidget {
  final List<ContraindicationWarning> warnings;

  const _DetailedWarningsSheet({required this.warnings});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Detailed Health Considerations',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: warnings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final warning = warnings[index];
                return _buildDetailedWarningCard(context, warning);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedWarningCard(
      BuildContext context, ContraindicationWarning warning) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getSeverityColor(theme, warning.severity),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  warning.severity.name.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  warning.title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            warning.detailedDescription,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          if (warning.recommendation.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'medical_services',
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Recommendation',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    warning.recommendation,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getSeverityColor(ThemeData theme, WarningSeverity severity) {
    switch (severity) {
      case WarningSeverity.low:
        return Colors.orange;
      case WarningSeverity.medium:
        return theme.colorScheme.error;
      case WarningSeverity.high:
        return Colors.red.shade700;
    }
  }
}

enum WarningSeverity { low, medium, high }

class ContraindicationWarning {
  final String id;
  final String title;
  final String description;
  final String detailedDescription;
  final String recommendation;
  final WarningSeverity severity;
  final String category;

  ContraindicationWarning({
    required this.id,
    required this.title,
    required this.description,
    required this.detailedDescription,
    required this.recommendation,
    required this.severity,
    required this.category,
  });
}
