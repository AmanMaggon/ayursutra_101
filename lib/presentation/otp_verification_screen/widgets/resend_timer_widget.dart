import 'package:flutter/material.dart';

class ResendTimerWidget extends StatelessWidget {
  final int remainingTime;
  final VoidCallback? onResend;
  final bool isLoading;

  const ResendTimerWidget({
    super.key,
    required this.remainingTime,
    this.onResend,
    this.isLoading = false,
  });

  String get _formattedTime {
    final minutes = remainingTime ~/ 60;
    final seconds = remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 20,
                color: remainingTime > 0
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                remainingTime > 0
                    ? 'Resend OTP in $_formattedTime'
                    : 'You can now resend OTP',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: remainingTime > 0
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          if (remainingTime == 0) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: isLoading ? null : onResend,
              child: Text(
                isLoading ? 'Sending...' : 'Resend OTP',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
