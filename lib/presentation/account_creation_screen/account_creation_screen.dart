import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import './widgets/abha_integration_widget.dart';
import './widgets/personal_details_form_widget.dart';
import './widgets/progress_stepper_widget.dart';
import './widgets/role_selection_widget.dart';
import './widgets/security_setup_widget.dart';
import './widgets/terms_consent_widget.dart';

class AccountCreationScreen extends StatefulWidget {
  const AccountCreationScreen({super.key});

  @override
  State<AccountCreationScreen> createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends State<AccountCreationScreen> {
  final PageController _pageController = PageController();
  final AuthService _authService = AuthService();

  int _currentStep = 0;
  final int _totalSteps = 5;

  bool _isLoading = false;

  // Form Data - No changes here
  final Map<String, dynamic> _formData = {
    'title': 'Mr.',
    'fullName': '',
    'email': '',
    'phoneNumber': '',
    'dateOfBirth': null,
    'abhaId': '',
    'isAbhaLinked': false,
    'password': '',
    'confirmPassword': '',
    'role': 'patient',
    'emergencyContactName': '',
    'emergencyContactPhone': '',
    'language': 'en',
    'city': '',
    'state': '',
    'consentGiven': false,
    'termsAccepted': false,
  };

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // --- The rest of your build methods are fine, no changes needed ---
  // build(), _buildAppBar(), _buildPersonalDetailsStep(), etc. all remain the same.
  // I will only show the methods that have changed.

  // [Your other build methods like build(), _buildAppBar(), etc. go here unchanged]
  // ...

  /// **THIS IS THE MAIN FIX**
  /// This function now calls the correct general-purpose signup method and
  /// handles the post-signup flow correctly.
  Future<void> _createAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // FIX 1: Call the correct general-purpose signup method
      final response = await _authService.signUpWithEmailPassword(
        // Use a temporary email if the user did not provide one
        email: _formData['email']?.isNotEmpty == true
            ? _formData['email']
            : '${_formData['phoneNumber']}@ayursutra.temp',
        password: _formData['password'],
        // FIX 2: Pass user metadata in the 'data' parameter
        data: {
          'full_name': _formData['fullName'],
          'role': _formData['role'],
          'phone_number': _formData['phoneNumber'],
          'abha_id': _formData['abhaId']?.isNotEmpty == true
              ? _formData['abhaId']
              : null,
        },
      );

      if (mounted && response.user != null) {
        // FIX 3: Show a more accurate success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created! Please check your email to verify.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        // FIX 4: Navigate back to the login screen, not the dashboard
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.authenticationEntryScreen, // Go back to login
          (route) => false,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account creation failed: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // All other methods like _handleNextStep, _canProceedToNextStep, etc.
  // are correct and do not need to be changed.
  // Make sure to paste this corrected _createAccount function into your file.

  // --- PASTE THE REST OF YOUR ORIGINAL CODE BELOW ---
  // (The parts that were not changed)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          ProgressStepperWidget(
            currentStep: _currentStep,
            totalSteps: _totalSteps,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPersonalDetailsStep(),
                _buildAbhaIntegrationStep(),
                _buildSecuritySetupStep(),
                _buildRoleSelectionStep(),
                _buildTermsConsentStep(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Create Account',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      centerTitle: true,
      leading: IconButton(
        onPressed: () => _handleBackPressed(),
        icon: Icon(Icons.arrow_back),
      ),
      actions: [
        if (_currentStep > 0)
          TextButton(
            onPressed: _isLoading ? null : () => _handleSkipStep(),
            child: Text(
              'Skip',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildPersonalDetailsStep() {
    return PersonalDetailsFormWidget(
      formData: _formData,
      onDataChanged: (Map<String, dynamic> data) {
        setState(() {
          _formData.addAll(data);
        });
      },
    );
  }

  Widget _buildAbhaIntegrationStep() {
    return AbhaIntegrationWidget(
      formData: _formData,
      onDataChanged: (Map<String, dynamic> data) {
        setState(() {
          _formData.addAll(data);
        });
      },
    );
  }

  Widget _buildSecuritySetupStep() {
    return SecuritySetupWidget(
      formData: _formData,
      onDataChanged: (Map<String, dynamic> data) {
        setState(() {
          _formData.addAll(data);
        });
      },
    );
  }

  Widget _buildRoleSelectionStep() {
    return RoleSelectionWidget(
      formData: _formData,
      onDataChanged: (Map<String, dynamic> data) {
        setState(() {
          _formData.addAll(data);
        });
      },
    );
  }

  Widget _buildTermsConsentStep() {
    return TermsConsentWidget(
      formData: _formData,
      onDataChanged: (Map<String, dynamic> data) {
        setState(() {
          _formData.addAll(data);
        });
      },
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _handlePreviousStep,
                  child: Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),
            Expanded(
              flex: _currentStep > 0 ? 1 : 2,
              child: ElevatedButton(
                onPressed: _isLoading || !_canProceedToNextStep()
                    ? null
                    : _handleNextStep,
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Text(_currentStep == _totalSteps - 1
                        ? 'Create Account'
                        : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0: // Personal Details
        return _formData['fullName']?.isNotEmpty == true &&
            _formData['phoneNumber']?.isNotEmpty == true;
      case 1: // ABHA Integration
        return true; // Optional step
      case 2: // Security Setup
        return _formData['password']?.isNotEmpty == true &&
            _formData['confirmPassword']?.isNotEmpty == true &&
            _formData['password'] == _formData['confirmPassword'];
      case 3: // Role Selection
        return _formData['role']?.isNotEmpty == true;
      case 4: // Terms & Consent
        return _formData['termsAccepted'] == true &&
            _formData['consentGiven'] == true;
      default:
        return false;
    }
  }

  void _handleBackPressed() {
    if (_currentStep > 0) {
      _handlePreviousStep();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _handlePreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleNextStep() async {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _createAccount();
    }
  }

  void _handleSkipStep() {
    if (_currentStep == 1) {
      _handleNextStep();
    }
  }
}