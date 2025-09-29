import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class BookingSummaryCard extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const BookingSummaryCard({
    super.key,
    required this.bookingData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'medical_services',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Booking Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildSummaryRow(
            context,
            'Therapy Package',
            bookingData['therapyName'] as String? ?? 'Panchakarma Complete',
            isTitle: true,
          ),
          SizedBox(height: 1.h),
          _buildSummaryRow(
            context,
            'Duration',
            bookingData['duration'] as String? ?? '21 Days',
          ),
          _buildSummaryRow(
            context,
            'Start Date',
            bookingData['startDate'] as String? ?? '15 Oct 2024',
          ),
          _buildSummaryRow(
            context,
            'Center',
            bookingData['centerName'] as String? ?? 'Ayurveda Wellness Center',
          ),
          SizedBox(height: 2.h),
          Container(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          SizedBox(height: 2.h),
          _buildPricingSection(context),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isTitle = false,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: isTitle
                  ? theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    )
                  : theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(BuildContext context) {
    final theme = Theme.of(context);
    final baseAmount =
        (bookingData['baseAmount'] as num?)?.toDouble() ?? 45000.0;
    final gstAmount = (bookingData['gstAmount'] as num?)?.toDouble() ?? 8100.0;
    final discountAmount =
        (bookingData['discountAmount'] as num?)?.toDouble() ?? 0.0;
    final totalAmount = baseAmount + gstAmount - discountAmount;

    return Column(
      children: [
        _buildPriceRow(
          context,
          'Package Amount',
          '₹${_formatIndianCurrency(baseAmount)}',
        ),
        if (discountAmount > 0) ...[
          _buildPriceRow(
            context,
            'Discount Applied',
            '- ₹${_formatIndianCurrency(discountAmount)}',
            color: theme.colorScheme.tertiary,
          ),
        ],
        _buildPriceRow(
          context,
          'GST (18%)',
          '₹${_formatIndianCurrency(gstAmount)}',
        ),
        SizedBox(height: 1.h),
        Container(
          height: 1,
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        SizedBox(height: 1.h),
        _buildPriceRow(
          context,
          'Total Amount',
          '₹${_formatIndianCurrency(totalAmount)}',
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    String amount, {
    bool isTotal = false,
    Color? color,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  )
                : theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w400,
                  ),
          ),
          Text(
            amount,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color ?? theme.colorScheme.primary,
                  )
                : theme.textTheme.bodyMedium?.copyWith(
                    color: color ?? theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
          ),
        ],
      ),
    );
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
