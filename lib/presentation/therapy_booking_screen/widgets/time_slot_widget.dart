import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class TimeSlotWidget extends StatelessWidget {
  final List<TimeSlot> timeSlots;
  final TimeSlot? selectedSlot;
  final Function(TimeSlot) onSlotSelected;

  const TimeSlotWidget({
    super.key,
    required this.timeSlots,
    this.selectedSlot,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'Available Time Slots',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Time slots grid
          timeSlots.isEmpty
              ? _buildEmptyState(context)
              : _buildTimeSlotGrid(context),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'event_busy',
            color: theme.colorScheme.outline,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No slots available',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please select a different date or join the waitlist',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final slot = timeSlots[index];
        return _buildTimeSlotCard(context, slot);
      },
    );
  }

  Widget _buildTimeSlotCard(BuildContext context, TimeSlot slot) {
    final theme = Theme.of(context);
    final isSelected = selectedSlot?.id == slot.id;
    final isAvailable = slot.status == SlotStatus.available;

    return GestureDetector(
      onTap: isAvailable ? () => onSlotSelected(slot) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _getSlotBackgroundColor(theme, slot, isSelected),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getSlotBorderColor(theme, slot, isSelected),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    slot.time,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getSlotTextColor(theme, slot, isSelected),
                    ),
                  ),
                  _buildStatusIndicator(theme, slot),
                ],
              ),
              const SizedBox(height: 4),

              // Therapist info
              if (slot.therapistName.isNotEmpty) ...[
                Text(
                  slot.therapistName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: _getSlotTextColor(theme, slot, isSelected)
                        .withValues(alpha: 0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Room info
              if (slot.roomName.isNotEmpty) ...[
                Text(
                  slot.roomName,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: _getSlotTextColor(theme, slot, isSelected)
                        .withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(ThemeData theme, TimeSlot slot) {
    Color indicatorColor;
    IconData indicatorIcon;

    switch (slot.status) {
      case SlotStatus.available:
        indicatorColor = theme.colorScheme.primary;
        indicatorIcon = Icons.check_circle;
        break;
      case SlotStatus.limited:
        indicatorColor = Colors.orange;
        indicatorIcon = Icons.warning;
        break;
      case SlotStatus.unavailable:
        indicatorColor = theme.colorScheme.error;
        indicatorIcon = Icons.cancel;
        break;
    }

    return CustomIconWidget(
      iconName: indicatorIcon.codePoint.toString(),
      color: indicatorColor,
      size: 16,
    );
  }

  Color _getSlotBackgroundColor(
      ThemeData theme, TimeSlot slot, bool isSelected) {
    if (!_isSlotAvailable(slot)) {
      return theme.colorScheme.surface.withValues(alpha: 0.5);
    }

    if (isSelected) {
      return theme.colorScheme.primary.withValues(alpha: 0.1);
    }

    return theme.colorScheme.surface;
  }

  Color _getSlotBorderColor(ThemeData theme, TimeSlot slot, bool isSelected) {
    if (!_isSlotAvailable(slot)) {
      return theme.colorScheme.outline.withValues(alpha: 0.3);
    }

    if (isSelected) {
      return theme.colorScheme.primary;
    }

    return theme.colorScheme.outline.withValues(alpha: 0.5);
  }

  Color _getSlotTextColor(ThemeData theme, TimeSlot slot, bool isSelected) {
    if (!_isSlotAvailable(slot)) {
      return theme.colorScheme.onSurface.withValues(alpha: 0.4);
    }

    if (isSelected) {
      return theme.colorScheme.primary;
    }

    return theme.colorScheme.onSurface;
  }

  bool _isSlotAvailable(TimeSlot slot) {
    return slot.status == SlotStatus.available ||
        slot.status == SlotStatus.limited;
  }
}

enum SlotStatus { available, limited, unavailable }

class TimeSlot {
  final String id;
  final String time;
  final String therapistName;
  final String therapistImage;
  final String roomName;
  final SlotStatus status;
  final double price;

  TimeSlot({
    required this.id,
    required this.time,
    required this.therapistName,
    required this.therapistImage,
    required this.roomName,
    required this.status,
    required this.price,
  });
}
