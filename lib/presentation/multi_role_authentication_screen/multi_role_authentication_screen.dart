import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Assuming this contains AppTheme and other utils
import '../../services/auth_service.dart';
import './widgets/abha_input_widget.dart';
import './widgets/biometric_prompt_widget.dart';
import './widgets/language_selector_widget.dart';
import './widgets/password_input_widget.dart';
import './widgets/role_selector_widget.dart';

class MultiRoleAuthenticationScreen extends StatefulWidget {
  const MultiRoleAuthenticationScreen({super.key});

  @override
  State<MultiRoleAuthenticationScreen> createState() =>
      _MultiRoleAuthenticationScreenState();
}

class _MultiRoleAuthenticationScreenState
    extends State<MultiRoleAuthenticationScreen> with TickerProviderStateMixin {
  final TextEditingController _abhaController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _abhaFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final AuthService _authService = AuthService();

  String _selectedRole = 'patient';
  String _selectedLanguage = 'en';
  String? _abhaError;
  String? _passwordError;
  bool _isLoading = false;
  bool _showBiometricPrompt = false;
  bool _rememberMe = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupKeyboardListener();
    _checkExistingAuth();
  }

  void _checkExistingAuth() async {
    // FIX: Check authentication status through the AuthService for consistency.
    if (_authService.isAuthenticated) {
      final userProfile = await _authService.getCurrentUserProfile();
      if (mounted && userProfile != null) {
        _navigateToRoleDashboard(userProfile.role);
      }
    }
  }

  // --- THIS IS THE MAIN FIX ---
  Future<void> _handleLogin() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      // FIX: Call the correct new method `signInWithIdentifierAndPassword`
      final response = await _authService.signInWithIdentifierAndPassword(
        identifier: _abhaController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted && response.user != null) {
        final userProfile = await _authService.getCurrentUserProfile();
        
        // Navigate directly after successful login and profile fetch.
        // Your biometric logic can be re-integrated here if needed.
        if(mounted && userProfile != null) {
            _navigateToRoleDashboard(userProfile.role);
        } else {
            throw Exception('Could not retrieve user profile after login.');
        }
      }
    } on AuthException catch (e) {
      // FIX: Improved error handling to show clear messages from Supabase
      if (mounted) {
        setState(() {
          _passwordError = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _passwordError = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- THE REST OF THE FILE (with minor corrections) ---

  @override
  void dispose() {
    _abhaController.dispose();
    _passwordController.dispose();
    _abhaFocusNode.dispose();
    _passwordFocusNode.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Removed the duplicate, incomplete build method. This is the only one.
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                children: [
                  SizedBox(height: 4.h),
                  LanguageSelectorWidget(
                    selectedLanguage: _selectedLanguage,
                    onLanguageChanged: (language) => setState(() => _selectedLanguage = language),
                  ),
                  SizedBox(height: 4.h),
                  _buildLogoAndTitle(),
                  SizedBox(height: 4.h),
                  _buildSecurityIndicator(),
                  SizedBox(height: 4.h),
                  _showBiometricPrompt
                      ? _buildBiometricPrompt()
                      : _buildLoginForm(),
                  SizedBox(height: 4.h),
                  if (!_showBiometricPrompt) _buildNewUserRegistrationLink(),
                  SizedBox(height: 2.h),
                  if (!_showBiometricPrompt) _buildDemoCredentialsInfo(),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- UI BUILDER WIDGETS ---

  Widget _buildLoginForm() {
    return Column(
      children: [
        RoleSelectorWidget(
          selectedRole: _selectedRole,
          onRoleChanged: (role) {
            setState(() {
              _selectedRole = role;
              _abhaError = null;
              _passwordError = null;
            });
          },
        ),
        SizedBox(height: 4.h),
        if (_selectedRole != 'guest') ...[
          AbhaInputWidget(
            controller: _abhaController,
            errorText: _abhaError,
            focusNode: _abhaFocusNode,
            onChanged: (value) => setState(() => _abhaError = null),
          ),
          SizedBox(height: 3.h),
          PasswordInputWidget(
            controller: _passwordController,
            errorText: _passwordError,
            focusNode: _passwordFocusNode,
            onChanged: (value) => setState(() => _passwordError = null),
          ),
          SizedBox(height: 2.h),
          _buildRememberMeAndForgotPassword(),
          SizedBox(height: 4.h),
        ],
        _buildLoginButton(),
        SizedBox(height: 3.h),
        if (_selectedRole != 'guest') _buildGuestAccessButton(),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : (_selectedRole == 'guest' ? _handleGuestAccess : _handleLogin),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 2.5.h),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? _buildLoadingIndicator('Authenticating...')
            : _buildButtonContent(
                _selectedRole == 'guest' ? 'Explore as Guest' : 'Login Securely',
                _selectedRole == 'guest' ? 'explore' : 'login',
              ),
      ),
    );
  }
  
  // Other methods (_initializeAnimations, _setupKeyboardListener, _validateInputs, etc.)
  // can remain as they are in your original file.
  
  // --- HELPER AND NAVIGATION METHODS ---

  void _initializeAnimations() {
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _slideController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _fadeController.forward();
    _slideController.forward();
  }

  void _setupKeyboardListener() {
    _abhaFocusNode.addListener(_scrollToField);
    _passwordFocusNode.addListener(_scrollToField);
  }

  void _scrollToField() {
    if (_abhaFocusNode.hasFocus || _passwordFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), () {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  bool _validateInputs() {
    setState(() {
      _abhaError = null;
      _passwordError = null;
    });
    bool isValid = true;
    if (_selectedRole == 'guest') return true;
    if (_abhaController.text.isEmpty) {
      setState(() => _abhaError = 'Identifier is required');
      isValid = false;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      isValid = false;
    } else if (_passwordController.text.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      isValid = false;
    }
    return isValid;
  }

  void _navigateToRoleDashboard(String role) {
    HapticFeedback.lightImpact();
    String route;
    switch (role) {
      case 'patient':
        route = '/patient-dashboard';
        break;
      case 'doctor':
        route = '/doctor-dashboard';
        break;
      case 'chemist':
        route = '/chemist-dashboard';
        break;
      case 'guest':
        route = '/guest-dashboard';
        break;
      default:
        route = '/patient-dashboard';
    }
    Navigator.pushReplacementNamed(context, route);
  }

  void _handleGuestAccess() {
    setState(() => _selectedRole = 'guest');
    _navigateToRoleDashboard('guest');
  }

  // --- Placeholders for your other widgets and methods ---
  
  Widget _buildLogoAndTitle() => Column(children: [Text("AyurSutra", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))]);
  Widget _buildSecurityIndicator() => Container();
  Widget _buildBiometricPrompt() => BiometricPromptWidget(onBiometricSuccess: (){}, onSkip: (){});
  Widget _buildRememberMeAndForgotPassword() => Container();
  Widget _buildGuestAccessButton() => Container();
  Widget _buildNewUserRegistrationLink() => Container();
  Widget _buildDemoCredentialsInfo() => Container();

  Row _buildLoadingIndicator(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
          width: 5.w,
          height: 5.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.lightTheme.colorScheme.onPrimary),
          )),
      SizedBox(width: 3.w),
      Text(text,
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600)),
    ]);
  }
  
  Row _buildButtonContent(String text, String iconName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomIconWidget(iconName: iconName, color: AppTheme.lightTheme.colorScheme.onPrimary, size: 20),
        SizedBox(width: 2.w),
        Text(
          text,
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// Assuming these classes exist elsewhere in your project
class AppTheme { static final lightTheme = ThemeData.light(); }
class CustomIconWidget extends StatelessWidget {
  final String iconName; final Color color; final double size;
  const CustomIconWidget({required this.iconName, required this.color, required this.size, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Icon(Icons.login, color: color, size: size);
}