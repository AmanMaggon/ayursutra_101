class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final String? templateId;
  final String language;
  final List<String> deliveryChannels;
  final DateTime? smsSentAt;
  final DateTime? emailSentAt;
  final DateTime? pushSentAt;
  final bool isRead;
  final DateTime? scheduledFor;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.templateId,
    required this.language,
    required this.deliveryChannels,
    this.smsSentAt,
    this.emailSentAt,
    this.pushSentAt,
    required this.isRead,
    this.scheduledFor,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      title: json['title'],
      message: json['message'],
      templateId: json['template_id'],
      language: json['language'] ?? 'en',
      deliveryChannels:
          List<String>.from(json['delivery_channels'] ?? ['in_app']),
      smsSentAt: json['sms_sent_at'] != null
          ? DateTime.parse(json['sms_sent_at'])
          : null,
      emailSentAt: json['email_sent_at'] != null
          ? DateTime.parse(json['email_sent_at'])
          : null,
      pushSentAt: json['push_sent_at'] != null
          ? DateTime.parse(json['push_sent_at'])
          : null,
      isRead: json['is_read'] ?? false,
      scheduledFor: json['scheduled_for'] != null
          ? DateTime.parse(json['scheduled_for'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'template_id': templateId,
      'language': language,
      'delivery_channels': deliveryChannels,
      'sms_sent_at': smsSentAt?.toIso8601String(),
      'email_sent_at': emailSentAt?.toIso8601String(),
      'push_sent_at': pushSentAt?.toIso8601String(),
      'is_read': isRead,
      'scheduled_for': scheduledFor?.toIso8601String(),
    };
  }

  // Helper getters
  String get typeDisplayName {
    switch (type) {
      case 'appointment':
        return 'Appointment';
      case 'payment':
        return 'Payment';
      case 'progress':
        return 'Progress';
      case 'care_instruction':
        return 'Care Instructions';
      case 'emergency':
        return 'Emergency';
      case 'system':
        return 'System';
      default:
        return type
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  bool get isDelivered {
    return deliveryChannels.any((channel) {
      switch (channel) {
        case 'sms':
          return smsSentAt != null;
        case 'email':
          return emailSentAt != null;
        case 'push':
          return pushSentAt != null;
        case 'in_app':
          return true; // In-app notifications are immediately available
        default:
          return false;
      }
    });
  }

  bool get isPending {
    return scheduledFor != null && scheduledFor!.isAfter(DateTime.now());
  }

  NotificationModel copyWith({
    String? title,
    String? message,
    bool? isRead,
    DateTime? smsSentAt,
    DateTime? emailSentAt,
    DateTime? pushSentAt,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      type: type,
      title: title ?? this.title,
      message: message ?? this.message,
      templateId: templateId,
      language: language,
      deliveryChannels: deliveryChannels,
      smsSentAt: smsSentAt ?? this.smsSentAt,
      emailSentAt: emailSentAt ?? this.emailSentAt,
      pushSentAt: pushSentAt ?? this.pushSentAt,
      isRead: isRead ?? this.isRead,
      scheduledFor: scheduledFor,
      createdAt: createdAt,
    );
  }
}
