import 'package:flutter/material.dart';
import '../presentation/multi_role_authentication_screen/multi_role_authentication_screen.dart';
import '../presentation/authentication_entry_screen/authentication_entry_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/account_creation_screen/account_creation_screen.dart';
import '../presentation/otp_verification_screen/otp_verification_screen.dart';
import '../presentation/payment_gateway_screen/payment_gateway_screen.dart';
import '../presentation/live_session_tracking_screen/live_session_tracking_screen.dart';
import '../presentation/patient_dashboard/patient_dashboard.dart';
import '../presentation/therapy_booking_screen/therapy_booking_screen.dart';
import '../presentation/doctor_dashboard/doctor_dashboard.dart';
import '../presentation/ai_drishya_assistant_chat_interface/ai_drishya_assistant_chat_interface.dart';
import '../presentation/automated_therapy_scheduling_dashboard/automated_therapy_scheduling_dashboard.dart';
import '../presentation/enhanced_notification_system_interface/enhanced_notification_system_interface.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/splash';
  static const String splash = '/splash';
  static const String authenticationEntryScreen =
      '/authentication-entry-screen';
  static const String accountCreationScreen = '/account-creation-screen';
  static const String otpVerificationScreen = '/otp-verification-screen';
  static const String multiRoleAuthentication =
      '/multi-role-authentication-screen';
  static const String paymentGateway = '/payment-gateway-screen';
  static const String liveSessionTracking = '/live-session-tracking-screen';
  static const String patientDashboard = '/patient-dashboard';
  static const String therapyBooking = '/therapy-booking-screen';
  static const String doctorDashboard = '/doctor-dashboard';
  static const String chemistDashboard = '/chemist-dashboard';
  static const String aiDrishyaAssistantChatInterface =
      '/ai-drishya-assistant-chat-interface';
  static const String automatedTherapySchedulingDashboard =
      '/automated-therapy-scheduling-dashboard';
  static const String enhancedNotificationSystemInterface =
      '/enhanced-notification-system-interface';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    authenticationEntryScreen: (context) => const AuthenticationEntryScreen(),
    accountCreationScreen: (context) => const AccountCreationScreen(),
    otpVerificationScreen: (context) => const OtpVerificationScreen(),
    multiRoleAuthentication: (context) => const MultiRoleAuthenticationScreen(),
    paymentGateway: (context) => const PaymentGatewayScreen(),
    liveSessionTracking: (context) => const LiveSessionTrackingScreen(),
    patientDashboard: (context) => const PatientDashboard(),
    therapyBooking: (context) => const TherapyBookingScreen(),
    doctorDashboard: (context) => const DoctorDashboard(),
    chemistDashboard: (context) => const ChemistDashboard(),
    aiDrishyaAssistantChatInterface: (context) =>
        const AiDrishyaAssistantChatInterface(),
    automatedTherapySchedulingDashboard: (context) =>
        const AutomatedTherapySchedulingDashboard(),
    enhancedNotificationSystemInterface: (context) =>
        const EnhancedNotificationSystemInterface(),
    // TODO: Add your other routes here
  };
}

class ChemistDashboard extends StatelessWidget {
  const ChemistDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chemist Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_pharmacy,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Chemist Dashboard',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Pharmacy management features coming soon',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(
                context,
                '/authentication-entry',
              ),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
