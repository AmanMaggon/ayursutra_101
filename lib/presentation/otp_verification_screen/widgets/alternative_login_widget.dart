import 'package:flutter/material.dart';

class AlternativeLoginWidget extends StatelessWidget {
  final bool isDemoMode;
  final String currentType;
  final VoidCallback? onSwitchToPassword;
  final VoidCallback? onSwitchToAbha;
  final VoidCallback? onSwitchToMobile;

  const AlternativeLoginWidget({
    super.key,
    this.isDemoMode = false,
    required this.currentType,
    this.onSwitchToPassword,
    this.onSwitchToAbha,
    this.onSwitchToMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alternative Login Methods',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),

          const SizedBox(height: 16),

          // Alternative options
          if (currentType != 'mobile') ...[
            _buildAlternativeOption(
              context,
              icon: Icons.phone_outlined,
              title: 'Mobile OTP',
              subtitle: 'Login with mobile number',
              onTap: onSwitchToMobile,
            ),
            const SizedBox(height: 12),
          ],

          if (currentType != 'abha') ...[
            _buildAlternativeOption(
              context,
              icon: Icons.verified_user_outlined,
              title: 'ABHA ID',
              subtitle: 'Government verified identity',
              onTap: onSwitchToAbha,
            ),
            const SizedBox(height: 12),
          ],

          _buildAlternativeOption(
            context,
            icon: Icons.lock_outlined,
            title: 'Password Login',
            subtitle: 'Use email and password',
            onTap: onSwitchToPassword,
          ),

          if (isDemoMode) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .tertiary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Demo mode: All methods work with test credentials',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlternativeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
