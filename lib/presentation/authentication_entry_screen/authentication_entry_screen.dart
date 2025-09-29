import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import './widgets/language_selector_widget.dart';

class AuthenticationEntryScreen extends StatefulWidget {
  const AuthenticationEntryScreen({super.key});

  @override
  State<AuthenticationEntryScreen> createState() => _AuthenticationEntryScreenState();
}

class _AuthenticationEntryScreenState extends State<AuthenticationEntryScreen> {
  String _selectedLanguage = 'en';
  bool _isLoading = false;
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  LanguageSelectorWidget(
                    selectedLanguage: _selectedLanguage,
                    onLanguageChanged: (String language) {
                      setState(() => _selectedLanguage = language);
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              Text(
                'Sign in to continue to your dashboard',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),

              const SizedBox(height: 40),

              // Demo Credentials Section
              _buildDemoCredentials(),

              const SizedBox(height: 30),

              // Login Form
              _buildLoginForm(),

              const SizedBox(height: 20),

              // Alternative Login Options
              _buildAlternativeOptions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoCredentials() {
    final credentials = AuthService.getDemoCredentialsForDisplay();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Demo Credentials',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        ...credentials.map((cred) => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cred['role']!,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _loginWithDemoCredentials(cred['role']!.toLowerCase()),
                    child: Text('Use This'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Email: ${cred['email']}'),
              Text('Password: ${cred['password']}'),
              Text('Mobile: ${cred['mobile']} | OTP: ${cred['otp']}'),
              Text('ABHA: ${cred['abha']} | OTP: ${cred['otp']}'),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Login with Email/Mobile/ABHA',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        
        // Identifier Input
        TextField(
          controller: _identifierController,
          decoration: InputDecoration(
            labelText: 'Email, Mobile, or ABHA ID',
            hintText: 'Enter your email, mobile number, or ABHA ID',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: Icon(Icons.account_circle_outlined),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Password Input
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Login Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handlePasswordLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                    'Sign In',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlternativeOptions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or continue with',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Mobile OTP Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => _navigateToMobileOTP(),
            icon: Icon(Icons.phone_outlined),
            label: Text('Continue with Mobile OTP'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // ABHA Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => _navigateToAbhaOTP(),
            icon: Icon(Icons.verified_user_outlined),
            label: Text('Continue with ABHA'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Create Account Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.accountCreationScreen),
            child: Text(
              'Create New Account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handlePasswordLogin() async {
    if (_identifierController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please enter both identifier and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final response = await authService.signInWithIdentifierAndPassword(
        identifier: _identifierController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null) {
        // Get user role and navigate to appropriate dashboard
        final role = response.user!.userMetadata?['role'] ?? 'patient';
        String route;
        switch (role.toLowerCase()) {
          case 'patient':
            route = AppRoutes.patientDashboard;
            break;
          case 'doctor':
            route = AppRoutes.doctorDashboard;
            break;
          case 'chemist':
            route = AppRoutes.chemistDashboard;
            break;
          default:
            route = AppRoutes.patientDashboard;
        }

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
        }
      }
    } catch (error) {
      _showError('Login failed: ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _loginWithDemoCredentials(String role) async {
    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final response = await authService.signInWithDemoCredentials(role);

      if (response.user != null) {
        String route;
        switch (role.toLowerCase()) {
          case 'patient':
            route = AppRoutes.patientDashboard;
            break;
          case 'doctor':
            route = AppRoutes.doctorDashboard;
            break;
          case 'chemist':
            route = AppRoutes.chemistDashboard;
            break;
          default:
            route = AppRoutes.patientDashboard;
        }

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
        }
      }
    } catch (error) {
      _showError('Demo login failed: ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToMobileOTP() {
    // Show dialog to enter mobile number
    showDialog(
      context: context,
      builder: (context) => _MobileInputDialog(
        onSubmit: (mobile) {
          Navigator.pushNamed(
            context,
            AppRoutes.otpVerificationScreen,
            arguments: {
              'verificationType': 'mobile',
              'isDemoMode': true,
              'identifier': mobile,
            },
          );
        },
      ),
    );
  }

  void _navigateToAbhaOTP() {
    // Show dialog to enter ABHA ID
    showDialog(
      context: context,
      builder: (context) => _AbhaInputDialog(
        onSubmit: (abha) {
          Navigator.pushNamed(
            context,
            AppRoutes.otpVerificationScreen,
            arguments: {
              'verificationType': 'abha',
              'isDemoMode': true,
              'identifier': abha,
            },
          );
        },
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

// Helper dialog for mobile input
class _MobileInputDialog extends StatefulWidget {
  final Function(String) onSubmit;

  const _MobileInputDialog({required this.onSubmit});

  @override
  State<_MobileInputDialog> createState() => _MobileInputDialogState();
}

class _MobileInputDialogState extends State<_MobileInputDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Mobile Number'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Mobile Number',
              hintText: 'Try: 9991199911 (Patient)',
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          Text(
            'Demo Numbers:\n9991199911 (Patient)\n9992299922 (Doctor)\n9993399933 (Chemist)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              Navigator.pop(context);
              widget.onSubmit(_controller.text.trim());
            }
          },
          child: Text('Continue'),
        ),
      ],
    );
  }
}

// Helper dialog for ABHA input
class _AbhaInputDialog extends StatefulWidget {
  final Function(String) onSubmit;

  const _AbhaInputDialog({required this.onSubmit});

  @override
  State<_AbhaInputDialog> createState() => _AbhaInputDialogState();
}

class _AbhaInputDialogState extends State<_AbhaInputDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter ABHA ID'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'ABHA ID',
              hintText: 'Try: demo.patient@abdm',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Demo ABHA IDs:\ndemo.patient@abdm\ndemo.doctor@abdm\ndemo.chemist@abdm',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              Navigator.pop(context);
              widget.onSubmit(_controller.text.trim());
            }
          },
          child: Text('Continue'),
        ),
      ],
    );
  }
}
