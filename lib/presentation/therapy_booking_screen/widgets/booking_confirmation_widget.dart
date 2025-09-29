import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class BookingConfirmationWidget extends StatelessWidget {
  final BookingDetails bookingDetails;
  final VoidCallback onBookNow;
  final VoidCallback? onReschedule;
  final VoidCallback? onJoinWaitlist;
  final bool isLoading;

  const BookingConfirmationWidget({
    super.key,
    required this.bookingDetails,
    required this.onBookNow,
    this.onReschedule,
    this.onJoinWaitlist,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                'Booking Confirmation',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Booking details card
              _buildBookingDetailsCard(context),
              const SizedBox(height: 16),

              // Preparation requirements
              if (bookingDetails.preparationRequirements.isNotEmpty) ...[
                _buildPreparationCard(context),
                const SizedBox(height: 16),
              ],

              // Action buttons
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingDetailsCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Therapy type and package
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookingDetails.therapyType,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (bookingDetails.packageName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        bookingDetails.packageName,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  bookingDetails.phase.name.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date and time
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  context,
                  'calendar_today',
                  'Date',
                  bookingDetails.formattedDate,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  context,
                  'schedule',
                  'Time',
                  bookingDetails.timeSlot,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Duration and therapist
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  context,
                  'timer',
                  'Duration',
                  bookingDetails.duration,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  context,
                  'person',
                  'Therapist',
                  bookingDetails.therapistName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Room and price
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  context,
                  'room',
                  'Room',
                  bookingDetails.roomName,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  context,
                  'currency_rupee',
                  'Price',
                  '₹${bookingDetails.totalPrice.toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      BuildContext context, String iconName, String label, String value) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: theme.colorScheme.primary,
          size: 16,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreparationCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info',
                color: theme.colorScheme.tertiary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Preparation Requirements',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...bookingDetails.preparationRequirements.map(
            (requirement) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      requirement,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Primary action button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onBookNow,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'payment',
                        color: theme.colorScheme.onPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Book Now - ₹${bookingDetails.totalPrice.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        // Secondary actions
        if (onReschedule != null || onJoinWaitlist != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              if (onReschedule != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : onReschedule,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Reschedule',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
              if (onReschedule != null && onJoinWaitlist != null) ...[
                const SizedBox(width: 12),
              ],
              if (onJoinWaitlist != null) ...[
                Expanded(
                  child: TextButton(
                    onPressed: isLoading ? null : onJoinWaitlist,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Join Waitlist',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

enum TherapyPhase { purva, pradhana, paschat }

class BookingDetails {
  final String therapyType;
  final String packageName;
  final TherapyPhase phase;
  final DateTime selectedDate;
  final String timeSlot;
  final String duration;
  final String therapistName;
  final String therapistImage;
  final String roomName;
  final double totalPrice;
  final List<String> preparationRequirements;

  BookingDetails({
    required this.therapyType,
    required this.packageName,
    required this.phase,
    required this.selectedDate,
    required this.timeSlot,
    required this.duration,
    required this.therapistName,
    required this.therapistImage,
    required this.roomName,
    required this.totalPrice,
    required this.preparationRequirements,
  });

  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${selectedDate.day} ${months[selectedDate.month - 1]}, ${selectedDate.year}';
  }
}
