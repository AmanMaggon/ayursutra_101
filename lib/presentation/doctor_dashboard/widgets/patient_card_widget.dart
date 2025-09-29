import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PatientCardWidget extends StatelessWidget {
  final Map<String, dynamic> patient;
  final VoidCallback? onTap;
  final VoidCallback? onViewProgress;
  final VoidCallback? onSendMessage;
  final VoidCallback? onAdjustProtocol;
  final VoidCallback? onViewHistory;
  final VoidCallback? onLabResults;
  final VoidCallback? onEmergencyContact;

  const PatientCardWidget({
    super.key,
    required this.patient,
    this.onTap,
    this.onViewProgress,
    this.onSendMessage,
    this.onAdjustProtocol,
    this.onViewHistory,
    this.onLabResults,
    this.onEmergencyContact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priority = patient['priority'] as String? ?? 'normal';
    final currentPhase = patient['currentPhase'] as String? ?? 'Assessment';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(patient['id']),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onViewProgress?.call(),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: Colors.white,
              icon: Icons.trending_up,
              label: 'Progress',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => onSendMessage?.call(),
              backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
              foregroundColor: Colors.white,
              icon: Icons.message,
              label: 'Message',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => onAdjustProtocol?.call(),
              backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              foregroundColor: Colors.white,
              icon: Icons.tune,
              label: 'Protocol',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          onLongPress: () => _showContextMenu(context),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getPriorityColor(priority).withValues(alpha: 0.3),
                width: priority == 'critical' ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  // Patient Photo
                  Stack(
                    children: [
                      Container(
                        width: 15.w,
                        height: 15.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getPriorityColor(priority),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: CustomImageWidget(
                            imageUrl: patient['photo'] as String? ??
                                'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=150&h=150&fit=crop&crop=face',
                            width: 15.w,
                            height: 15.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (priority == 'critical')
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 4.w,
                            height: 4.w,
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.error,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.surface,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 3.w),

                  // Patient Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                patient['name'] as String? ?? 'Unknown Patient',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildPriorityBadge(priority, theme),
                          ],
                        ),
                        SizedBox(height: 0.5.h),

                        // Current Phase
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getPhaseColor(currentPhase)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            currentPhase,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getPhaseColor(currentPhase),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 1.h),

                        // Patient Info Row
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'person',
                              size: 14,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '${patient['age'] ?? 'N/A'} yrs • ${patient['gender'] ?? 'N/A'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            const Spacer(),
                            CustomIconWidget(
                              iconName: 'schedule',
                              size: 14,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              patient['nextSession'] as String? ?? 'No session',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),

                        if (patient['condition'] != null) ...[
                          SizedBox(height: 0.5.h),
                          Text(
                            'Condition: ${patient['condition']}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Action Button
                  CustomIconWidget(
                    iconName: 'chevron_right',
                    size: 20,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority, ThemeData theme) {
    final color = _getPriorityColor(priority);
    final text = priority == 'critical'
        ? 'URGENT'
        : priority == 'attention'
            ? 'ATTENTION'
            : '';

    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'critical':
        return AppTheme.lightTheme.colorScheme.error;
      case 'attention':
        return AppTheme.lightTheme.colorScheme.tertiary;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  Color _getPhaseColor(String phase) {
    switch (phase.toLowerCase()) {
      case 'assessment':
        return Colors.blue;
      case 'treatment':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'recovery':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'maintenance':
        return AppTheme.lightTheme.colorScheme.secondary;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                margin: EdgeInsets.only(top: 2.h),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 2.h),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'history',
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Full History'),
                onTap: () {
                  Navigator.pop(context);
                  onViewHistory?.call();
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'science',
                  size: 24,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: const Text('Lab Results'),
                onTap: () {
                  Navigator.pop(context);
                  onLabResults?.call();
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'emergency',
                  size: 24,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: const Text('Emergency Contact'),
                onTap: () {
                  Navigator.pop(context);
                  onEmergencyContact?.call();
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
