import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  late SupabaseClient _client;

  SupabaseService._internal();

  static SupabaseService get instance {
    _instance ??= SupabaseService._internal();
    return _instance!;
  }

  SupabaseClient get client => _client;

  Future<void> initialize() async {
    // Use hardcoded values from env.json for now
    const String supabaseUrl = 'https://ytwzpumcwwvvdkgeochv.supabase.co';
    const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl0d3pwdW1jd3d2dmRrZ2VvY2h2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkxNDE0MTYsImV4cCI6MjA3NDcxNzQxNn0.sZoGWpJVkQ68AIjFbwn1gwx074ILM_ArVpHO4-DqhEw';

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    _client = Supabase.instance.client;
  }

  // Authentication methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Helper method to check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Get current user's role
  Future<String?> getCurrentUserRole() async {
    if (!isAuthenticated) return null;

    try {
      final response = await _client
          .from('user_profiles')
          .select('role')
          .eq('id', currentUser!.id)
          .single();
      return response['role'];
    } catch (e) {
      return null;
    }
  }
}
