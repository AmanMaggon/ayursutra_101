import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class QuickActionsWidget extends StatelessWidget {
  final VoidCallback? onPrescription;
  final VoidCallback? onProtocols;
  final VoidCallback? onAnalytics;
  final VoidCallback? onPatientSearch;

  const QuickActionsWidget({
    super.key,
    this.onPrescription,
    this.onProtocols,
    this.onAnalytics,
    this.onPatientSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  'E-Prescription',
                  'prescription',
                  theme.colorScheme.primary,
                  onPrescription,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildActionCard(
                  context,
                  'Protocols',
                  'assignment',
                  theme.colorScheme.secondary,
                  onProtocols,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  'Analytics',
                  'analytics',
                  theme.colorScheme.tertiary,
                  onAnalytics,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildActionCard(
                  context,
                  'Search Patient',
                  'search',
                  Colors.teal,
                  onPatientSearch,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String iconName,
    Color color,
    VoidCallback? onTap,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.1),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                size: 24,
                color: color,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
