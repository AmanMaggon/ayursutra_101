import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PasswordInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final String? errorText;
  final Function(String) onChanged;
  final FocusNode? focusNode; // Add optional FocusNode parameter

  const PasswordInputWidget({
    super.key,
    required this.controller,
    this.errorText,
    required this.onChanged,
    this.focusNode, // Optional external focus node
  });

  @override
  State<PasswordInputWidget> createState() => _PasswordInputWidgetState();
}

class _PasswordInputWidgetState extends State<PasswordInputWidget> {
  FocusNode? _internalFocusNode; // Internal focus node (nullable)
  bool _isFocused = false;
  bool _isPasswordVisible = false;

  // Get the effective focus node (external or internal)
  FocusNode get _effectiveFocusNode {
    return widget.focusNode ?? _internalFocusNode!;
  }

  @override
  void initState() {
    super.initState();
    
    // Create internal focus node only if external one is not provided
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
    }
    
    // Add listener to the effective focus node
    _effectiveFocusNode.addListener(() {
      setState(() {
        _isFocused = _effectiveFocusNode.hasFocus;
      });
    });
  }

  @override
  void didUpdateWidget(PasswordInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle focus node changes when widget updates
    if (widget.focusNode != oldWidget.focusNode) {
      // Remove listener from old focus node
      if (oldWidget.focusNode != null) {
        oldWidget.focusNode!.removeListener(_focusListener);
      } else {
        _internalFocusNode?.removeListener(_focusListener);
      }
      
      // Dispose internal focus node if switching to external
      if (oldWidget.focusNode == null && widget.focusNode != null) {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      }
      
      // Create internal focus node if switching from external to internal
      if (oldWidget.focusNode != null && widget.focusNode == null) {
        _internalFocusNode = FocusNode();
      }
      
      // Add listener to new effective focus node
      _effectiveFocusNode.addListener(_focusListener);
    }
  }

  void _focusListener() {
    setState(() {
      _isFocused = _effectiveFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    // Remove listener
    _effectiveFocusNode.removeListener(_focusListener);
    
    // Only dispose internal focus node if we created it
    _internalFocusNode?.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.errorText != null
                    ? AppTheme.lightTheme.colorScheme.error
                    : _isFocused
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                width: _isFocused ? 2 : 1,
              ),
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: _effectiveFocusNode, // Use effective focus node
              obscureText: !_isPasswordVisible,
              onChanged: widget.onChanged,
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your password',
                hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.5),
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'lock_outline',
                    color: _isFocused
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                    size: 20,
                  ),
                ),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName:
                          _isPasswordVisible ? 'visibility_off' : 'visibility',
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ),
                ),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              ),
            ),
          ),
          if (widget.errorText != null) ...[
            SizedBox(height: 1.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'error_outline',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
