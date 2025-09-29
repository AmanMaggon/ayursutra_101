import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/completion_checklist_widget.dart';
import './widgets/emergency_alert_widget.dart';
import './widgets/oil_medicine_tracking_widget.dart';
import './widgets/patient_feedback_widget.dart';
import './widgets/room_details_widget.dart';
import './widgets/session_header_widget.dart';
import './widgets/status_timeline_widget.dart';
import './widgets/therapist_card_widget.dart';

class LiveSessionTrackingScreen extends StatefulWidget {
  const LiveSessionTrackingScreen({super.key});

  @override
  State<LiveSessionTrackingScreen> createState() =>
      _LiveSessionTrackingScreenState();
}

class _LiveSessionTrackingScreenState extends State<LiveSessionTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  Duration _sessionDuration =
      const Duration(hours: 1, minutes: 23, seconds: 45);
  bool _isSessionActive = true;
  bool _isChecklistComplete = false;

  // Mock data for the session
  final Map<String, dynamic> _therapistData = {
    "id": "T001",
    "name": "Dr. Priya Sharma",
    "specialization": "Panchakarma Specialist",
    "photo":
        "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
    "rating": 4.8,
    "experience": 12,
    "isActive": true,
  };

  final Map<String, dynamic> _roomData = {
    "number": "A-204",
    "location": "Second Floor, Ayurveda Wing",
    "equipmentStatus": "Ready",
    "temperature": 24,
    "lighting": "Dim",
    "hygieneStatus": "Sanitized",
  };

  final List<Map<String, dynamic>> _timelineData = [
    {
      "title": "Preparation Started",
      "description": "Room sanitization and equipment setup completed",
      "time": "14:30",
      "isCompleted": true,
      "isCurrent": false,
    },
    {
      "title": "Patient Assessment",
      "description": "Vital signs checked, medical history reviewed",
      "time": "14:45",
      "isCompleted": true,
      "isCurrent": false,
    },
    {
      "title": "Abhyanga Therapy in Progress",
      "description": "Full body oil massage with medicated oils",
      "expandedDetails":
          "Using Mahanarayan oil for joint and muscle relaxation. Patient comfort level being monitored continuously.",
      "time": "15:00",
      "isCompleted": false,
      "isCurrent": true,
    },
    {
      "title": "Steam Therapy",
      "description": "Herbal steam treatment for toxin elimination",
      "time": "16:15",
      "isCompleted": false,
      "isCurrent": false,
    },
    {
      "title": "Post-care Instructions",
      "description": "Recovery guidelines and next session planning",
      "time": "16:45",
      "isCompleted": false,
      "isCurrent": false,
    },
  ];

  final List<Map<String, dynamic>> _oilMedicineData = [
    {
      "type": "Oil",
      "name": "Mahanarayan Oil",
      "batchNumber": "MNO-2024-089",
      "quantity": "50ml",
      "appliedAt": "15:05",
      "isVerified": true,
      "therapistNote":
          "Applied with gentle circular motions, patient responded well",
    },
    {
      "type": "Medicine",
      "name": "Triphala Churna",
      "batchNumber": "TC-2024-156",
      "quantity": "5g",
      "appliedAt": "15:20",
      "isVerified": false,
      "therapistNote": null,
    },
  ];

  final List<Map<String, dynamic>> _checklistItems = [
    {
      "title": "Patient comfort confirmed",
      "description":
          "Verify patient is comfortable with temperature and positioning",
      "isRequired": true,
      "isChecked": false,
    },
    {
      "title": "Oil application documented",
      "description": "Record all oils and medicines used with batch numbers",
      "isRequired": true,
      "isChecked": false,
    },
    {
      "title": "Vital signs recorded",
      "description": "Blood pressure, pulse, and temperature documented",
      "isRequired": true,
      "isChecked": false,
    },
    {
      "title": "Post-care instructions given",
      "description": "Patient briefed on aftercare and next session details",
      "isRequired": true,
      "isChecked": false,
    },
    {
      "title": "Session photos taken",
      "description": "Progress documentation with patient consent",
      "isRequired": false,
      "isChecked": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSessionTimer();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  void _startSessionTimer() {
    // Simulate session timer
    Future.delayed(const Duration(seconds: 1), () {
      if (_isSessionActive && mounted) {
        setState(() {
          _sessionDuration = Duration(
            seconds: _sessionDuration.inSeconds + 1,
          );
        });
        _startSessionTimer();
      }
    });
  }

  void _handleBackPressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Exit Session Tracking?',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to exit? The session will continue in the background.',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/patient-dashboard');
              },
              child: Text(
                'Exit',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleEmergencyAlert() {
    // Simulate emergency alert functionality
    setState(() {
      _isSessionActive = false;
    });

    // In a real app, this would:
    // 1. Send immediate alert to medical staff
    // 2. Share patient location
    // 3. Log emergency event
    // 4. Potentially call emergency services
  }

  void _handleTherapistMessage() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'message',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Message Therapist',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Send a non-urgent message to your therapist. For emergencies, use the red emergency button.',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Expanded(
                      child: TextField(
                        maxLines: null,
                        expands: true,
                        decoration: InputDecoration(
                          hintText: 'Type your message here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.all(3.w),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Message sent to therapist',
                                style: GoogleFonts.inter(fontSize: 12.sp),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Send Message',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleFeedbackSubmitted(int comfort, String? notes) {
    // In a real app, this would send feedback to the backend
    print('Feedback submitted: Comfort level $comfort, Notes: $notes');
  }

  void _handleChecklistComplete(bool isComplete) {
    setState(() {
      _isChecklistComplete = isComplete;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            Column(
              children: [
                SessionHeaderWidget(
                  therapyName: "Abhyanga + Steam Therapy",
                  currentPhase: "Purva Karma - Preparation Phase",
                  sessionDuration: _sessionDuration,
                  progressPercentage: 65.0,
                  onBackPressed: _handleBackPressed,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: 1.h),
                        TherapistCardWidget(
                          therapistData: _therapistData,
                          onMessageTap: _handleTherapistMessage,
                        ),
                        RoomDetailsWidget(
                          roomData: _roomData,
                        ),
                        StatusTimelineWidget(
                          timelineData: _timelineData,
                        ),
                        PatientFeedbackWidget(
                          onFeedbackSubmitted: _handleFeedbackSubmitted,
                        ),
                        OilMedicineTrackingWidget(
                          trackingData: _oilMedicineData,
                        ),
                        CompletionChecklistWidget(
                          checklistItems: _checklistItems,
                          onChecklistComplete: _handleChecklistComplete,
                        ),
                        SizedBox(height: 20.h), // Space for emergency button
                      ],
                    ),
                  ),
                ),
              ],
            ),
            EmergencyAlertWidget(
              onEmergencyPressed: _handleEmergencyAlert,
            ),
          ],
        ),
      ),
    );
  }
}
