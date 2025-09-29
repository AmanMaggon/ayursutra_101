import 'package:flutter/material.dart';
import '../../../core/app_export.dart';

class QuickActionButtonsWidget extends StatelessWidget {
  final Function(String) onAction;

  const QuickActionButtonsWidget({
    super.key,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        id: 'book_appointment',
        label: 'Book Appointment',
        icon: Icons.calendar_month,
        color: Theme.of(context).colorScheme.primary,
      ),
      _QuickAction(
        id: 'view_sessions',
        label: 'Today\'s Sessions',
        icon: Icons.schedule,
        color: Theme.of(context).colorScheme.secondary,
      ),
      _QuickAction(
        id: 'notifications',
        label: 'Notifications',
        icon: Icons.notifications,
        color: Theme.of(context).colorScheme.tertiary,
      ),
      _QuickAction(
        id: 'diet_guidelines',
        label: 'Diet Guidelines',
        icon: Icons.restaurant_menu,
        color: Colors.orange,
      ),
      _QuickAction(
        id: 'emergency',
        label: 'Emergency Help',
        icon: Icons.emergency,
        color: Theme.of(context).colorScheme.error,
      ),
    ];

    return Container(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            actions.map((action) => _buildActionChip(context, action)).toList(),
      ),
    );
  }

  Widget _buildActionChip(BuildContext context, _QuickAction action) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onAction(action.id),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: action.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: action.color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                action.icon,
                size: 16,
                color: action.color,
              ),
              const SizedBox(width: 6),
              Text(
                action.label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: action.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  _QuickAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}
