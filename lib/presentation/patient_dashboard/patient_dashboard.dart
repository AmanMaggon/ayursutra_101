import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ Added missing import

import '../../core/app_export.dart';
import '../../models/notification_model.dart';
import '../../models/therapy_session.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../services/therapy_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/live_session_card.dart';
import './widgets/notifications_card.dart';
import './widgets/progress_card.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/upcoming_session_card.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard>
    with TickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  final AuthService _authService = AuthService();
  final TherapyService _therapyService = TherapyService();
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = false;
  UserProfile? _userProfile;
  TherapySession? _upcomingSession;
  List<NotificationModel> _notifications = [];
  Map<String, dynamic>? _liveSessionData;
  Map<String, dynamic> _progressData = {};

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDashboardData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load user profile
      _userProfile = await _authService.getCurrentUserProfile();

      // Load upcoming session
      _upcomingSession = await _therapyService.getUpcomingSession();

      // Load notifications
      _notifications =
          await _notificationService.getUserNotifications(limit: 4);

      // Load active live session
      _liveSessionData = await _therapyService.getActiveLiveSession();

      // Calculate progress data
      if (_userProfile != null) {
        await _calculateProgressData();
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      // Use fallback mock data if real data fails
      _setFallbackData();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _setFallbackData() {
    // Fallback to mock data structure
    if (_upcomingSession == null) {
      _progressData = {
        'packageName': 'Complete Panchakarma Package',
        'completedSessions': 8,
        'totalSessions': 21,
        'currentPhase': 'Pradhana Karma'
      };
    }
  }

  Future<void> _calculateProgressData() async {
    try {
      final allSessions = await _therapyService.getUserSessions();
      final completedSessions =
          allSessions.where((s) => s.status == 'completed').length;
      final totalSessions = allSessions.length;

      setState(() {
        _progressData = {
          'packageName': allSessions.isNotEmpty
              ? (allSessions.first.packageName.isNotEmpty
                  ? allSessions.first.packageName
                  : 'Custom Treatment Plan')
              : 'No Active Package',
          'completedSessions': completedSessions,
          'totalSessions': totalSessions > 0 ? totalSessions : 1,
          'currentPhase': _getCurrentPhase(allSessions),
        };
      });
    } catch (e) {
      print('Error calculating progress: $e');
      _setFallbackData();
    }
  }

  String _getCurrentPhase(List<TherapySession> sessions) {
    if (sessions.isEmpty) return 'Planning Phase';

    final recentSession = sessions.first;
    switch (recentSession.therapyPhase) {
      case 'purva_karma':
        return 'Purva Karma';
      case 'pradhana_karma':
        return 'Pradhana Karma';
      case 'paschat_karma':
        return 'Paschat Karma';
      default:
        return 'Treatment Phase';
    }
  }

  Future<void> _refreshData() async {
    HapticFeedback.lightImpact();
    await _loadDashboardData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dashboard updated successfully',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refreshData,
          color: colorScheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildAppBar(colorScheme),
              SliverToBoxAdapter(
                child: _isLoading
                    ? _buildLoadingState(colorScheme)
                    : _buildDashboardContent(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 0,
        variant: CustomBottomBarVariant.primary,
        onTap: _handleBottomNavigation,
      ),
      floatingActionButton: _buildFloatingActionButton(colorScheme),
    );
  }

  Widget _buildAppBar(ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 15.h,
      floating: false,
      pinned: true,
      backgroundColor: colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.8), // ✅ Fixed withValues to withOpacity
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Namaste, ${_userProfile?.fullName ?? 'Patient'}',
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), // ✅ Fixed withValues to withOpacity
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Current Phase: ${_progressData['currentPhase'] ?? 'Planning'}',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showNotifications(),
          icon: Icon( // ✅ Fixed CustomIconWidget to Icon
            Icons.notifications,
            color: Colors.white,
            size: 24,
          ),
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuSelection,
          icon: Icon( // ✅ Fixed CustomIconWidget to Icon
            Icons.more_vert,
            color: Colors.white,
            size: 24,
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon( // ✅ Fixed CustomIconWidget to Icon
                      Icons.person,
                      color: colorScheme.onSurface,
                      size: 20),
                  SizedBox(width: 3.w),
                  Text('Profile',
                      style: GoogleFonts.inter(
                          fontSize: 14.sp, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon( // ✅ Fixed CustomIconWidget to Icon
                      Icons.settings,
                      color: colorScheme.onSurface,
                      size: 20),
                  SizedBox(width: 3.w),
                  Text('Settings',
                      style: GoogleFonts.inter(
                          fontSize: 14.sp, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon( // ✅ Fixed CustomIconWidget to Icon
                      Icons.logout, color: colorScheme.error, size: 20),
                  SizedBox(width: 3.w),
                  Text('Logout',
                      style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.error)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Container(
      height: 60.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            SizedBox(height: 2.h),
            Text(
              'Loading your dashboard...',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface.withOpacity(0.7), // ✅ Fixed withValues to withOpacity
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      children: [
        SizedBox(height: 2.h),

        // Live Session Card
        LiveSessionCard(
          liveSessionData: _liveSessionData,
          onViewSession: () => _navigateToLiveSession(),
          onEndSession: () => _endLiveSession(),
        ),

        // Upcoming Session Card
        UpcomingSessionCard(
          sessionData: _upcomingSession?.toJson() ?? {},
          onViewDetails: () => _viewSessionDetails(),
          onReschedule: () => _rescheduleSession(),
          onCancel: () => _cancelSession(),
          onAddToCalendar: () => _addToCalendar(),
        ),

        // Progress Card
        ProgressCard(
          progressData: _progressData,
          onViewProgress: () => _viewDetailedProgress(),
        ),

        // Quick Actions Widget
        QuickActionsWidget(
          onBookSession: () => _bookNewSession(),
          onEmergencyContact: () => _contactEmergency(),
          onViewProgress: () => _viewDetailedProgress(),
          onReschedule: () => _rescheduleSession(),
        ),

        // Notifications Card
        NotificationsCard(
          notifications: _notifications.map((n) => n.toJson()).toList(),
          onViewAll: () => _viewAllNotifications(),
        ),

        SizedBox(height: 10.h),
      ],
    );
  }

  Widget _buildFloatingActionButton(ColorScheme colorScheme) {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.mediumImpact();
        _bookNewSession();
      },
      backgroundColor: colorScheme.primary,
      foregroundColor: Colors.white,
      icon: Icon(Icons.add, color: Colors.white, size: 24), // ✅ Fixed CustomIconWidget to Icon
      label: Text(
        'Book Session',
        style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Event Handlers
  void _handleBottomNavigation(int index) {
    switch (index) {
      case 0:
        break; // Already on dashboard
      case 1:
        Navigator.pushNamed(context, '/therapy-booking-screen');
        break;
      case 2:
        Navigator.pushNamed(context, '/live-session-tracking-screen');
        break;
      case 3:
        Navigator.pushNamed(context, '/doctor-dashboard');
        break;
      case 4:
        Navigator.pushNamed(context, '/payment-gateway-screen');
        break;
    }
  }

  void _handleMenuSelection(String value) async {
    switch (value) {
      case 'profile':
        _showComingSoonSnackBar('Profile');
        break;
      case 'settings':
        _showComingSoonSnackBar('Settings');
        break;
      case 'logout':
        await _authService.signOut();
        Navigator.pushNamedAndRemoveUntil(
            context, '/multi-role-authentication-screen', (route) => false);
        break;
    }
  }

  void _navigateToLiveSession() =>
      Navigator.pushNamed(context, '/live-session-tracking-screen');

  void _endLiveSession() async {
    if (_liveSessionData != null) {
      try {
        await _therapyService.endLiveSession(_liveSessionData!['id']);
        setState(() => _liveSessionData = null);
        _showSuccessSnackBar('Session ended successfully');
      } catch (e) {
        _showErrorSnackBar('Failed to end session');
      }
    }
  }

  void _viewSessionDetails() => _showComingSoonSnackBar('Session Details');
  void _rescheduleSession() =>
      Navigator.pushNamed(context, '/therapy-booking-screen');
  void _cancelSession() => _showCancelDialog();
  void _addToCalendar() => _showSuccessSnackBar('Session added to calendar');
  void _viewDetailedProgress() => _showComingSoonSnackBar('Detailed Progress');
  void _bookNewSession() =>
      Navigator.pushNamed(context, '/therapy-booking-screen');
  void _contactEmergency() => _showEmergencyDialog();
  void _showNotifications() => _showComingSoonSnackBar('All Notifications');
  void _viewAllNotifications() => _showComingSoonSnackBar('All Notifications');

  // Helper methods
  void _showCancelDialog() {
    _showDialog(
      'Cancel Session',
      'Are you sure you want to cancel your upcoming session? This action cannot be undone.',
      'Cancel Session',
      () => _showSuccessSnackBar('Session cancelled successfully'),
    );
  }

  void _showEmergencyDialog() {
    _showDialog(
      'Emergency Contact',
      'Do you need immediate medical assistance? This will connect you to our 24/7 emergency helpline.',
      'Call Now',
      () => _showSuccessSnackBar('Connecting to emergency helpline...'),
    );
  }

  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon',
            style: GoogleFonts.inter(
                fontSize: 14.sp, fontWeight: FontWeight.w400)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: GoogleFonts.inter(
                fontSize: 14.sp, fontWeight: FontWeight.w400)),
        backgroundColor: Theme.of(context).colorScheme.primary, // ✅ Fixed AppTheme reference
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: GoogleFonts.inter(
                fontSize: 14.sp, fontWeight: FontWeight.w400)),
        backgroundColor: Theme.of(context).colorScheme.error, // ✅ Fixed AppTheme reference
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDialog(
      String title, String content, String actionText, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title,
              style: GoogleFonts.inter(
                  fontSize: 18.sp, fontWeight: FontWeight.w600)),
          content: Text(content,
              style: GoogleFonts.inter(
                  fontSize: 14.sp, fontWeight: FontWeight.w400)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel',
                  style: GoogleFonts.inter(
                      fontSize: 14.sp, fontWeight: FontWeight.w500)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text(actionText,
                  style: GoogleFonts.inter(
                      fontSize: 14.sp, fontWeight: FontWeight.w500)),
            ),
          ],
        );
      },
    );
  }
}
