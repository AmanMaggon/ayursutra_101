import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import './supabase_service.dart';

class AuthService {
  final _client = SupabaseService.instance.client;

  static const String demoOtp = '000000';
  
  // Fake demo credentials
  static const Map<String, Map<String, String>> _demoCredentials = {
    'patient': {
      'email': 'patient@ayursutra.com',
      'password': 'Demo@1234',
      'mobile': '9991199911',
      'abha': 'demo.patient@abdm',
    },
    'doctor': {
      'email': 'doctor@ayursutra.com',
      'password': 'Demo@1234',
      'mobile': '9992299922',
      'abha': 'demo.doctor@abdm',
    },
    'chemist': {
      'email': 'chemist@ayursutra.com',
      'password': 'Demo@1234',
      'mobile': '9993399933',
      'abha': 'demo.chemist@abdm',
    },
  };

  /// Gets formatted demo credentials for display in the UI.
  static List<Map<String, String>> getDemoCredentialsForDisplay() {
    return _demoCredentials.entries.map((entry) {
      return {
        'role': entry.key[0].toUpperCase() + entry.key.substring(1),
        'email': entry.value['email']!,
        'password': entry.value['password']!,
        'mobile': entry.value['mobile']!,
        'abha': entry.value['abha']!,
        'otp': demoOtp,
      };
    }).toList();
  }

  // BYPASS: Create fake successful auth response
  AuthResponse _createFakeAuthResponse(String role) {
    return AuthResponse(
      user: User(
        id: 'demo-user-id-$role',
        appMetadata: {},
        userMetadata: {'role': role, 'full_name': '$role Demo User'},
        aud: '',
        createdAt: DateTime.now().toIso8601String(),
      ),
      session: Session(
        accessToken: 'fake-token-$role',
        tokenType: 'bearer',
        user: User(
          id: 'demo-user-id-$role',
          appMetadata: {},
          userMetadata: {'role': role, 'full_name': '$role Demo User'},
          aud: '',
          createdAt: DateTime.now().toIso8601String(),
        ),
      ),
    );
  }

  // BYPASS: Always return success
  Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) async {
    print('BYPASS: signUpWithEmailPassword - Auto success');
    await Future.delayed(Duration(seconds: 1)); // Fake delay
    return _createFakeAuthResponse(data['role'] ?? 'patient');
  }

  // BYPASS: Always return success
  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    print('BYPASS: signInWithEmailPassword - Auto success');
    await Future.delayed(Duration(seconds: 1)); // Fake delay
    return _createFakeAuthResponse('patient');
  }

  // BYPASS: Always return success
  Future<AuthResponse> signInWithIdentifierAndPassword({
    required String identifier,
    required String password,
  }) async {
    print('BYPASS: signInWithIdentifierAndPassword - Auto success');
    await Future.delayed(Duration(seconds: 1)); // Fake delay
    
    // Try to guess role from identifier
    String role = 'patient';
    if (identifier.contains('doctor')) role = 'doctor';
    if (identifier.contains('chemist')) role = 'chemist';
    
    return _createFakeAuthResponse(role);
  }

  // BYPASS: Always return success
  Future<AuthResponse> signInWithDemoCredentials(String role) async {
    print('BYPASS: signInWithDemoCredentials - Auto success for $role');
    await Future.delayed(Duration(seconds: 1)); // Fake delay
    return _createFakeAuthResponse(role.toLowerCase());
  }

  // BYPASS: Always return success
  Future<AuthResponse> verifyMobileOtp(String phoneNumber, String otp, {bool isDemoMode = false}) async {
    print('BYPASS: verifyMobileOtp - Auto success');
    await Future.delayed(Duration(seconds: 1)); // Fake delay
    
    // Guess role from phone number
    String role = 'patient';
    if (phoneNumber == '9992299922') role = 'doctor';
    if (phoneNumber == '9993399933') role = 'chemist';
    
    return _createFakeAuthResponse(role);
  }

  // BYPASS: Always return success
  Future<AuthResponse> signInWithAbha({
    required String abhaId,
    String? password,
    String? otp,
    String? mobileNumber,
    bool isDemoMode = false,
  }) async {
    print('BYPASS: signInWithAbha - Auto success');
    await Future.delayed(Duration(seconds: 1)); // Fake delay
    
    // Guess role from ABHA ID
    String role = 'patient';
    if (abhaId.contains('doctor')) role = 'doctor';
    if (abhaId.contains('chemist')) role = 'chemist';
    
    return _createFakeAuthResponse(role);
  }

  // BYPASS: Do nothing
  Future<void> sendMobileOtp(String phoneNumber, {bool isDemoMode = false}) async {
    print("BYPASS: sendMobileOtp - Fake OTP sent to $phoneNumber");
    await Future.delayed(Duration(milliseconds: 500)); // Fake delay
  }

  // BYPASS: Always return success
  Future<Map<String, dynamic>> sendAbhaOtp({
    required String abhaId,
    String? mobileNumber,
    bool isDemoMode = false,
  }) async {
    print("BYPASS: sendAbhaOtp - Fake OTP sent to $abhaId");
    await Future.delayed(Duration(milliseconds: 500)); // Fake delay
    return {
      'success': true,
      'message': 'BYPASS: Fake OTP sent',
      'transactionId': 'fake-txn-${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  // BYPASS: Return null (triggers fallback to dashboard)
  Future<UserProfile?> getCurrentUserProfile() async {
    print('BYPASS: getCurrentUserProfile - Returning null for fallback');
    await Future.delayed(Duration(milliseconds: 200)); // Fake delay
    return null; // This will trigger fallback to patient dashboard
  }

  // BYPASS: Do nothing
  Future<void> signOut() async {
    print('BYPASS: signOut - Fake sign out');
  }

  // BYPASS: Always authenticated
  Stream<AuthState> get authStateChanges => Stream.value(
    AuthState(AuthChangeEvent.signedIn, Session(
      accessToken: 'fake-token',
      tokenType: 'bearer',
      user: User(
        id: 'demo-user-id',
        appMetadata: {},
        userMetadata: {'role': 'patient'},
        aud: '',
        createdAt: DateTime.now().toIso8601String(),
      ),
    ))
  );
  
  bool get isAuthenticated => true; // Always logged in
  
  bool get isAbhaAuthenticated => false;
  
  String? get currentUserAbhaId => null;
}
