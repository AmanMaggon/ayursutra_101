import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInputWidget extends StatefulWidget {
  final Function(String) onChanged;
  final bool isDemoMode;

  const OtpInputWidget({
    super.key,
    required this.onChanged,
    this.isDemoMode = false,
  });

  @override
  State<OtpInputWidget> createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<OtpInputWidget> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    // Initialize controllers and focus nodes for 6 digits
    for (int i = 0; i < 6; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Move to next field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    // Get complete OTP
    String otp = _controllers.map((controller) => controller.text).join();
    widget.onChanged(otp);
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _fillDemoOtp() {
    if (widget.isDemoMode) {
      const demoOtp = "000000";
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = demoOtp[i];
      }
      widget.onChanged(demoOtp);
      _focusNodes[5].unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // OTP input boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return Container(
              width: 45,
              height: 55,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _controllers[index].text.isNotEmpty
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                  width: _controllers[index].text.isNotEmpty ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                keyboardType: TextInputType.number,
                maxLength: 1,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) => _onChanged(value, index),
                onTap: () {
                  // Clear current field when tapped
                  _controllers[index].clear();
                  widget.onChanged(_controllers.map((c) => c.text).join());
                },
                onEditingComplete: () {
                  if (index < 5 && _controllers[index].text.isNotEmpty) {
                    _focusNodes[index + 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),

        if (widget.isDemoMode) ...[
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _fillDemoOtp,
            icon: Icon(
              Icons.auto_fix_high,
              size: 18,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            label: Text(
              'Fill Demo OTP (000000)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Error hints
        Text(
          'Enter the 6-digit code sent to your ${widget.isDemoMode ? 'demo ' : ''}number',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
