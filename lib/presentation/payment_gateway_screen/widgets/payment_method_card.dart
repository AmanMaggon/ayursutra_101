import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

enum PaymentMethodType {
  upi,
  card,
  netBanking,
  wallet,
}

class PaymentMethodCard extends StatefulWidget {
  final PaymentMethodType type;
  final bool isSelected;
  final VoidCallback onTap;
  final Function(Map<String, dynamic>)? onPaymentDataChanged;

  const PaymentMethodCard({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
    this.onPaymentDataChanged,
  });

  @override
  State<PaymentMethodCard> createState() => _PaymentMethodCardState();
}

class _PaymentMethodCardState extends State<PaymentMethodCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String? _selectedBank;
  String? _selectedWallet;
  String? _selectedUpiApp;

  final List<Map<String, String>> _banks = [
    {
      'name': 'State Bank of India',
      'code': 'SBI',
      'logo': 'https://logos-world.net/wp-content/uploads/2021/02/SBI-Logo.png'
    },
    {
      'name': 'HDFC Bank',
      'code': 'HDFC',
      'logo':
          'https://logos-world.net/wp-content/uploads/2020/12/HDFC-Bank-Logo.png'
    },
    {
      'name': 'ICICI Bank',
      'code': 'ICICI',
      'logo':
          'https://logos-world.net/wp-content/uploads/2020/12/ICICI-Bank-Logo.png'
    },
    {
      'name': 'Axis Bank',
      'code': 'AXIS',
      'logo':
          'https://logos-world.net/wp-content/uploads/2020/12/Axis-Bank-Logo.png'
    },
    {
      'name': 'Kotak Mahindra Bank',
      'code': 'KOTAK',
      'logo':
          'https://logos-world.net/wp-content/uploads/2020/12/Kotak-Mahindra-Bank-Logo.png'
    },
    {
      'name': 'Punjab National Bank',
      'code': 'PNB',
      'logo':
          'https://logos-world.net/wp-content/uploads/2021/02/Punjab-National-Bank-Logo.png'
    },
  ];

  final List<Map<String, String>> _wallets = [
    {
      'name': 'Paytm',
      'logo':
          'https://logos-world.net/wp-content/uploads/2020/11/Paytm-Logo.png'
    },
    {
      'name': 'PhonePe',
      'logo':
          'https://logos-world.net/wp-content/uploads/2021/02/PhonePe-Logo.png'
    },
    {
      'name': 'Google Pay',
      'logo':
          'https://logos-world.net/wp-content/uploads/2020/12/Google-Pay-Logo.png'
    },
    {
      'name': 'Amazon Pay',
      'logo':
          'https://logos-world.net/wp-content/uploads/2020/11/Amazon-Pay-Logo.png'
    },
  ];

  final List<Map<String, String>> _upiApps = [
    {'name': 'Google Pay', 'package': 'com.google.android.apps.nfc.payment'},
    {'name': 'PhonePe', 'package': 'com.phonepe.app'},
    {'name': 'Paytm', 'package': 'net.one97.paytm'},
    {'name': 'BHIM', 'package': 'in.org.npci.upiapp'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(PaymentMethodCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _animationController.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: widget.isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: _getMethodColor(theme).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: _getMethodIcon(),
                      color: _getMethodColor(theme),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getMethodTitle(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          _getMethodSubtitle(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getProcessingTime(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  CustomIconWidget(
                    iconName: widget.isSelected
                        ? 'keyboard_arrow_up'
                        : 'keyboard_arrow_down',
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _expandAnimation.value,
                  child: child,
                ),
              );
            },
            child: _buildExpandedContent(context, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, ThemeData theme) {
    switch (widget.type) {
      case PaymentMethodType.upi:
        return _buildUpiContent(theme);
      case PaymentMethodType.card:
        return _buildCardContent(theme);
      case PaymentMethodType.netBanking:
        return _buildNetBankingContent(theme);
      case PaymentMethodType.wallet:
        return _buildWalletContent(theme);
    }
  }

  Widget _buildUpiContent(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          SizedBox(height: 3.h),
          Text(
            'Choose UPI App',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 1.h,
            ),
            itemCount: _upiApps.length,
            itemBuilder: (context, index) {
              final app = _upiApps[index];
              final isSelected = _selectedUpiApp == app['name'];

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedUpiApp = app['name'];
                  });
                  widget.onPaymentDataChanged?.call({
                    'type': 'upi',
                    'app': app['name'],
                    'package': app['package'],
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.colorScheme.surface,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'account_balance_wallet',
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          app['name']!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
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
                    'UPI payments are secured with bank-grade encryption',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          SizedBox(height: 3.h),
          Text(
            'Card Details',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          TextFormField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Card Number',
              hintText: '1234 5678 9012 3456',
              prefixIcon: CustomIconWidget(
                iconName: 'credit_card',
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
            onChanged: (value) {
              widget.onPaymentDataChanged?.call({
                'type': 'card',
                'cardNumber': value,
                'expiry': _expiryController.text,
                'cvv': _cvvController.text,
                'name': _nameController.text,
              });
            },
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    labelText: 'MM/YY',
                    hintText: '12/28',
                  ),
                  onChanged: (value) {
                    widget.onPaymentDataChanged?.call({
                      'type': 'card',
                      'cardNumber': _cardNumberController.text,
                      'expiry': value,
                      'cvv': _cvvController.text,
                      'name': _nameController.text,
                    });
                  },
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                  ),
                  onChanged: (value) {
                    widget.onPaymentDataChanged?.call({
                      'type': 'card',
                      'cardNumber': _cardNumberController.text,
                      'expiry': _expiryController.text,
                      'cvv': value,
                      'name': _nameController.text,
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Cardholder Name',
              hintText: 'John Doe',
            ),
            onChanged: (value) {
              widget.onPaymentDataChanged?.call({
                'type': 'card',
                'cardNumber': _cardNumberController.text,
                'expiry': _expiryController.text,
                'cvv': _cvvController.text,
                'name': value,
              });
            },
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'lock',
                  color: theme.colorScheme.tertiary,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Your card details are encrypted and secure',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetBankingContent(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          SizedBox(height: 3.h),
          Text(
            'Select Your Bank',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 1.h,
            ),
            itemCount: _banks.length,
            itemBuilder: (context, index) {
              final bank = _banks[index];
              final isSelected = _selectedBank == bank['name'];

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedBank = bank['name'];
                  });
                  widget.onPaymentDataChanged?.call({
                    'type': 'netbanking',
                    'bank': bank['name'],
                    'code': bank['code'],
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.colorScheme.surface,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomImageWidget(
                        imageUrl: bank['logo']!,
                        width: 8.w,
                        height: 8.w,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        bank['name']!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWalletContent(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          SizedBox(height: 3.h),
          Text(
            'Choose Wallet',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 1.h,
            ),
            itemCount: _wallets.length,
            itemBuilder: (context, index) {
              final wallet = _wallets[index];
              final isSelected = _selectedWallet == wallet['name'];

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedWallet = wallet['name'];
                  });
                  widget.onPaymentDataChanged?.call({
                    'type': 'wallet',
                    'wallet': wallet['name'],
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.colorScheme.surface,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomImageWidget(
                        imageUrl: wallet['logo']!,
                        width: 8.w,
                        height: 8.w,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        wallet['name']!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getMethodTitle() {
    switch (widget.type) {
      case PaymentMethodType.upi:
        return 'UPI Payment';
      case PaymentMethodType.card:
        return 'Credit/Debit Card';
      case PaymentMethodType.netBanking:
        return 'Net Banking';
      case PaymentMethodType.wallet:
        return 'Digital Wallets';
    }
  }

  String _getMethodSubtitle() {
    switch (widget.type) {
      case PaymentMethodType.upi:
        return 'Pay using UPI apps like GPay, PhonePe';
      case PaymentMethodType.card:
        return 'Visa, Mastercard, RuPay accepted';
      case PaymentMethodType.netBanking:
        return 'All major Indian banks supported';
      case PaymentMethodType.wallet:
        return 'Paytm, PhonePe, Amazon Pay & more';
    }
  }

  String _getMethodIcon() {
    switch (widget.type) {
      case PaymentMethodType.upi:
        return 'qr_code';
      case PaymentMethodType.card:
        return 'credit_card';
      case PaymentMethodType.netBanking:
        return 'account_balance';
      case PaymentMethodType.wallet:
        return 'account_balance_wallet';
    }
  }

  Color _getMethodColor(ThemeData theme) {
    switch (widget.type) {
      case PaymentMethodType.upi:
        return theme.colorScheme.primary;
      case PaymentMethodType.card:
        return theme.colorScheme.secondary;
      case PaymentMethodType.netBanking:
        return theme.colorScheme.tertiary;
      case PaymentMethodType.wallet:
        return const Color(0xFF4CAF50);
    }
  }

  String _getProcessingTime() {
    switch (widget.type) {
      case PaymentMethodType.upi:
        return 'Instant';
      case PaymentMethodType.card:
        return '2-3 mins';
      case PaymentMethodType.netBanking:
        return '3-5 mins';
      case PaymentMethodType.wallet:
        return 'Instant';
    }
  }
}
