import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationFilterWidget extends StatelessWidget {
  final String selectedFilter;
  final bool showUnreadOnly;
  final Function(String) onFilterChanged;
  final VoidCallback onToggleUnread;
  final int unreadCount;

  const NotificationFilterWidget({
    super.key,
    required this.selectedFilter,
    required this.showUnreadOnly,
    required this.onFilterChanged,
    required this.onToggleUnread,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final filters = [
      {'key': 'all', 'label': 'All', 'icon': Icons.notifications},
      {'key': 'appointment', 'label': 'Appointments', 'icon': Icons.event},
      {'key': 'payment', 'label': 'Payments', 'icon': Icons.payment},
      {'key': 'progress', 'label': 'Progress', 'icon': Icons.trending_up},
      {
        'key': 'care_instruction',
        'label': 'Care',
        'icon': Icons.medical_services
      },
      {'key': 'emergency', 'label': 'Emergency', 'icon': Icons.warning},
      {'key': 'system', 'label': 'System', 'icon': Icons.info},
    ];

    return Column(
      children: [
        // Unread Filter Toggle
        Container(
          margin: EdgeInsets.only(bottom: 2.h),
          child: Row(
            children: [
              Switch(
                value: showUnreadOnly,
                onChanged: (_) => onToggleUnread(),
                activeColor: colorScheme.primary,
              ),
              SizedBox(width: 2.w),
              Text(
                'Show unread only',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 2.w),
              if (unreadCount > 0) ...[
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Type Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((filter) {
              final isSelected = selectedFilter == filter['key'];

              return Container(
                margin: EdgeInsets.only(right: 2.w),
                child: FilterChip(
                  selected: isSelected,
                  onSelected: (_) => onFilterChanged(filter['key'] as String),
                  avatar: Icon(
                    filter['icon'] as IconData,
                    size: 16,
                    color: isSelected
                        ? Colors.white
                        : colorScheme.onSurface.withAlpha(179),
                  ),
                  label: Text(
                    filter['label'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : colorScheme.onSurface.withAlpha(179),
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  selectedColor: colorScheme.primary,
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface.withAlpha(77),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
