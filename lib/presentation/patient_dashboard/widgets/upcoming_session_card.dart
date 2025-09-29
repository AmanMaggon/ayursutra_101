import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ Add missing import

import '../../../core/app_export.dart';

class UpcomingSessionCard extends StatelessWidget {
  final Map<String, dynamic> sessionData;
  final VoidCallback? onViewDetails;
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;
  final VoidCallback? onAddToCalendar;

  const UpcomingSessionCard({
    super.key,
    required this.sessionData,
    this.onViewDetails,
    this.onReschedule,
    this.onCancel,
    this.onAddToCalendar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // ✅ Handle empty sessionData - show placeholder
    if (sessionData.isEmpty) {
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
              children: [
                Icon(
                  Icons.schedule,
                  size: 48,
                  color: colorScheme.onSurface.withOpacity(0.3),
                ),
                SizedBox(height: 2.h),
                Text(
                  'No upcoming sessions',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Book a new session to get started',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onViewDetails?.call();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(colorScheme),
                SizedBox(height: 2.h),
                _buildSessionDetails(colorScheme),
                SizedBox(height: 2.h),
                _buildTherapistInfo(colorScheme),
                SizedBox(height: 2.h),
                _buildActionButtons(colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    // ✅ Handle date parsing safely
    final DateTime sessionDate = sessionData['date'] != null 
        ? DateTime.tryParse(sessionData['date'].toString()) ?? DateTime.now().add(Duration(days: 1))
        : DateTime.now().add(Duration(days: 1));
    final String timeSlot = sessionData['timeSlot'] ?? '10:00 AM'; // ✅ Add null safety

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upcoming Session',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                '${sessionDate.day}/${sessionDate.month}/${sessionDate.year}',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                timeSlot,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withOpacity(0.7), // ✅ Fixed withValues
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: _getStatusColor(colorScheme),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            sessionData['status'] ?? 'Confirmed', // ✅ Add null safety
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionDetails(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.05), // ✅ Fixed withValues
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.1), // ✅ Fixed withValues
        ),
      ),
      child: Row(
        children: [
          Icon( // ✅ Fixed CustomIconWidget
            Icons.spa,
            color: colorScheme.primary,
            size: 20,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sessionData['therapyType'] ?? 'Abhyanga Massage', // ✅ Add null safety
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Duration: ${sessionData['duration'] ?? 60} minutes', // ✅ Add null safety
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface.withOpacity(0.7), // ✅ Fixed withValues
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTherapistInfo(ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.2), // ✅ Fixed withValues
              width: 2,
            ),
            color: colorScheme.primary.withOpacity(0.1), // ✅ Add background color as fallback
          ),
          child: ClipOval(
            child: sessionData['therapistImage'] != null
                ? Image.network( // ✅ Fixed CustomImageWidget
                    sessionData['therapistImage'],
                    width: 12.w,
                    height: 12.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        color: colorScheme.primary,
                        size: 6.w,
                      );
                    },
                  )
                : Icon( // ✅ Fallback icon
                    Icons.person,
                    color: colorScheme.primary,
                    size: 6.w,
                  ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sessionData['therapistName'] ?? 'Dr. Sharma', // ✅ Add null safety
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  Icon( // ✅ Fixed CustomIconWidget
                    Icons.location_on,
                    color: colorScheme.onSurface.withOpacity(0.6), // ✅ Fixed withValues
                    size: 14,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Room ${sessionData['roomNumber'] ?? '102'}', // ✅ Add null safety
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurface.withOpacity(0.7), // ✅ Fixed withValues
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: colorScheme.tertiary.withOpacity(0.1), // ✅ Fixed withValues
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon( // ✅ Fixed CustomIconWidget
                Icons.star,
                color: colorScheme.tertiary,
                size: 12,
              ),
              SizedBox(width: 1.w),
              Text(
                (sessionData['therapistRating'] ?? 4.8).toString(), // ✅ Add null safety
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              onReschedule?.call();
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              side: BorderSide(color: colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Reschedule',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              onViewDetails?.call();
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'View Details',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ColorScheme colorScheme) {
    final status = sessionData['status'] ?? 'confirmed'; // ✅ Add null safety
    switch (status.toLowerCase()) {
      case 'confirmed':
        return colorScheme.primary;
      case 'pending':
        return colorScheme.tertiary;
      case 'rescheduled':
        return Colors.orange;
      default:
        return colorScheme.onSurface.withOpacity(0.6); // ✅ Fixed withValues
    }
  }
}
