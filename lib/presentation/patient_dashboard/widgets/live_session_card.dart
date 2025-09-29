import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ Add this import

import '../../../core/app_export.dart';

class LiveSessionCard extends StatefulWidget {
  final Map<String, dynamic>? liveSessionData;
  final VoidCallback? onViewSession;
  final VoidCallback? onEndSession;

  const LiveSessionCard({
    super.key,
    this.liveSessionData,
    this.onViewSession,
    this.onEndSession,
  });

  @override
  State<LiveSessionCard> createState() => _LiveSessionCardState();
}

class _LiveSessionCardState extends State<LiveSessionCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.liveSessionData != null) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.liveSessionData == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary.withOpacity(0.1), // ✅ Fixed
                      colorScheme.tertiary.withOpacity(0.05), // ✅ Fixed
                    ],
                  ),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3), // ✅ Fixed
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onViewSession?.call();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(colorScheme),
                        SizedBox(height: 2.h),
                        _buildSessionInfo(colorScheme),
                        SizedBox(height: 2.h),
                        _buildProgressIndicator(colorScheme),
                        SizedBox(height: 2.h),
                        _buildActionButtons(colorScheme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon( // ✅ Fixed CustomIconWidget
            Icons.play_circle_filled,
            color: Colors.white,
            size: 20,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Live Session in Progress',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              Text(
                widget.liveSessionData!['therapyType'] as String,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withOpacity(0.7), // ✅ Fixed
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 1.5.w,
                height: 1.5.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 1.w),
              Text(
                'LIVE',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionInfo(ColorScheme colorScheme) {
    final DateTime startTime =
        DateTime.parse(widget.liveSessionData!['startTime'] as String);
    final int duration = widget.liveSessionData!['duration'] as int;
    final String therapistName =
        widget.liveSessionData!['therapistName'] as String;
    final String roomNumber = widget.liveSessionData!['roomNumber'] as String;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2), // ✅ Fixed
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  colorScheme,
                  'Started',
                  '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                  Icons.schedule,
                ),
              ),
              Container(
                width: 1,
                height: 4.h,
                color: colorScheme.outline.withOpacity(0.2), // ✅ Fixed
              ),
              Expanded(
                child: _buildInfoItem(
                  colorScheme,
                  'Duration',
                  '$duration min',
                  Icons.timer,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  colorScheme,
                  'Therapist',
                  therapistName,
                  Icons.person,
                ),
              ),
              Container(
                width: 1,
                height: 4.h,
                color: colorScheme.outline.withOpacity(0.2), // ✅ Fixed
              ),
              Expanded(
                child: _buildInfoItem(
                  colorScheme,
                  'Room',
                  roomNumber,
                  Icons.location_on,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    ColorScheme colorScheme,
    String label,
    String value,
    IconData iconData,
  ) {
    return Column(
      children: [
        Icon( // ✅ Fixed CustomIconWidget
          iconData,
          color: colorScheme.primary,
          size: 16,
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface.withOpacity(0.7), // ✅ Fixed
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(ColorScheme colorScheme) {
    final DateTime startTime =
        DateTime.parse(widget.liveSessionData!['startTime'] as String);
    final int duration = widget.liveSessionData!['duration'] as int;
    final DateTime now = DateTime.now();
    final int elapsedMinutes = now.difference(startTime).inMinutes;
    final double progress = (elapsedMinutes / duration).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Session Progress',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '${elapsedMinutes}/${duration} min',
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
            color: colorScheme.primary.withOpacity(0.1), // ✅ Fixed
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
                    colorScheme.tertiary,
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

  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onViewSession?.call();
            },
            icon: Icon( // ✅ Fixed CustomIconWidget
              Icons.visibility,
              color: colorScheme.primary,
              size: 16,
            ),
            label: Text(
              'View Details',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              side: BorderSide(color: colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onEndSession?.call();
            },
            icon: Icon( // ✅ Fixed CustomIconWidget
              Icons.stop,
              color: Colors.white,
              size: 16,
            ),
            label: Text(
              'End Session',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
