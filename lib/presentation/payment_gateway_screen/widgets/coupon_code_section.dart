import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CouponCodeSection extends StatefulWidget {
  final Function(double) onDiscountApplied;
  final double originalAmount;

  const CouponCodeSection({
    super.key,
    required this.onDiscountApplied,
    required this.originalAmount,
  });

  @override
  State<CouponCodeSection> createState() => _CouponCodeSectionState();
}

class _CouponCodeSectionState extends State<CouponCodeSection> {
  final TextEditingController _couponController = TextEditingController();
  bool _isApplying = false;
  bool _isApplied = false;
  String? _appliedCoupon;
  double _discountAmount = 0.0;
  String? _errorMessage;

  final List<Map<String, dynamic>> _availableCoupons = [
    {
      'code': 'FIRST20',
      'description': '20% off on first booking',
      'discount': 0.20,
      'minAmount': 10000.0,
      'maxDiscount': 10000.0,
      'type': 'percentage',
    },
    {
      'code': 'WELLNESS15',
      'description': '15% off on wellness packages',
      'discount': 0.15,
      'minAmount': 25000.0,
      'maxDiscount': 7500.0,
      'type': 'percentage',
    },
    {
      'code': 'SAVE5000',
      'description': 'Flat ₹5,000 off',
      'discount': 5000.0,
      'minAmount': 30000.0,
      'maxDiscount': 5000.0,
      'type': 'flat',
    },
    {
      'code': 'AYURVEDA10',
      'description': '10% off on Ayurveda treatments',
      'discount': 0.10,
      'minAmount': 15000.0,
      'maxDiscount': 5000.0,
      'type': 'percentage',
    },
  ];

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'local_offer',
                color: theme.colorScheme.tertiary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Apply Coupon Code',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (!_isApplied) ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code',
                      prefixIcon: CustomIconWidget(
                        iconName: 'confirmation_number',
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 20,
                      ),
                      errorText: _errorMessage,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                SizedBox(width: 3.w),
                SizedBox(
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _isApplying ? null : _applyCoupon,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isApplying
                        ? SizedBox(
                            width: 4.w,
                            height: 4.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Text(
                            'Apply',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildAvailableCoupons(theme),
          ] else ...[
            _buildAppliedCoupon(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildAvailableCoupons(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Offers',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        SizedBox(height: 1.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _availableCoupons.length,
          separatorBuilder: (context, index) => SizedBox(height: 1.h),
          itemBuilder: (context, index) {
            final coupon = _availableCoupons[index];
            final isEligible =
                widget.originalAmount >= (coupon['minAmount'] as double);

            return InkWell(
              onTap: isEligible
                  ? () => _applyCouponCode(coupon['code'] as String)
                  : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: isEligible
                      ? theme.colorScheme.tertiary.withValues(alpha: 0.05)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isEligible
                        ? theme.colorScheme.tertiary.withValues(alpha: 0.3)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: isEligible
                            ? theme.colorScheme.tertiary
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        coupon['code'] as String,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isEligible
                              ? theme.colorScheme.onTertiary
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coupon['description'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isEligible
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (!isEligible) ...[
                            SizedBox(height: 0.5.h),
                            Text(
                              'Min. order ₹${_formatIndianCurrency(coupon['minAmount'] as double)}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isEligible)
                      CustomIconWidget(
                        iconName: 'arrow_forward_ios',
                        color: theme.colorScheme.tertiary,
                        size: 16,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppliedCoupon(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'check_circle',
            color: theme.colorScheme.primary,
            size: 24,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coupon Applied: $_appliedCoupon',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'You saved ₹${_formatIndianCurrency(_discountAmount)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _removeCoupon,
            child: Text(
              'Remove',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _applyCoupon() {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a coupon code';
      });
      return;
    }
    _applyCouponCode(code);
  }

  void _applyCouponCode(String code) {
    setState(() {
      _isApplying = true;
      _errorMessage = null;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      final coupon = _availableCoupons.firstWhere(
        (c) => (c['code'] as String).toUpperCase() == code.toUpperCase(),
        orElse: () => {},
      );

      if (coupon.isEmpty) {
        setState(() {
          _isApplying = false;
          _errorMessage = 'Invalid coupon code';
        });
        return;
      }

      final minAmount = coupon['minAmount'] as double;
      if (widget.originalAmount < minAmount) {
        setState(() {
          _isApplying = false;
          _errorMessage =
              'Minimum order amount ₹${_formatIndianCurrency(minAmount)} required';
        });
        return;
      }

      double discount = 0.0;
      if (coupon['type'] == 'percentage') {
        discount = widget.originalAmount * (coupon['discount'] as double);
        final maxDiscount = coupon['maxDiscount'] as double;
        if (discount > maxDiscount) {
          discount = maxDiscount;
        }
      } else {
        discount = coupon['discount'] as double;
      }

      setState(() {
        _isApplying = false;
        _isApplied = true;
        _appliedCoupon = code.toUpperCase();
        _discountAmount = discount;
        _couponController.text = code.toUpperCase();
      });

      widget.onDiscountApplied(discount);
    });
  }

  void _removeCoupon() {
    setState(() {
      _isApplied = false;
      _appliedCoupon = null;
      _discountAmount = 0.0;
      _couponController.clear();
      _errorMessage = null;
    });
    widget.onDiscountApplied(0.0);
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
}
