import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class AutomatedNotificationsWidget extends StatefulWidget {
  const AutomatedNotificationsWidget({super.key});

  @override
  State<AutomatedNotificationsWidget> createState() =>
      _AutomatedNotificationsWidgetState();
}

class _AutomatedNotificationsWidgetState
    extends State<AutomatedNotificationsWidget> {
  final List<NotificationTemplate> _notifications = [
    NotificationTemplate(
      id: '1',
      title: 'Session Reminder - 1 Hour Before',
      message:
          'Your Abhyanga session with Dr. {therapist_name} is scheduled in 1 hour at Room {room_number}. Please arrive 15 minutes early.',
      type: NotificationType.reminder,
      timing: '1 hour before',
      channels: ['SMS', 'Push', 'Email'],
      language: 'Auto-detect',
      status: NotificationStatus.active,
    ),
    NotificationTemplate(
      id: '2',
      title: 'Pre-procedure Instructions',
      message:
          'कृपया अपने {therapy_type} सेशन से पहले हल्का भोजन करें और ढीले कपड़े पहनें। Please have light meal before your {therapy_type} session and wear loose clothes.',
      type: NotificationType.instruction,
      timing: '2 hours before',
      channels: ['SMS', 'Push'],
      language: 'Hindi + English',
      status: NotificationStatus.active,
    ),
    NotificationTemplate(
      id: '3',
      title: 'Post-session Care',
      message:
          'Your session is complete! Please rest for 30 minutes and avoid cold beverages. Follow-up care instructions have been sent to your email.',
      type: NotificationType.followup,
      timing: 'Immediately after',
      channels: ['Push', 'Email'],
      language: 'English',
      status: NotificationStatus.active,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.notifications_active,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Automated Notifications',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _showAddNotificationDialog(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Template'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: GoogleFonts.inter(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Notification Statistics
          Row(
            children: [
              Expanded(
                  child: _buildStatCard(
                      'Templates',
                      '${_notifications.length}',
                      Icons.help_outline,
                      Theme.of(context).colorScheme.primary)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatCard(
                      'Sent Today', '47', Icons.send, Colors.green)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatCard(
                      'Success Rate', '96%', Icons.check_circle, Colors.blue)),
            ],
          ),
          const SizedBox(height: 16),

          // Notifications List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              return _buildNotificationCard(_notifications[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationTemplate notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getTypeColor(notification.type).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color:
                      _getTypeColor(notification.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getTypeIcon(notification.type),
                  color: _getTypeColor(notification.type),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  notification.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: notification.status == NotificationStatus.active,
                onChanged: (value) {
                  setState(() {
                    notification.status = value
                        ? NotificationStatus.active
                        : NotificationStatus.inactive;
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Message Preview
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              notification.message,
              style: GoogleFonts.inter(
                fontSize: 12,
                height: 1.3,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),

          // Details
          Row(
            children: [
              _buildDetailChip(
                  'Timing: ${notification.timing}', Icons.access_time),
              const SizedBox(width: 8),
              _buildDetailChip(
                  'Language: ${notification.language}', Icons.language),
            ],
          ),
          const SizedBox(height: 8),

          // Channels
          Wrap(
            spacing: 4,
            children: notification.channels
                .map((channel) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        channel,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Notification Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Template Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.reminder:
        return Colors.blue;
      case NotificationType.instruction:
        return Colors.orange;
      case NotificationType.followup:
        return Colors.green;
      case NotificationType.emergency:
        return Theme.of(context).colorScheme.error;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.instruction:
        return Icons.info;
      case NotificationType.followup:
        return Icons.follow_the_signs;
      case NotificationType.emergency:
        return Icons.emergency;
    }
  }
}

// Data Models
class NotificationTemplate {
  String id;
  String title;
  String message;
  NotificationType type;
  String timing;
  List<String> channels;
  String language;
  NotificationStatus status;

  NotificationTemplate({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timing,
    required this.channels,
    required this.language,
    required this.status,
  });
}

enum NotificationType { reminder, instruction, followup, emergency }

enum NotificationStatus { active, inactive }
