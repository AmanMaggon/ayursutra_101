import '../models/notification_model.dart';
import './supabase_service.dart';

class NotificationService {
  final _client = SupabaseService.instance.client;

  // Get user notifications
  Future<List<NotificationModel>> getUserNotifications({
    int limit = 50,
    bool unreadOnly = false,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      var query = _client.from('notifications').select().eq('user_id', user.id);

      if (unreadOnly) {
        query = query.eq('is_read', false);
      }

      final response =
          await query.order('created_at', ascending: false).limit(limit);

      return response
          .map<NotificationModel>((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch notifications: $error');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);
    } catch (error) {
      throw Exception('Failed to mark notification as read: $error');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id)
          .eq('is_read', false);
    } catch (error) {
      throw Exception('Failed to mark all notifications as read: $error');
    }
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    final user = _client.auth.currentUser;
    if (user == null) return 0;

    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .eq('is_read', false)
          .count();

      return response.count ?? 0;
    } catch (error) {
      print('Error getting unread count: $error');
      return 0;
    }
  }

  // Send notification (for admin use)
  Future<void> sendNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    List<String> deliveryChannels = const ['in_app'],
    DateTime? scheduledFor,
    String? templateId,
    String language = 'en',
  }) async {
    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'type': type,
        'title': title,
        'message': message,
        'delivery_channels': deliveryChannels,
        'scheduled_for': scheduledFor?.toIso8601String(),
        'template_id': templateId,
        'language': language,
      });
    } catch (error) {
      throw Exception('Failed to send notification: $error');
    }
  }

  // Subscribe to real-time notifications
  Stream<List<NotificationModel>> subscribeToNotifications() async* {
    final user = _client.auth.currentUser;
    if (user == null) return;

    // First emit current notifications
    yield await getUserNotifications();

    // Then listen for changes
    await for (final _ in _client
        .from('notifications')
        .stream(primaryKey: ['id']).eq('user_id', user.id)) {
      yield await getUserNotifications();
    }
  }
}
