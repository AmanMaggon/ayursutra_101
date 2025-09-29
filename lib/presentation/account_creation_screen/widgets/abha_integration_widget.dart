import 'package:flutter/material.dart';

class AbhaIntegrationWidget extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(Map<String, dynamic>) onDataChanged;

  const AbhaIntegrationWidget({
    super.key,
    required this.formData,
    required this.onDataChanged,
  });

  @override
  State<AbhaIntegrationWidget> createState() => _AbhaIntegrationWidgetState();
}

class _AbhaIntegrationWidgetState extends State<AbhaIntegrationWidget> {
  final _abhaController = TextEditingController();
  bool _isLinkingAbha = false;
  bool _isAbhaLinked = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _abhaController.text = widget.formData['abhaId'] ?? '';
    _isAbhaLinked = widget.formData['isAbhaLinked'] ?? false;
  }

  @override
  void dispose() {
    _abhaController.dispose();
    super.dispose();
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
            'ABHA ID Integration',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Link your Ayushman Bharat Health Account for seamless healthcare access',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),

          // ABHA Info Card
          _buildAbhaInfoCard(),
          const SizedBox(height: 24),

          // ABHA Linking Section
          if (!_isAbhaLinked) ...[
            _buildAbhaLinkingSection(),
          ] else ...[
            _buildAbhaLinkedSection(),
          ],

          const SizedBox(height: 24),

          // Benefits Section
          _buildBenefitsSection(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAbhaInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.verified_user,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ABHA ID',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    Text(
                      'Government-issued digital health ID',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'GOVT',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Your ABHA ID enables secure, interoperable health records across all healthcare providers in India.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbhaLinkingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Link ABHA ID (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 16),

        // ABHA ID Input
        TextFormField(
          controller: _abhaController,
          decoration: InputDecoration(
            labelText: 'ABHA ID / Health ID',
            hintText: '14-digit ABHA ID or Health ID@sbx',
            prefixIcon: Icon(Icons.credit_card_outlined),
            suffixIcon: _isVerifying
                ? Container(
                    width: 20,
                    height: 20,
                    padding: const EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          keyboardType: TextInputType.text,
          onChanged: (_) => _updateFormData(),
        ),
        const SizedBox(height: 16),

        // Link Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLinkingAbha || _abhaController.text.isEmpty
                ? null
                : _linkAbhaId,
            icon: _isLinkingAbha
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Icon(Icons.link),
            label: Text(_isLinkingAbha ? 'Linking...' : 'Link ABHA ID'),
          ),
        ),
        const SizedBox(height: 12),

        // Skip Option
        Center(
          child: TextButton(
            onPressed: () {
              widget.onDataChanged({'abhaId': '', 'isAbhaLinked': false});
            },
            child: Text(
              'Skip for now',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAbhaLinkedSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.tertiary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ABHA ID Successfully Linked',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.credit_card,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _abhaController.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _unlinkAbhaId,
            icon: Icon(Icons.link_off, size: 16),
            label: Text('Unlink ABHA ID'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    final benefits = [
      {
        'icon': Icons.security,
        'title': 'Secure Identity',
        'description': 'Government-verified digital health identity',
      },
      {
        'icon': Icons.swap_horiz,
        'title': 'Interoperability',
        'description': 'Access health records across all providers',
      },
      {
        'icon': Icons.history,
        'title': 'Health History',
        'description': 'Maintain comprehensive medical records',
      },
      {
        'icon': Icons.shield,
        'title': 'Privacy Control',
        'description': 'You control who accesses your data',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ABHA Benefits',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 16),
        ...benefits.map((benefit) => _buildBenefitItem(
              benefit['icon'] as IconData,
              benefit['title'] as String,
              benefit['description'] as String,
            )),
      ],
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _linkAbhaId() async {
    setState(() {
      _isLinkingAbha = true;
    });

    try {
      // Simulate ABHA verification
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isAbhaLinked = true;
        _isLinkingAbha = false;
      });

      _updateFormData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ABHA ID linked successfully!'),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
      );
    } catch (error) {
      setState(() {
        _isLinkingAbha = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to link ABHA ID. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _unlinkAbhaId() {
    setState(() {
      _isAbhaLinked = false;
      _abhaController.clear();
    });
    _updateFormData();
  }

  void _updateFormData() {
    widget.onDataChanged({
      'abhaId': _abhaController.text,
      'isAbhaLinked': _isAbhaLinked,
    });
  }
}
