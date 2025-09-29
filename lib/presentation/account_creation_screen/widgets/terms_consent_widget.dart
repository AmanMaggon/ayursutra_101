import 'package:flutter/material.dart';

class TermsConsentWidget extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(Map<String, dynamic>) onDataChanged;

  const TermsConsentWidget({
    super.key,
    required this.formData,
    required this.onDataChanged,
  });

  @override
  State<TermsConsentWidget> createState() => _TermsConsentWidgetState();
}

class _TermsConsentWidgetState extends State<TermsConsentWidget> {
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  bool _dataProcessingConsent = false;
  bool _abhaDataSharingConsent = false;
  bool _marketingConsent = false;

  @override
  void initState() {
    super.initState();
    _termsAccepted = widget.formData['termsAccepted'] ?? false;
    _privacyAccepted = widget.formData['privacyAccepted'] ?? false;
    _dataProcessingConsent = widget.formData['dataProcessingConsent'] ?? false;
    _abhaDataSharingConsent =
        widget.formData['abhaDataSharingConsent'] ?? false;
    _marketingConsent = widget.formData['marketingConsent'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Terms & Consent',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please review and accept our terms to complete your account setup',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),

          // Required Consents
          _buildSectionHeader('Required Consents', true),

          _buildConsentItem(
            title: 'Terms of Service',
            description:
                'I agree to the AyurSutra Terms of Service and User Agreement',
            value: _termsAccepted,
            onChanged: (value) {
              setState(() {
                _termsAccepted = value;
              });
              _updateFormData();
            },
            isRequired: true,
            linkText: 'Read Terms of Service',
            onLinkTap: () => _showTermsDialog(),
          ),

          _buildConsentItem(
            title: 'Privacy Policy',
            description:
                'I have read and accept the Privacy Policy regarding data handling',
            value: _privacyAccepted,
            onChanged: (value) {
              setState(() {
                _privacyAccepted = value;
              });
              _updateFormData();
            },
            isRequired: true,
            linkText: 'Read Privacy Policy',
            onLinkTap: () => _showPrivacyDialog(),
          ),

          _buildConsentItem(
            title: 'Healthcare Data Processing',
            description:
                'I consent to processing of my healthcare data for treatment purposes',
            value: _dataProcessingConsent,
            onChanged: (value) {
              setState(() {
                _dataProcessingConsent = value;
              });
              _updateFormData();
            },
            isRequired: true,
            linkText: 'Learn about data processing',
            onLinkTap: () => _showDataProcessingDialog(),
          ),

          const SizedBox(height: 24),

          // ABHA Specific Consents
          if (widget.formData['isAbhaLinked'] == true) ...[
            _buildSectionHeader('ABHA Data Sharing', true),
            _buildConsentItem(
              title: 'ABHA Data Sharing',
              description:
                  'I consent to sharing my ABHA health records with AyurSutra for treatment coordination',
              value: _abhaDataSharingConsent,
              onChanged: (value) {
                setState(() {
                  _abhaDataSharingConsent = value;
                });
                _updateFormData();
              },
              isRequired: true,
              linkText: 'Understand ABHA sharing',
              onLinkTap: () => _showAbhaConsentDialog(),
            ),
            const SizedBox(height: 24),
          ],

          // Optional Consents
          _buildSectionHeader('Optional Consents', false),

          _buildConsentItem(
            title: 'Marketing Communications',
            description:
                'I agree to receive health tips, wellness updates, and promotional content',
            value: _marketingConsent,
            onChanged: (value) {
              setState(() {
                _marketingConsent = value;
              });
              _updateFormData();
            },
            isRequired: false,
            linkText: 'Communication preferences',
            onLinkTap: () => _showMarketingDialog(),
          ),

          const SizedBox(height: 32),

          // Important Information
          _buildImportantInfo(),

          const SizedBox(height: 32),

          // Data Rights Information
          _buildDataRightsInfo(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          if (isRequired) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Required',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConsentItem({
    required String title,
    required String description,
    required bool value,
    required Function(bool) onChanged,
    required bool isRequired,
    required String linkText,
    required VoidCallback onLinkTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRequired && !value
              ? Theme.of(context).colorScheme.error.withValues(alpha: 0.5)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: value,
                onChanged: (newValue) => onChanged(newValue ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onLinkTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                linkText,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.tertiary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Important Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• You can withdraw consent anytime from account settings\n'
            '• Your healthcare data is encrypted and stored securely\n'
            '• We never share your data without explicit consent\n'
            '• You maintain full control over your health information',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRightsInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Data Rights',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Under Indian data protection regulations, you have the right to:\n\n'
            '• Access your personal data\n'
            '• Correct inaccurate information\n'
            '• Delete your account and data\n'
            '• Port your data to another service\n'
            '• Withdraw consent at any time\n'
            '• File complaints with data protection authorities',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Terms of Service'),
        content: SingleChildScrollView(
          child: Text(
            'AyurSutra Terms of Service\n\n'
            '1. Acceptance of Terms\n'
            'By using AyurSutra, you agree to these terms.\n\n'
            '2. Medical Disclaimer\n'
            'AyurSutra is a management platform. Always consult healthcare professionals.\n\n'
            '3. User Responsibilities\n'
            'Provide accurate information and use the platform responsibly.\n\n'
            '4. Privacy & Data Protection\n'
            'We protect your data according to our Privacy Policy.\n\n'
            '5. Service Availability\n'
            'We strive for 99.9% uptime but cannot guarantee uninterrupted service.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Text(
            'AyurSutra Privacy Policy\n\n'
            '1. Data Collection\n'
            'We collect only necessary health and personal information.\n\n'
            '2. Data Use\n'
            'Your data is used for treatment coordination and service improvement.\n\n'
            '3. Data Sharing\n'
            'We never share data without your explicit consent.\n\n'
            '4. Data Security\n'
            'Industry-standard encryption protects your information.\n\n'
            '5. Your Rights\n'
            'You can access, modify, or delete your data anytime.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDataProcessingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Healthcare Data Processing'),
        content: SingleChildScrollView(
          child: Text(
            'Healthcare Data Processing Consent\n\n'
            'We process your healthcare data to:\n\n'
            '• Coordinate Panchakarma treatments\n'
            '• Track therapy progress\n'
            '• Manage prescriptions\n'
            '• Provide care instructions\n'
            '• Generate health reports\n\n'
            'All processing follows medical confidentiality standards and data protection regulations.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAbhaConsentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ABHA Data Sharing'),
        content: SingleChildScrollView(
          child: Text(
            'ABHA Data Sharing Consent\n\n'
            'By linking your ABHA ID, you consent to:\n\n'
            '• Sharing health records with AyurSutra providers\n'
            '• Automatic data synchronization\n'
            '• Treatment history integration\n'
            '• Prescription data sharing\n\n'
            'You can revoke this consent anytime, but it may affect service quality.\n\n'
            'All data sharing follows ABDM guidelines and maintains full audit trails.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMarketingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Marketing Communications'),
        content: SingleChildScrollView(
          child: Text(
            'Marketing Communications Consent\n\n'
            'If you opt-in, you\'ll receive:\n\n'
            '• Ayurvedic health tips\n'
            '• Wellness newsletters\n'
            '• Therapy recommendations\n'
            '• Seasonal health advice\n'
            '• Platform updates\n\n'
            'You can unsubscribe anytime from any communication.\n\n'
            'This is completely optional and doesn\'t affect your treatment.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _updateFormData() {
    widget.onDataChanged({
      'termsAccepted': _termsAccepted,
      'privacyAccepted': _privacyAccepted,
      'dataProcessingConsent': _dataProcessingConsent,
      'abhaDataSharingConsent': _abhaDataSharingConsent,
      'marketingConsent': _marketingConsent,
      'consentGiven': _termsAccepted &&
          _privacyAccepted &&
          _dataProcessingConsent &&
          (widget.formData['isAbhaLinked'] != true || _abhaDataSharingConsent),
    });
  }
}
