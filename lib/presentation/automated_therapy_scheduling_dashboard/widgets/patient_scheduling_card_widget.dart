import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../automated_therapy_scheduling_dashboard.dart';

class PatientSchedulingCardWidget extends StatelessWidget {
  final PatientScheduleData patient;
  final VoidCallback onSchedule;
  final VoidCallback onViewHistory;

  const PatientSchedulingCardWidget({
    super.key,
    required this.patient,
    required this.onSchedule,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercentage =
        patient.completedSessions / patient.totalSessions;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getPriorityColor(patient.priority, context)
              .withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getPriorityColor(patient.priority, context)
                      .withValues(alpha: 0.1),
                  _getPriorityColor(patient.priority, context)
                      .withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                // Patient Photo/Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(25),
                    image: patient.photo != null
                        ? DecorationImage(
                            image: NetworkImage(patient.photo!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: patient.photo == null
                      ? Icon(
                          Icons.person,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          size: 24,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                // Patient Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              patient.name,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          _buildPriorityBadge(patient.priority, context),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Current Phase: ${patient.currentPhase}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Next Session: ${_formatNextSession(patient.nextSession)}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Progress Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Treatment Progress',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${patient.completedSessions}/${patient.totalSessions} sessions',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progressPercentage,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getPriorityColor(patient.priority, context),
                  ),
                  minHeight: 6,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progressPercentage * 100).toInt()}% Complete',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${patient.totalSessions - patient.completedSessions} remaining',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
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
                    onPressed: onViewHistory,
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text('View History'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                      ),
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
                    onPressed: onSchedule,
                    icon: const Icon(Icons.schedule, size: 18),
                    label: const Text('Schedule'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _getPriorityColor(patient.priority, context),
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

  Widget _buildPriorityBadge(Priority priority, BuildContext context) {
    String text;
    Color color;
    IconData icon;

    switch (priority) {
      case Priority.urgent:
        text = 'URGENT';
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case Priority.emergency:
        text = 'EMERGENCY';
        color = Theme.of(context).colorScheme.error;
        icon = Icons.emergency;
        break;
      case Priority.low:
        text = 'LOW';
        color = Colors.blue;
        icon = Icons.info;
        break;
      default:
        text = 'NORMAL';
        color = Theme.of(context).colorScheme.primary;
        icon = Icons.check_circle;
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

  Color _getPriorityColor(Priority priority, BuildContext context) {
    switch (priority) {
      case Priority.urgent:
        return Colors.orange;
      case Priority.emergency:
        return Theme.of(context).colorScheme.error;
      case Priority.low:
        return Colors.blue;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _formatNextSession(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.isNegative) {
      return 'Overdue';
    } else if (difference.inHours < 1) {
      return 'In ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'In ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays < 7) {
      return 'In ${difference.inDays} days';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
