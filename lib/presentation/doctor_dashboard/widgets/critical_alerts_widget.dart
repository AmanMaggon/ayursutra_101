import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CriticalAlertsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> criticalAlerts;
  final VoidCallback? onViewAllAlerts;

  const CriticalAlertsWidget({
    super.key,
    required this.criticalAlerts,
    this.onViewAllAlerts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (criticalAlerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomIconWidget(
                    iconName: 'warning',
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Critical Alerts',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.error,
                        ),
                      ),
                      Text(
                        '${criticalAlerts.length} patients need attention',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (criticalAlerts.length > 2)
                  TextButton(
                    onPressed: onViewAllAlerts,
                    child: Text(
                      'View All',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 2.h),

            // Alert Items
            ...criticalAlerts
                .take(2)
                .map((alert) => _buildAlertItem(context, alert, theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(
      BuildContext context, Map<String, dynamic> alert, ThemeData theme) {
    final alertType = alert['type'] as String? ?? 'general';
    final severity = alert['severity'] as String? ?? 'medium';

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getSeverityColor(severity).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Alert Icon
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: _getAlertTypeColor(alertType).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: _getAlertIcon(alertType),
              size: 18,
              color: _getAlertTypeColor(alertType),
            ),
          ),
          SizedBox(width: 3.w),

          // Alert Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alert['patientName'] as String? ?? 'Unknown Patient',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getSeverityColor(severity),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        severity.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 9.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  alert['description'] as String? ?? 'No description available',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'schedule',
                      size: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      alert['timestamp'] as String? ?? 'Just now',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _handleAlertAction(context, alert),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Review',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAlertIcon(String type) {
    switch (type.toLowerCase()) {
      case 'vital_signs':
        return 'favorite';
      case 'medication':
        return 'medication';
      case 'side_effects':
        return 'report_problem';
      case 'missed_session':
        return 'event_busy';
      case 'lab_results':
        return 'science';
      default:
        return 'notification_important';
    }
  }

  Color _getAlertTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'vital_signs':
        return Colors.red;
      case 'medication':
        return Colors.blue;
      case 'side_effects':
        return Colors.orange;
      case 'missed_session':
        return Colors.purple;
      case 'lab_results':
        return Colors.teal;
      default:
        return AppTheme.lightTheme.colorScheme.error;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
      case 'critical':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow.shade700;
      default:
        return AppTheme.lightTheme.colorScheme.error;
    }
  }

  void _handleAlertAction(BuildContext context, Map<String, dynamic> alert) {
    // Navigate to patient details or show alert details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reviewing alert for ${alert['patientName']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
