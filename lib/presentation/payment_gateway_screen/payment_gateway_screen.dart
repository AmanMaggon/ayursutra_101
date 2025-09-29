import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/booking_summary_card.dart';
import './widgets/coupon_code_section.dart';
import './widgets/payment_method_card.dart';
import './widgets/payment_progress_indicator.dart';

class PaymentGatewayScreen extends StatefulWidget {
  const PaymentGatewayScreen({super.key});

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  PaymentMethodType? _selectedPaymentMethod;
  Map<String, dynamic>? _paymentData;
  PaymentStep _currentStep = PaymentStep.selectMethod;
  double _discountAmount = 0.0;
  bool _isProcessing = false;
  String? _transactionId;

  final Map<String, dynamic> _bookingData = {
    'therapyName': 'Panchakarma Complete Package',
    'duration': '21 Days',
    'startDate': '15 Oct 2024',
    'centerName': 'Ayurveda Wellness Center, Mumbai',
    'baseAmount': 45000.0,
    'gstAmount': 8100.0,
    'discountAmount': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.95),
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              _buildHeader(context, theme),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      PaymentProgressIndicator(
                        currentStep: _currentStep,
                        processingMessage: _getProcessingMessage(),
                        estimatedTime: _getEstimatedTime(),
                      ),
                      if (_currentStep == PaymentStep.selectMethod) ...[
                        BookingSummaryCard(bookingData: _bookingData),
                        CouponCodeSection(
                          onDiscountApplied: _onDiscountApplied,
                          originalAmount:
                              (_bookingData['baseAmount'] as double) +
                                  (_bookingData['gstAmount'] as double),
                        ),
                        _buildPaymentMethods(theme),
                        SizedBox(height: 2.h),
                        _buildSecurityInfo(theme),
                        SizedBox(height: 2.h),
                        _buildRefundPolicy(theme),
                      ] else if (_currentStep == PaymentStep.success) ...[
                        _buildSuccessContent(theme),
                      ] else if (_currentStep == PaymentStep.failed) ...[
                        _buildFailureContent(theme),
                      ],
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: _buildBottomSheet(context, theme),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.all(2.w),
              child: CustomIconWidget(
                iconName: 'arrow_back',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Payment',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Complete your booking payment',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'security',
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  'SSL Secured',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Text(
            'Choose Payment Method',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        PaymentMethodCard(
          type: PaymentMethodType.upi,
          isSelected: _selectedPaymentMethod == PaymentMethodType.upi,
          onTap: () => _selectPaymentMethod(PaymentMethodType.upi),
          onPaymentDataChanged: _onPaymentDataChanged,
        ),
        PaymentMethodCard(
          type: PaymentMethodType.card,
          isSelected: _selectedPaymentMethod == PaymentMethodType.card,
          onTap: () => _selectPaymentMethod(PaymentMethodType.card),
          onPaymentDataChanged: _onPaymentDataChanged,
        ),
        PaymentMethodCard(
          type: PaymentMethodType.netBanking,
          isSelected: _selectedPaymentMethod == PaymentMethodType.netBanking,
          onTap: () => _selectPaymentMethod(PaymentMethodType.netBanking),
          onPaymentDataChanged: _onPaymentDataChanged,
        ),
        PaymentMethodCard(
          type: PaymentMethodType.wallet,
          isSelected: _selectedPaymentMethod == PaymentMethodType.wallet,
          onTap: () => _selectPaymentMethod(PaymentMethodType.wallet),
          onPaymentDataChanged: _onPaymentDataChanged,
        ),
      ],
    );
  }

  Widget _buildSecurityInfo(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'verified_user',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Your Payment is Protected',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildSecurityFeature(
                  theme,
                  'lock',
                  '256-bit SSL\nEncryption',
                ),
              ),
              Expanded(
                child: _buildSecurityFeature(
                  theme,
                  'account_balance',
                  'RBI Approved\nGateways',
                ),
              ),
              Expanded(
                child: _buildSecurityFeature(
                  theme,
                  'shield',
                  'PCI DSS\nCompliant',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFeature(ThemeData theme, String icon, String text) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        SizedBox(height: 1.h),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRefundPolicy(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: InkWell(
        onTap: _showRefundPolicy,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'policy',
                color: theme.colorScheme.tertiary,
                size: 20,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'View Refund & Cancellation Policy',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.tertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              CustomIconWidget(
                iconName: 'arrow_forward_ios',
                color: theme.colorScheme.tertiary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessContent(ThemeData theme) {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: 'check_circle',
              color: theme.colorScheme.primary,
              size: 48,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Payment Successful!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Your Panchakarma therapy booking has been confirmed',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildSuccessDetail(
                    'Transaction ID',
                    _transactionId ??
                        'TXN${DateTime.now().millisecondsSinceEpoch}'),
                _buildSuccessDetail('Amount Paid',
                    '₹${_formatIndianCurrency(_getTotalAmount())}'),
                _buildSuccessDetail('Booking Date', '15 Oct 2024'),
                _buildSuccessDetail('Therapy Duration', '21 Days'),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _downloadReceipt,
                  icon: CustomIconWidget(
                    iconName: 'download',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  label: const Text('Download Receipt'),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _viewBookingDetails,
                  icon: CustomIconWidget(
                    iconName: 'calendar_today',
                    color: theme.colorScheme.onPrimary,
                    size: 20,
                  ),
                  label: const Text('View Booking'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessDetail(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureContent(ThemeData theme) {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: 'error',
              color: theme.colorScheme.error,
              size: 48,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Payment Failed',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.error,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'We couldn\'t process your payment. Please try again with a different payment method.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Common reasons for payment failure:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 1.h),
                _buildFailureReason('• Insufficient balance in account'),
                _buildFailureReason('• Incorrect card details or expired card'),
                _buildFailureReason('• Network connectivity issues'),
                _buildFailureReason('• Bank server temporarily unavailable'),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _contactSupport,
                  icon: CustomIconWidget(
                    iconName: 'support_agent',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  label: const Text('Contact Support'),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _retryPayment,
                  icon: CustomIconWidget(
                    iconName: 'refresh',
                    color: theme.colorScheme.onPrimary,
                    size: 20,
                  ),
                  label: const Text('Try Again'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFailureReason(String reason) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          reason,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context, ThemeData theme) {
    if (_currentStep != PaymentStep.selectMethod) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '₹${_formatIndianCurrency(_getTotalAmount())}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: _selectedPaymentMethod != null && !_isProcessing
                    ? _processPayment
                    : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 5.w,
                            height: 5.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'Processing...',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'lock',
                            color: theme.colorScheme.onPrimary,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Pay Now - ₹${_formatIndianCurrency(_getTotalAmount())}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectPaymentMethod(PaymentMethodType method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
    HapticFeedback.lightImpact();
  }

  void _onPaymentDataChanged(Map<String, dynamic> data) {
    setState(() {
      _paymentData = data;
    });
  }

  void _onDiscountApplied(double discount) {
    setState(() {
      _discountAmount = discount;
      _bookingData['discountAmount'] = discount;
    });
  }

  double _getTotalAmount() {
    final baseAmount = _bookingData['baseAmount'] as double;
    final gstAmount = _bookingData['gstAmount'] as double;
    return baseAmount + gstAmount - _discountAmount;
  }

  String _formatIndianCurrency(double amount) {
    final formatter = amount.toStringAsFixed(0);
    final length = formatter.length;

    if (length <= 3) return formatter;

    String result = '';
    int count = 0;

    for (int i = length - 1; i >= 0; i--) {
      if (count == 3 || (count > 3 && (count - 3) % 2 == 0)) {
        result = ',$result';
      }
      result = formatter[i] + result;
      count++;
    }

    return result;
  }

  String? _getProcessingMessage() {
    if (_selectedPaymentMethod == null) return null;

    switch (_selectedPaymentMethod!) {
      case PaymentMethodType.upi:
        return 'Redirecting to your UPI app...';
      case PaymentMethodType.card:
        return 'Verifying card details with bank...';
      case PaymentMethodType.netBanking:
        return 'Connecting to bank server...';
      case PaymentMethodType.wallet:
        return 'Processing wallet payment...';
    }
  }

  String? _getEstimatedTime() {
    if (_selectedPaymentMethod == null) return null;

    switch (_selectedPaymentMethod!) {
      case PaymentMethodType.upi:
        return '30 seconds';
      case PaymentMethodType.card:
        return '2-3 minutes';
      case PaymentMethodType.netBanking:
        return '3-5 minutes';
      case PaymentMethodType.wallet:
        return '1 minute';
    }
  }

  void _processPayment() async {
    if (_selectedPaymentMethod == null) return;

    setState(() {
      _isProcessing = true;
      _currentStep = PaymentStep.processing;
    });

    HapticFeedback.mediumImpact();

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 3));

    // Simulate payment result (90% success rate)
    final isSuccess = DateTime.now().millisecond % 10 != 0;

    setState(() {
      _isProcessing = false;
      _currentStep = isSuccess ? PaymentStep.success : PaymentStep.failed;
      if (isSuccess) {
        _transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
      }
    });

    if (isSuccess) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.vibrate();
    }
  }

  void _retryPayment() {
    setState(() {
      _currentStep = PaymentStep.selectMethod;
      _selectedPaymentMethod = null;
      _paymentData = null;
      _isProcessing = false;
      _transactionId = null;
    });
  }

  void _downloadReceipt() {
    // Implement receipt download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Receipt downloaded successfully'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _viewBookingDetails() {
    Navigator.pushReplacementNamed(context, '/patient-dashboard');
  }

  void _contactSupport() {
    // Implement support contact
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Redirecting to support chat...'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showRefundPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRefundPolicySheet(),
    );
  }

  Widget _buildRefundPolicySheet() {
    final theme = Theme.of(context);

    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Refund & Cancellation Policy',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: theme.colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPolicySection(
                    'Cancellation Policy',
                    '• Free cancellation up to 48 hours before treatment\n'
                        '• 50% refund for cancellations 24-48 hours before\n'
                        '• 25% refund for cancellations within 24 hours\n'
                        '• No refund for no-shows or same-day cancellations',
                  ),
                  SizedBox(height: 3.h),
                  _buildPolicySection(
                    'Refund Process',
                    '• Refunds will be processed within 5-7 business days\n'
                        '• Amount will be credited to the original payment method\n'
                        '• Processing fees (if any) are non-refundable\n'
                        '• Partial treatments are eligible for pro-rated refunds',
                  ),
                  SizedBox(height: 3.h),
                  _buildPolicySection(
                    'Medical Emergencies',
                    '• Full refund available with valid medical certificate\n'
                        '• Treatment can be rescheduled without additional charges\n'
                        '• Emergency cancellations are handled case-by-case',
                  ),
                  SizedBox(height: 3.h),
                  _buildPolicySection(
                    'Contact Information',
                    'For cancellations and refunds:\n'
                        '• Email: support@panchakarmaflow.com\n'
                        '• Phone: +91 98765 43210\n'
                        '• Available: 9 AM - 6 PM (Mon-Sat)',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          content,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
