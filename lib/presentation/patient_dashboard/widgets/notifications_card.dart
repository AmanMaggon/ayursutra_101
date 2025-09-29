import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ Add missing import

import '../../../core/app_export.dart';

class NotificationsCard extends StatefulWidget {
  final List<Map<String, dynamic>> notifications;
  final VoidCallback? onViewAll;

  const NotificationsCard({
    super.key,
    required this.notifications,
    this.onViewAll,
  });

  @override
  State<NotificationsCard> createState() => _NotificationsCardState();
}

class _NotificationsCardState extends State<NotificationsCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
              _buildHeader(colorScheme),
              SizedBox(height: 2.h),
              _buildNotificationsList(colorScheme),
              if (widget.notifications.length > 2) ...[
                SizedBox(height: 1.h),
                _buildExpandButton(colorScheme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    final int unreadCount = (widget.notifications as List)
        .where((notification) => !(notification['isRead'] ?? false)) // ✅ Fixed null safety
        .length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon( // ✅ Fixed CustomIconWidget
              Icons.notifications,
              color: colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Recent Notifications',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            if (unreadCount > 0) ...[
              SizedBox(width: 2.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            widget.onViewAll?.call();
          },
          child: Text(
            'View All',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsList(ColorScheme colorScheme) {
    // ✅ Handle empty notifications
    if (widget.notifications.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.notifications_none,
                size: 48,
                color: colorScheme.onSurface.withOpacity(0.3),
              ),
              SizedBox(height: 2.h),
              Text(
                'No notifications yet',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final displayNotifications = _isExpanded
        ? widget.notifications
        : widget.notifications.take(2).toList();

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: displayNotifications.map((notification) {
          return _buildNotificationItem(colorScheme, notification);
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationItem(
    ColorScheme colorScheme,
    Map<String, dynamic> notification,
  ) {
    final bool isRead = notification['isRead'] ?? false; // ✅ Fixed null safety
    final String type = notification['type'] ?? 'general'; // ✅ Fixed null safety
    final String title = notification['title'] ?? 'Notification'; // ✅ Fixed null safety
    final String message = notification['message'] ?? ''; // ✅ Fixed null safety
    
    // ✅ Handle timestamp safely
    final DateTime timestamp = notification['timestamp'] != null 
        ? DateTime.tryParse(notification['timestamp'].toString()) ?? DateTime.now()
        : DateTime.now();
    final String timeAgo = _getTimeAgo(timestamp);

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isRead
            ? Colors.transparent
            : colorScheme.primary.withOpacity(0.05), // ✅ Fixed withValues
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isRead
              ? colorScheme.outline.withOpacity(0.2) // ✅ Fixed withValues
              : colorScheme.primary.withOpacity(0.2), // ✅ Fixed withValues
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(1.5.w),
            decoration: BoxDecoration(
              color: _getNotificationColor(type, colorScheme)
                  .withOpacity(0.1), // ✅ Fixed withValues
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon( // ✅ Fixed CustomIconWidget
              _getNotificationIcon(type),
              color: _getNotificationColor(type, colorScheme),
              size: 16,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface.withOpacity(0.7), // ✅ Fixed withValues
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  timeAgo,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface.withOpacity(0.5), // ✅ Fixed withValues
                  ),
                ),
              ],
            ),
          ),
          if (!isRead)
            Container(
              width: 2.w,
              height: 2.w,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandButton(ColorScheme colorScheme) {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          setState(() {
            _isExpanded = !_isExpanded;
          });
          if (_isExpanded) {
            _animationController.forward();
          } else {
            _animationController.reverse();
          }
        },
        icon: AnimatedRotation(
          turns: _isExpanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 300),
          child: Icon( // ✅ Fixed CustomIconWidget
            Icons.expand_more,
            color: colorScheme.primary,
            size: 16,
          ),
        ),
        label: Text(
          _isExpanded ? 'Show Less' : 'Show More',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) { // ✅ Fixed return type
    switch (type.toLowerCase()) {
      case 'appointment':
        return Icons.event;
      case 'reminder':
        return Icons.alarm;
      case 'care_instruction':
        return Icons.medical_services;
      case 'payment':
        return Icons.payment;
      case 'progress':
        return Icons.trending_up;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type, ColorScheme colorScheme) {
    switch (type.toLowerCase()) {
      case 'appointment':
        return colorScheme.primary;
      case 'reminder':
        return colorScheme.tertiary;
      case 'care_instruction':
        return Colors.green;
      case 'payment':
        return Colors.orange;
      case 'progress':
        return Colors.blue;
      default:
        return colorScheme.onSurface.withOpacity(0.6); // ✅ Fixed withValues
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
