import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ Add missing import

import '../../../core/app_export.dart';

class ProgressCard extends StatelessWidget {
  final Map<String, dynamic> progressData;
  final VoidCallback? onViewProgress;

  const ProgressCard({
    super.key,
    required this.progressData,
    this.onViewProgress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final int completedSessions = progressData['completedSessions'] ?? 0; // ✅ Add null safety
    final int totalSessions = progressData['totalSessions'] ?? 1; // ✅ Add null safety
    final double progressPercentage = totalSessions > 0 ? completedSessions / totalSessions : 0; // ✅ Prevent division by zero

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onViewProgress,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(colorScheme),
                SizedBox(height: 2.h),
                _buildProgressBar(colorScheme, progressPercentage),
                SizedBox(height: 2.h),
                _buildProgressStats(
                    colorScheme, completedSessions, totalSessions),
                SizedBox(height: 2.h),
                _buildPhaseInfo(colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Treatment Progress',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              progressData['packageName'] ?? 'Treatment Package', // ✅ Add null safety
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface.withOpacity(0.7), // ✅ Fix withValues
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1), // ✅ Fix withValues
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon( // ✅ Fix CustomIconWidget
            Icons.trending_up,
            color: colorScheme.primary,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(ColorScheme colorScheme, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overall Progress',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          height: 1.h,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1), // ✅ Fix withValues
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.8), // ✅ Fix withValues
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStats(
      ColorScheme colorScheme, int completed, int total) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            colorScheme,
            'Completed',
            completed.toString(),
            Icons.check_circle_outline,
            colorScheme.primary,
          ),
        ),
        Container(
          width: 1,
          height: 6.h,
          color: colorScheme.outline.withOpacity(0.2), // ✅ Fix withValues
        ),
        Expanded(
          child: _buildStatItem(
            colorScheme,
            'Remaining',
            (total - completed).toString(),
            Icons.schedule,
            colorScheme.tertiary,
          ),
        ),
        Container(
          width: 1,
          height: 6.h,
          color: colorScheme.outline.withOpacity(0.2), // ✅ Fix withValues
        ),
        Expanded(
          child: _buildStatItem(
            colorScheme,
            'Total',
            total.toString(),
            Icons.spa,
            colorScheme.onSurface.withOpacity(0.6), // ✅ Fix withValues
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    ColorScheme colorScheme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Column(
        children: [
          Icon( // ✅ Fix CustomIconWidget
            icon,
            color: color,
            size: 20,
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface.withOpacity(0.7), // ✅ Fix withValues
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseInfo(ColorScheme colorScheme) {
    final String currentPhase = progressData['currentPhase'] ?? 'Planning Phase'; // ✅ Add null safety
    final List<String> phases = [
      'Purva Karma',
      'Pradhana Karma',
      'Paschat Karma'
    ];
    final int currentPhaseIndex = phases.indexOf(currentPhase);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.tertiary.withOpacity(0.05), // ✅ Fix withValues
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.tertiary.withOpacity(0.1), // ✅ Fix withValues
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Phase',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: phases.asMap().entries.map((entry) {
              final index = entry.key;
              final phase = entry.value;
              final isActive = index == currentPhaseIndex;
              final isCompleted = index < currentPhaseIndex;

              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 3.w,
                      height: 3.w,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? colorScheme.primary
                            : isActive
                                ? colorScheme.tertiary
                                : colorScheme.outline.withOpacity(0.3), // ✅ Fix withValues
                        shape: BoxShape.circle,
                      ),
                      child: isCompleted
                          ? Icon( // ✅ Fix CustomIconWidget
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            )
                          : null,
                    ),
                    if (index < phases.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: EdgeInsets.symmetric(horizontal: 1.w),
                          color: isCompleted
                              ? colorScheme.primary
                              : colorScheme.outline.withOpacity(0.3), // ✅ Fix withValues
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 1.h),
          Text(
            currentPhase,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}
