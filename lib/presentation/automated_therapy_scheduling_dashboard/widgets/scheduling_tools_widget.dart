import 'package:flutter/material.dart';
import '../../../core/app_export.dart';

class SchedulingToolsWidget extends StatelessWidget {
  final VoidCallback onQuickSchedule;
  final VoidCallback onBulkSchedule;
  final VoidCallback onTemplateSchedule;

  const SchedulingToolsWidget({
    super.key,
    required this.onQuickSchedule,
    required this.onBulkSchedule,
    required this.onTemplateSchedule,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Smart Scheduling Tools',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildToolButton(
                  context,
                  'AI Quick Schedule',
                  'Automatically find optimal slots',
                  Icons.auto_awesome,
                  Theme.of(context).colorScheme.primary,
                  onQuickSchedule,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildToolButton(
                  context,
                  'Bulk Schedule',
                  'Schedule multiple patients',
                  Icons.group_add,
                  Colors.orange,
                  onBulkSchedule,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildToolButton(
                  context,
                  'Template Schedule',
                  'Use therapy sequence templates',
                  Icons.file_copy,
                  Colors.teal,
                  onTemplateSchedule,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
