import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../models/notification_model.dart';

class NotificationCardWidget extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;

  const NotificationCardWidget({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onMarkAsRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Material(
        elevation: notification.isRead ? 1 : 3,
        borderRadius: BorderRadius.circular(12),
        color: notification.isRead
            ? colorScheme.surface
            : colorScheme.primary.withAlpha(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notification Icon
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: _getNotificationColor(notification.type)
                            .withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getNotificationIcon(notification.type),
                        color: _getNotificationColor(notification.type),
                        size: 6.w,
                      ),
                    ),

                    SizedBox(width: 3.w),

                    // Notification Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Notification Type Badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _getNotificationColor(notification.type),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  notification.typeDisplayName,
                                  style: GoogleFonts.inter(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              Spacer(),

                              // Time and Read Status
                              Row(
                                children: [
                                  if (!notification.isRead) ...[
                                    Container(
                                      width: 2.w,
                                      height: 2.w,
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                  ],
                                  Text(
                                    notification.timeAgo,
                                    style: GoogleFonts.inter(
                                      fontSize: 10.sp,
                                      color:
                                          colorScheme.onSurface.withAlpha(153),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: 1.h),

                          // Title
                          Text(
                            notification.title,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          SizedBox(height: 0.5.h),

                          // Message
                          Text(
                            notification.message,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: colorScheme.onSurface.withAlpha(179),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          SizedBox(height: 1.h),

                          // Delivery Channels and Status
                          Row(
                            children: [
                              // Delivery Channels
                              Row(
                                children: notification.deliveryChannels
                                    .map((channel) {
                                  return Container(
                                    margin: EdgeInsets.only(right: 1.w),
                                    child: Icon(
                                      _getChannelIcon(channel),
                                      size: 14,
                                      color: notification.isDelivered
                                          ? Colors.green
                                          : colorScheme.onSurface
                                              .withAlpha(102),
                                    ),
                                  );
                                }).toList(),
                              ),

                              Spacer(),

                              // Priority Indicator
                              if (notification.type == 'emergency') ...[
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 0.5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withAlpha(26),
                                    borderRadius: BorderRadius.circular(4),
                                    border:
                                        Border.all(color: Colors.red, width: 1),
                                  ),
                                  child: Text(
                                    'URGENT',
                                    style: GoogleFonts.inter(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Action Menu
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'mark_read':
                            if (!notification.isRead) onMarkAsRead();
                            break;
                          case 'delete':
                            _showDeleteConfirmation(context);
                            break;
                        }
                      },
                      icon: Icon(
                        Icons.more_vert,
                        color: colorScheme.onSurface.withAlpha(128),
                        size: 20,
                      ),
                      itemBuilder: (context) => [
                        if (!notification.isRead)
                          PopupMenuItem(
                            value: 'mark_read',
                            child: Row(
                              children: [
                                Icon(Icons.mark_email_read, size: 18),
                                SizedBox(width: 2.w),
                                Text(
                                  'Mark as Read',
                                  style: GoogleFonts.inter(fontSize: 12.sp),
                                ),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 2.w),
                              Text(
                                'Delete',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'emergency':
        return Colors.red;
      case 'appointment':
        return Colors.blue;
      case 'payment':
        return Colors.green;
      case 'progress':
        return Colors.purple;
      case 'care_instruction':
        return Colors.orange;
      case 'system':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'emergency':
        return Icons.warning;
      case 'appointment':
        return Icons.event;
      case 'payment':
        return Icons.payment;
      case 'progress':
        return Icons.trending_up;
      case 'care_instruction':
        return Icons.medical_services;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  IconData _getChannelIcon(String channel) {
    switch (channel) {
      case 'sms':
        return Icons.sms;
      case 'email':
        return Icons.email;
      case 'push':
        return Icons.notifications;
      case 'in_app':
        return Icons.phone_android;
      default:
        return Icons.notifications;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Notification',
          style:
              GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete this notification? This action cannot be undone.',
          style: GoogleFonts.inter(fontSize: 12.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(fontSize: 12.sp),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                  fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
