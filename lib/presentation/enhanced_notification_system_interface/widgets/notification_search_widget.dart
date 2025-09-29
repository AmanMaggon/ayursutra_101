import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationSearchWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClearSearch;

  const NotificationSearchWidget({
    super.key,
    required this.controller,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 6.h,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.onSurface.withAlpha(26),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: 'Search notifications...',
          hintStyle: GoogleFonts.inter(
            fontSize: 14.sp,
            color: colorScheme.onSurface.withAlpha(128),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: colorScheme.onSurface.withAlpha(128),
            size: 20,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: onClearSearch,
                  icon: Icon(
                    Icons.clear,
                    color: colorScheme.onSurface.withAlpha(128),
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 2.h,
          ),
        ),
      ),
    );
  }
}
