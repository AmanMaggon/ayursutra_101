import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import './widgets/alternative_login_widget.dart';
import './widgets/demo_mode_banner_widget.dart';
import './widgets/otp_input_widget.dart';
import './widgets/resend_timer_widget.dart';
import '../authentication_entry_screen/widgets/language_selector_widget.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _selectedLanguage = 'en';
  bool _isLoading = false;
  String _otpCode = '';
  int _resendTimer = 180; // 3 minutes
  Timer? _timer;

  // Arguments from navigation
  String _verificationType = 'mobile'; // 'mobile', 'abha'
  bool _isDemoMode = false;
  String _identifier = '';

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get arguments from navigation
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _verificationType = args['verificationType'] ?? 'mobile';
      _isDemoMode = args['isDemoMode'] ?? false;
      _identifier = args['identifier'] ?? '';
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    _resendTimer = 180;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header with back button
              _buildHeader(),

              // Demo mode banner
              if (_isDemoMode) DemoModeBannerWidget(),

              // OTP verification content
              _buildOtpContent(),

              // OTP input
              OtpInputWidget(
                onChanged: (value) => setState(() => _otpCode = value),
                isDemoMode: _isDemoMode,
              ),

              const SizedBox(height: 24),

              // Resend timer
              ResendTimerWidget(
                remainingTime: _resendTimer,
                onResend: _handleResendOtp,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 32),

              // Verify button
              _buildVerifyButton(),

              const SizedBox(height: 24),

              // Alternative login options
              AlternativeLoginWidget(
                isDemoMode: _isDemoMode,
                currentType: _verificationType,
                onSwitchToPassword: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.authenticationEntryScreen,
                ),
                onSwitchToAbha: () => _switchVerificationType('abha'),
                onSwitchToMobile: () => _switchVerificationType('mobile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back),
          ),
          Expanded(
            child: Text(
              'Verify ${_verificationType == 'mobile' ? 'Mobile' : 'ABHA ID'}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          // Language selector
          LanguageSelectorWidget(
            selectedLanguage: _selectedLanguage,
            onLanguageChanged: (String language) {
              setState(() => _selectedLanguage = language);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOtpContent() {
    return Column(
      children: [
        // Verification icon
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          ),
          child: Icon(
            _verificationType == 'mobile'
                ? Icons.phone_outlined
                : Icons.verified_user_outlined,
            size: 40,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),

        const SizedBox(height: 24),

        // Title
        Text(
          'Enter Verification Code',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          _verificationType == 'mobile'
              ? 'We sent a 6-digit code to your mobile number'
              : 'We sent a 6-digit code to verify your ABHA ID',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),

        if (_isDemoMode) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .tertiary
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Demo Mode: Use ANY 6-digit OTP',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed:
            (_isLoading || _otpCode.length != 6) ? null : _handleVerifyOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : Text(
                'Verify & Continue',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
      ),
    );
  }

  // 🔥 BYPASS METHOD - Goes straight to dashboard
  void _handleVerifyOtp() async {
    if (_isLoading || _otpCode.length != 6) return;

    setState(() => _isLoading = true);

    try {
      print('BYPASS: Skipping all auth, going directly to dashboard');
      
      // Just wait a second to simulate loading
      await Future.delayed(Duration(seconds: 1));
      
      // Go directly to patient dashboard - NO AUTH NEEDED
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.patientDashboard, // Using your AppRoutes
          (route) => false,
        );
      }
    } catch (error) {
      print('Even bypass failed: $error');
      // Still go to dashboard anyway
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.patientDashboard,
          (route) => false,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleResendOtp() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      print('BYPASS: Fake resend OTP');
      await Future.delayed(Duration(seconds: 1));
      
      _startResendTimer();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'BYPASS: Fake OTP sent successfully!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      print('Even resend bypass failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _switchVerificationType(String newType) {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.otpVerificationScreen,
      arguments: {
        'verificationType': newType,
        'isDemoMode': _isDemoMode,
        'identifier': _identifier,
      },
    );
  }
}
