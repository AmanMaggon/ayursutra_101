import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ Add missing import

import '../../../core/app_export.dart';

class QuickActionsWidget extends StatelessWidget {
  final VoidCallback? onBookSession;
  final VoidCallback? onEmergencyContact;
  final VoidCallback? onViewProgress;
  final VoidCallback? onReschedule;

  const QuickActionsWidget({
    super.key,
    this.onBookSession,
    this.onEmergencyContact,
    this.onViewProgress,
    this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Actions',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      colorScheme,
                      'Book Session',
                      Icons.event_available, // ✅ Fixed iconName to IconData
                      colorScheme.primary,
                      onBookSession,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: _buildActionButton(
                      colorScheme,
                      'Emergency',
                      Icons.emergency, // ✅ Fixed iconName to IconData
                      colorScheme.error,
                      onEmergencyContact,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      colorScheme,
                      'View Progress',
                      Icons.analytics, // ✅ Fixed iconName to IconData
                      colorScheme.tertiary,
                      onViewProgress,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: _buildActionButton(
                      colorScheme,
                      'Reschedule',
                      Icons.schedule, // ✅ Fixed iconName to IconData
                      Colors.orange,
                      onReschedule,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    ColorScheme colorScheme,
    String label,
    IconData iconData, // ✅ Changed from String to IconData
    Color color,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1), // ✅ Fixed withValues to withOpacity
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.2), // ✅ Fixed withValues to withOpacity
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1), // ✅ Fixed withValues to withOpacity
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon( // ✅ Fixed CustomIconWidget to Icon
                iconData,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
