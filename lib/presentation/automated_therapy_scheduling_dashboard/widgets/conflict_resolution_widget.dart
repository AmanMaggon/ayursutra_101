import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../automated_therapy_scheduling_dashboard.dart';

class ConflictResolutionWidget extends StatelessWidget {
  final SchedulingConflict conflict;
  final Function(String) onResolve;

  const ConflictResolutionWidget({
    super.key,
    required this.conflict,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getSeverityColor(conflict.severity, context),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getSeverityColor(conflict.severity, context)
                .withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getSeverityColor(conflict.severity, context)
                  .withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getSeverityColor(conflict.severity, context)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _getConflictIcon(conflict.type),
                    color: _getSeverityColor(conflict.severity, context),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getConflictTitle(conflict.type),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildSeverityBadge(conflict.severity, context),
                    ],
                  ),
                ),
                Icon(
                  Icons.warning,
                  color: _getSeverityColor(conflict.severity, context),
                  size: 20,
                ),
              ],
            ),
          ),

          // Conflict Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Issue Details',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  conflict.description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.4,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                // Affected Sessions
                Text(
                  'Affected Sessions (${conflict.affectedSessions.length})',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: conflict.affectedSessions
                      .map((sessionId) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .errorContainer
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Session #$sessionId',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),

                // AI Suggestion
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'AI Suggested Resolution',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        conflict.suggestedResolution,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.3,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showResolutionOptions(context),
                    icon: const Icon(Icons.settings, size: 18),
                    label: const Text('Custom Resolution'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onResolve(conflict.suggestedResolution),
                    icon: const Icon(Icons.auto_fix_high, size: 18),
                    label: const Text('Apply AI Solution'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildSeverityBadge(ConflictSeverity severity, BuildContext context) {
    String text;
    Color color = _getSeverityColor(severity, context);
    IconData icon;

    switch (severity) {
      case ConflictSeverity.critical:
        text = 'CRITICAL';
        icon = Icons.error;
        break;
      case ConflictSeverity.high:
        text = 'HIGH';
        icon = Icons.warning;
        break;
      case ConflictSeverity.medium:
        text = 'MEDIUM';
        icon = Icons.info;
        break;
      case ConflictSeverity.low:
        text = 'LOW';
        icon = Icons.check_circle_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showResolutionOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resolve Conflict'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose a resolution option:'),
            const SizedBox(height: 16),
            _buildResolutionOption(
              context,
              'Reschedule affected sessions',
              Icons.schedule,
              () => onResolve('Rescheduled all affected sessions'),
            ),
            _buildResolutionOption(
              context,
              'Assign different therapist',
              Icons.person_search,
              () => onResolve('Assigned alternative therapist'),
            ),
            _buildResolutionOption(
              context,
              'Change room assignment',
              Icons.meeting_room,
              () => onResolve('Moved to available room'),
            ),
            _buildResolutionOption(
              context,
              'Cancel conflicting session',
              Icons.cancel,
              () => onResolve('Cancelled conflicting session'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildResolutionOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  String _getConflictTitle(ConflictType type) {
    switch (type) {
      case ConflictType.therapistUnavailable:
        return 'Therapist Unavailable';
      case ConflictType.roomBooked:
        return 'Room Already Booked';
      case ConflictType.equipmentUnavailable:
        return 'Equipment Unavailable';
      case ConflictType.patientConflict:
        return 'Patient Schedule Conflict';
    }
  }

  IconData _getConflictIcon(ConflictType type) {
    switch (type) {
      case ConflictType.therapistUnavailable:
        return Icons.person_off;
      case ConflictType.roomBooked:
        return Icons.meeting_room_outlined;
      case ConflictType.equipmentUnavailable:
        return Icons.build;
      case ConflictType.patientConflict:
        return Icons.schedule_outlined;
    }
  }

  Color _getSeverityColor(ConflictSeverity severity, BuildContext context) {
    switch (severity) {
      case ConflictSeverity.critical:
        return Theme.of(context).colorScheme.error;
      case ConflictSeverity.high:
        return Colors.deepOrange;
      case ConflictSeverity.medium:
        return Colors.orange;
      case ConflictSeverity.low:
        return Colors.blue;
    }
  }
}
