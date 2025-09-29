import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum PaymentStep {
  selectMethod,
  processing,
  success,
  failed,
}

class PaymentProgressIndicator extends StatefulWidget {
  final PaymentStep currentStep;
  final String? processingMessage;
  final String? estimatedTime;

  const PaymentProgressIndicator({
    super.key,
    required this.currentStep,
    this.processingMessage,
    this.estimatedTime,
  });

  @override
  State<PaymentProgressIndicator> createState() =>
      _PaymentProgressIndicatorState();
}

class _PaymentProgressIndicatorState extends State<PaymentProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.currentStep == PaymentStep.processing) {
      _progressController.repeat();
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PaymentProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentStep != oldWidget.currentStep) {
      if (widget.currentStep == PaymentStep.processing) {
        _progressController.repeat();
        _pulseController.repeat(reverse: true);
      } else {
        _progressController.stop();
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      child: Column(
        children: [
          _buildStepIndicator(theme),
          SizedBox(height: 2.h),
          _buildStepContent(theme),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(ThemeData theme) {
    return Row(
      children: [
        _buildStep(
          theme,
          1,
          'Select',
          widget.currentStep.index >= PaymentStep.selectMethod.index,
          widget.currentStep == PaymentStep.selectMethod,
        ),
        _buildConnector(
          theme,
          widget.currentStep.index > PaymentStep.selectMethod.index,
        ),
        _buildStep(
          theme,
          2,
          'Process',
          widget.currentStep.index >= PaymentStep.processing.index,
          widget.currentStep == PaymentStep.processing,
        ),
        _buildConnector(
          theme,
          widget.currentStep.index > PaymentStep.processing.index,
        ),
        _buildStep(
          theme,
          3,
          'Complete',
          widget.currentStep.index >= PaymentStep.success.index,
          widget.currentStep == PaymentStep.success ||
              widget.currentStep == PaymentStep.failed,
        ),
      ],
    );
  }

  Widget _buildStep(
    ThemeData theme,
    int stepNumber,
    String label,
    bool isCompleted,
    bool isActive,
  ) {
    Color stepColor;
    Widget stepIcon;

    if (widget.currentStep == PaymentStep.failed && stepNumber == 3) {
      stepColor = theme.colorScheme.error;
      stepIcon = CustomIconWidget(
        iconName: 'close',
        color: theme.colorScheme.onError,
        size: 16,
      );
    } else if (isCompleted && !isActive) {
      stepColor = theme.colorScheme.primary;
      stepIcon = CustomIconWidget(
        iconName: 'check',
        color: theme.colorScheme.onPrimary,
        size: 16,
      );
    } else if (isActive) {
      stepColor = theme.colorScheme.primary;
      stepIcon = isActive && widget.currentStep == PaymentStep.processing
          ? AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: CustomIconWidget(
                    iconName: 'sync',
                    color: theme.colorScheme.onPrimary,
                    size: 16,
                  ),
                );
              },
            )
          : Text(
              stepNumber.toString(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            );
    } else {
      stepColor = theme.colorScheme.outline.withValues(alpha: 0.3);
      stepIcon = Text(
        stepNumber.toString(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: stepColor,
              shape: BoxShape.circle,
              border: isActive
                  ? Border.all(
                      color: stepColor.withValues(alpha: 0.3),
                      width: 3,
                    )
                  : null,
            ),
            child: Center(child: stepIcon),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isActive || isCompleted
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector(ThemeData theme, bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        child: isActive
            ? Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(1),
                ),
              )
            : AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: widget.currentStep == PaymentStep.processing
                        ? _progressAnimation.value
                        : 0.0,
                    backgroundColor:
                        theme.colorScheme.outline.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildStepContent(ThemeData theme) {
    switch (widget.currentStep) {
      case PaymentStep.selectMethod:
        return _buildSelectMethodContent(theme);
      case PaymentStep.processing:
        return _buildProcessingContent(theme);
      case PaymentStep.success:
        return _buildSuccessContent(theme);
      case PaymentStep.failed:
        return _buildFailedContent(theme);
    }
  }

  Widget _buildSelectMethodContent(ThemeData theme) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: 'payment',
          color: theme.colorScheme.primary,
          size: 32,
        ),
        SizedBox(height: 1.h),
        Text(
          'Choose Payment Method',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Select your preferred payment method to continue',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProcessingContent(ThemeData theme) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _progressController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _progressController.value * 2 * 3.14159,
              child: CustomIconWidget(
                iconName: 'sync',
                color: theme.colorScheme.primary,
                size: 32,
              ),
            );
          },
        ),
        SizedBox(height: 2.h),
        Text(
          'Processing Payment',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        if (widget.processingMessage != null) ...[
          Text(
            widget.processingMessage!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
        ],
        if (widget.estimatedTime != null) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Est. ${widget.estimatedTime}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 1.h),
        ],
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'security',
                color: theme.colorScheme.tertiary,
                size: 16,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Your payment is secured with 256-bit SSL encryption',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 16.w,
          height: 16.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: CustomIconWidget(
            iconName: 'check_circle',
            color: theme.colorScheme.primary,
            size: 32,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Payment Successful!',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Your booking has been confirmed. You will receive a confirmation email shortly.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFailedContent(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 16.w,
          height: 16.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: CustomIconWidget(
            iconName: 'error',
            color: theme.colorScheme.error,
            size: 32,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Payment Failed',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'We couldn\'t process your payment. Please try again or use a different payment method.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
