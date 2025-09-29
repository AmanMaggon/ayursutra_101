import '../models/therapy_package.dart';
import '../models/therapy_session.dart';
import './supabase_service.dart';

class TherapyService {
  final _client = SupabaseService.instance.client;

  // Get available therapy packages
  Future<List<TherapyPackage>> getTherapyPackages() async {
    try {
      final response = await _client
          .from('therapy_packages')
          .select()
          .eq('is_active', true)
          .order('name');

      return response
          .map<TherapyPackage>((json) => TherapyPackage.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch therapy packages: $error');
    }
  }

  // Get user's therapy sessions
  Future<List<TherapySession>> getUserSessions({String? status}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      var query = _client.from('therapy_sessions').select('''
            *,
            therapy_packages(name, description),
            user_profiles!therapy_sessions_doctor_id_fkey(full_name, profile_image_url)
          ''').eq('patient_id', user.id);

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('scheduled_date', ascending: false);

      return response
          .map<TherapySession>((json) => TherapySession.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch therapy sessions: $error');
    }
  }

  // Book a therapy session
  Future<TherapySession> bookTherapySession({
    required String packageId,
    required String therapyType,
    required DateTime scheduledDate,
    required String scheduledTime,
    String? doctorId,
    String? roomId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final response = await _client.from('therapy_sessions').insert({
        'patient_id': user.id,
        'package_id': packageId,
        'doctor_id': doctorId,
        'room_id': roomId,
        'therapy_type': therapyType,
        'scheduled_date': scheduledDate.toIso8601String().split('T')[0],
        'scheduled_time': scheduledTime,
        'status': 'scheduled',
      }).select('''
            *,
            therapy_packages(name, description),
            user_profiles!therapy_sessions_doctor_id_fkey(full_name, profile_image_url)
          ''').single();

      return TherapySession.fromJson(response);
    } catch (error) {
      throw Exception('Failed to book therapy session: $error');
    }
  }

  // Update session status
  Future<TherapySession> updateSessionStatus({
    required String sessionId,
    required String status,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final updateData = <String, dynamic>{'status': status};
      if (additionalData != null) {
        updateData.addAll(additionalData);
      }

      final response = await _client
          .from('therapy_sessions')
          .update(updateData)
          .eq('id', sessionId)
          .select('''
            *,
            therapy_packages(name, description),
            user_profiles!therapy_sessions_doctor_id_fkey(full_name, profile_image_url)
          ''').single();

      return TherapySession.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update session status: $error');
    }
  }

  // Get upcoming session
  Future<TherapySession?> getUpcomingSession() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _client
          .from('therapy_sessions')
          .select('''
            *,
            therapy_packages(name, description),
            user_profiles!therapy_sessions_doctor_id_fkey(full_name, profile_image_url)
          ''')
          .eq('patient_id', user.id)
          .eq('status', 'scheduled')
          .gte('scheduled_date', DateTime.now().toIso8601String().split('T')[0])
          .order('scheduled_date')
          .order('scheduled_time')
          .limit(1)
          .maybeSingle();

      return response != null ? TherapySession.fromJson(response) : null;
    } catch (error) {
      print('Error fetching upcoming session: $error');
      return null;
    }
  }

  // Get active live session
  Future<Map<String, dynamic>?> getActiveLiveSession() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _client
          .from('live_sessions')
          .select('''
            *,
            therapy_sessions!inner(
              *,
              user_profiles!therapy_sessions_doctor_id_fkey(full_name)
            )
          ''')
          .eq('therapy_sessions.patient_id', user.id)
          .isFilter('ended_at', null)
          .maybeSingle();

      return response;
    } catch (error) {
      print('Error fetching active live session: $error');
      return null;
    }
  }

  // Start live session
  Future<Map<String, dynamic>> startLiveSession(String sessionId) async {
    try {
      final response = await _client
          .from('live_sessions')
          .insert({
            'session_id': sessionId,
            'started_at': DateTime.now().toIso8601String(),
            'milestones': [],
            'emergency_alerts': [],
          })
          .select()
          .single();

      // Update session status to in_progress
      await _client
          .from('therapy_sessions')
          .update({'status': 'in_progress'}).eq('id', sessionId);

      return response;
    } catch (error) {
      throw Exception('Failed to start live session: $error');
    }
  }

  // End live session
  Future<void> endLiveSession(String liveSessionId) async {
    try {
      await _client.from('live_sessions').update({
        'ended_at': DateTime.now().toIso8601String(),
      }).eq('id', liveSessionId);
    } catch (error) {
      throw Exception('Failed to end live session: $error');
    }
  }
}