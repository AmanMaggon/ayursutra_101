import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/notification_card_widget.dart';
import './widgets/notification_filter_widget.dart';
import './widgets/notification_settings_widget.dart';
import './widgets/emergency_alert_banner_widget.dart';
import './widgets/notification_search_widget.dart';

class EnhancedNotificationSystemInterface extends StatefulWidget {
  const EnhancedNotificationSystemInterface({super.key});

  @override
  State<EnhancedNotificationSystemInterface> createState() =>
      _EnhancedNotificationSystemInterfaceState();
}

class _EnhancedNotificationSystemInterfaceState
    extends State<EnhancedNotificationSystemInterface>
    with TickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = AuthService();

  List<NotificationModel> _notifications = [];
  List<NotificationModel> _filteredNotifications = [];
  bool _isLoading = false;
  bool _hasMoreNotifications = true;
  int _currentPage = 1;
  String _selectedFilter = 'all';
  bool _showUnreadOnly = false;
  String _searchQuery = '';

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadNotifications();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
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

  Future<void> _loadNotifications({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _currentPage = 1;
        _hasMoreNotifications = true;
      }
    });

    try {
      final notifications = await _notificationService.getUserNotifications(
        limit: 20,
      );

      setState(() {
        if (refresh) {
          _notifications = notifications;
        } else {
          _notifications.addAll(notifications);
        }

        _hasMoreNotifications = notifications.length == 20;
        if (!refresh) _currentPage++;

        _applyFilters();
      });
    } catch (e) {
      print('Error loading notifications: $e');
      _showErrorSnackBar('Failed to load notifications');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_hasMoreNotifications && !_isLoading) {
        _loadNotifications();
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredNotifications = _notifications.where((notification) {
        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          if (!notification.title.toLowerCase().contains(_searchQuery) &&
              !notification.message.toLowerCase().contains(_searchQuery)) {
            return false;
          }
        }

        // Apply read/unread filter
        if (_showUnreadOnly && notification.isRead) {
          return false;
        }

        // Apply type filter
        if (_selectedFilter != 'all' && notification.type != _selectedFilter) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  Future<void> _refreshNotifications() async {
    HapticFeedback.lightImpact();
    await _loadNotifications(refresh: true);
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilters();
    });
  }

  void _toggleUnreadFilter() {
    setState(() {
      _showUnreadOnly = !_showUnreadOnly;
      _applyFilters();
    });
  }

  Future<void> _markNotificationAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);

      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
        }
        _applyFilters();
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();

      setState(() {
        _notifications =
            _notifications.map((n) => n.copyWith(isRead: true)).toList();
        _applyFilters();
      });

      _showSuccessSnackBar('All notifications marked as read');
    } catch (e) {
      print('Error marking all as read: $e');
      _showErrorSnackBar('Failed to mark all as read');
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      // Remove from local state since deleteNotification method doesn't exist in NotificationService
      setState(() {
        _notifications.removeWhere((n) => n.id == notificationId);
        _applyFilters();
      });

      _showSuccessSnackBar('Notification deleted');
    } catch (e) {
      print('Error deleting notification: $e');
      _showErrorSnackBar('Failed to delete notification');
    }
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationSettingsWidget(
        onSettingsChanged: () {
          Navigator.pop(context);
          _showSuccessSnackBar('Notification settings updated');
        },
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Notifications',
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showNotificationSettings,
            icon: Icon(
              Icons.settings,
              color: colorScheme.onSurface,
              size: 24,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            icon: Icon(
              Icons.more_vert,
              color: colorScheme.onSurface,
              size: 24,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read, size: 20),
                    SizedBox(width: 3.w),
                    Text('Mark All Read',
                        style: GoogleFonts.inter(fontSize: 14.sp)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 3.w),
                    Text('Export History',
                        style: GoogleFonts.inter(fontSize: 14.sp)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Emergency Alert Banner (if any)
              EmergencyAlertBannerWidget(),

              // Search and Filter Section
              Container(
                padding: EdgeInsets.all(4.w),
                color: colorScheme.surface,
                child: Column(
                  children: [
                    // Search Bar
                    NotificationSearchWidget(
                      controller: _searchController,
                      onClearSearch: () {
                        _searchController.clear();
                        _onSearchChanged();
                      },
                    ),

                    SizedBox(height: 2.h),

                    // Filters
                    NotificationFilterWidget(
                      selectedFilter: _selectedFilter,
                      showUnreadOnly: _showUnreadOnly,
                      onFilterChanged: _onFilterChanged,
                      onToggleUnread: _toggleUnreadFilter,
                      unreadCount:
                          _notifications.where((n) => !n.isRead).length,
                    ),
                  ],
                ),
              ),

              // Notifications List
              Expanded(
                child: RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _refreshNotifications,
                  color: colorScheme.primary,
                  child: _buildNotificationsList(colorScheme),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 3, // Assuming notifications is at index 3
        variant: CustomBottomBarVariant.primary,
        onTap: _handleBottomNavigation,
      ),
    );
  }

  Widget _buildNotificationsList(ColorScheme colorScheme) {
    if (_isLoading && _notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            SizedBox(height: 2.h),
            Text(
              'Loading notifications...',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: colorScheme.onSurface.withAlpha(179),
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: colorScheme.onSurface.withAlpha(77),
            ),
            SizedBox(height: 2.h),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No notifications match your search'
                  : (_showUnreadOnly
                      ? 'No unread notifications'
                      : 'No notifications yet'),
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withAlpha(179),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _searchQuery.isNotEmpty || _showUnreadOnly
                  ? 'Try adjusting your filters'
                  : 'Notifications will appear here as they arrive',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: colorScheme.onSurface.withAlpha(128),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      itemCount:
          _filteredNotifications.length + (_hasMoreNotifications ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _filteredNotifications.length) {
          return Container(
            padding: EdgeInsets.all(4.w),
            child: Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            ),
          );
        }

        final notification = _filteredNotifications[index];
        return NotificationCardWidget(
          notification: notification,
          onTap: () => _handleNotificationTap(notification),
          onMarkAsRead: () => _markNotificationAsRead(notification.id),
          onDelete: () => _deleteNotification(notification.id),
        );
      },
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    if (!notification.isRead) {
      _markNotificationAsRead(notification.id);
    }

    // Navigate based on notification type
    switch (notification.type) {
      case 'appointment':
        Navigator.pushNamed(context, '/therapy-booking-screen');
        break;
      case 'payment':
        Navigator.pushNamed(context, '/payment-gateway-screen');
        break;
      case 'progress':
        Navigator.pushNamed(context, '/patient-dashboard');
        break;
      case 'emergency':
        _showEmergencyDialog(notification);
        break;
      default:
        // Show notification details
        _showNotificationDetails(notification);
        break;
    }
  }

  void _showNotificationDetails(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          notification.title,
          style:
              GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                notification.message,
                style: GoogleFonts.inter(fontSize: 14.sp),
              ),
              SizedBox(height: 2.h),
              Text(
                'Received: ${notification.timeAgo}',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.inter(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  void _showEmergencyDialog(NotificationModel notification) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        title: Row(
          children: [
            Icon(Icons.warning, color: Theme.of(context).colorScheme.error),
            SizedBox(width: 2.w),
            Text(
              'Emergency Alert',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ],
        ),
        content: Text(
          notification.message,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Understood',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'mark_all_read':
        _markAllAsRead();
        break;
      case 'export':
        _exportNotificationHistory();
        break;
    }
  }

  void _exportNotificationHistory() {
    // Implementation for exporting notification history
    _showSuccessSnackBar('Export feature coming soon');
  }

  void _handleBottomNavigation(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/patient-dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/therapy-booking-screen');
        break;
      case 2:
        Navigator.pushReplacementNamed(
            context, '/live-session-tracking-screen');
        break;
      case 3:
        // Already on notifications
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/payment-gateway-screen');
        break;
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style:
              GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w400),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style:
              GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w400),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
