import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class EmergencyAlertBannerWidget extends StatefulWidget {
  const EmergencyAlertBannerWidget({super.key});

  @override
  State<EmergencyAlertBannerWidget> createState() =>
      _EmergencyAlertBannerWidgetState();
}

class _EmergencyAlertBannerWidgetState extends State<EmergencyAlertBannerWidget>
    with SingleTickerProviderStateMixin {
  bool _hasEmergencyAlert =
      false; // This would be determined by checking for emergency notifications
  String _emergencyMessage = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializePulseAnimation();
    _checkForEmergencyAlerts();
  }

  void _initializePulseAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (_hasEmergencyAlert) {
      _pulseController.repeat(reverse: true);
    }
  }

  void _checkForEmergencyAlerts() {
    // In a real implementation, this would check for emergency notifications
    // For demo purposes, we'll simulate an emergency alert
    setState(() {
      _hasEmergencyAlert = false; // Set to true to show emergency banner
      _emergencyMessage =
          'Emergency: Please contact your healthcare provider immediately regarding your recent test results.';
    });

    if (_hasEmergencyAlert) {
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
    if (!_hasEmergencyAlert) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.all(4.w),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.shade800,
                  Colors.red.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withAlpha(77),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning,
                        color: Colors.red.shade800,
                        size: 6.w,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'EMERGENCY ALERT',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Container(
                                width: 2.w,
                                height: 2.w,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale:
                                          1.0 + (_pulseController.value * 0.3),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withAlpha(204),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            _emergencyMessage,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withAlpha(242),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleEmergencyAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red.shade800,
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone, size: 18),
                            SizedBox(width: 2.w),
                            Text(
                              'Call Now',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _viewEmergencyDetails,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'View Details',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    IconButton(
                      onPressed: _dismissEmergencyAlert,
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleEmergencyAction() {
    // Implement emergency calling functionality
    // This could open the phone dialer or initiate an emergency call
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Emergency Contact',
          style:
              GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Connecting you to emergency healthcare support...',
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  void _viewEmergencyDetails() {
    // Navigate to detailed emergency information
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade50,
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade800),
            SizedBox(width: 2.w),
            Text(
              'Emergency Details',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade800,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _emergencyMessage,
                style: GoogleFonts.inter(fontSize: 14.sp),
              ),
              SizedBox(height: 2.h),
              Text(
                'Immediate Actions Required:',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade800,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                '• Contact your healthcare provider immediately\n'
                '• Do not take any medication without consultation\n'
                '• Keep this notification for reference\n'
                '• Seek emergency medical attention if symptoms worsen',
                style: GoogleFonts.inter(fontSize: 12.sp),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Understood',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.red.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _dismissEmergencyAlert() {
    setState(() {
      _hasEmergencyAlert = false;
    });
    _pulseController.stop();
  }
}
