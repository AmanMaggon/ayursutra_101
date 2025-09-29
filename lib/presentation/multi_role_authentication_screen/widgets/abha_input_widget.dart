import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';


class AbhaInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final String? errorText;
  final Function(String) onChanged;
  final FocusNode? focusNode; // **FIX 1: Added parameter to accept a FocusNode**

  const AbhaInputWidget({
    super.key,
    required this.controller,
    this.errorText,
    required this.onChanged,
    this.focusNode, // **FIX 2: Added to the constructor**
  });

  @override
  State<AbhaInputWidget> createState() => _AbhaInputWidgetState();
}

class _AbhaInputWidgetState extends State<AbhaInputWidget> {
  // **FIX 3: Removed the internal FocusNode. We will use the one passed from the parent.**
  // final FocusNode _focusNode = FocusNode(); 
  bool _isFocused = false;

  // Listener for focus changes
  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = widget.focusNode?.hasFocus ?? false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // **FIX 4: Listen to the FocusNode that was passed in via the widget.**
    widget.focusNode?.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    // **FIX 5: Remove the listener. DO NOT dispose the focus node here, as the parent owns it.**
    widget.focusNode?.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'verified_user',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'ABHA',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                'ABHA ID / Mobile Number',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
                        : AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3),
                width: _isFocused ? 2 : 1,
              ),
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: widget.focusNode, // **FIX 6: Use the passed-in FocusNode here**
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(14),
              ],
              onChanged: widget.onChanged,
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Enter 14-digit ABHA ID or 10-digit mobile',
                hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.5),
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'badge',
                    color: _isFocused
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.5),
                    size: 20,
                  ),
                ),
                suffixIcon: widget.controller.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          widget.controller.clear();
                          widget.onChanged('');
                        },
                        child: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'clear',
                            color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.5),
                            size: 20,
                          ),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info_outline',
                color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.7),
                size: 14,
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: Text(
                  'ABHA ID ensures secure healthcare data access across India',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Assuming these classes exist elsewhere in your project
class AppTheme { static final lightTheme = ThemeData.light(); }
class CustomIconWidget extends StatelessWidget {
  final String iconName; final Color color; final double size;
  const CustomIconWidget({required this.iconName, required this.color, required this.size, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) { 
    // This is a placeholder. Your actual icons might be different.
    IconData iconData = Icons.help;
    if(iconName == 'verified_user') iconData = Icons.verified_user;
    if(iconName == 'badge') iconData = Icons.badge;
    if(iconName == 'clear') iconData = Icons.clear;
    if(iconName == 'error_outline') iconData = Icons.error_outline;
    if(iconName == 'info_outline') iconData = Icons.info_outline;
    return Icon(iconData, color: color, size: size);
  }
}