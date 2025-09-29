import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import './widgets/calendar_view_widget.dart';
import './widgets/conflict_resolution_widget.dart';
import './widgets/patient_scheduling_card_widget.dart';
import './widgets/resource_utilization_widget.dart';

class AutomatedTherapySchedulingDashboard extends StatefulWidget {
  const AutomatedTherapySchedulingDashboard({super.key});

  @override
  State<AutomatedTherapySchedulingDashboard> createState() =>
      _AutomatedTherapySchedulingDashboardState();
}

class _AutomatedTherapySchedulingDashboardState
    extends State<AutomatedTherapySchedulingDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedViewMode = 'week'; // 'month', 'week', 'day'
  String _selectedFilter =
      'all'; // 'all', 'urgent', 'therapist', 'therapy_type'
  bool _showConflicts = false;

  final List<ScheduledSession> _scheduledSessions = [];
  final List<SchedulingConflict> _conflicts = [];
  final List<PatientScheduleData> _patients = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    // Mock scheduled sessions
    _scheduledSessions.addAll([
      ScheduledSession(
        id: '1',
        patientName: 'Rajesh Kumar',
        therapyType: 'Abhyanga',
        therapistName: 'Dr. Priya Sharma',
        roomNumber: 'R101',
        startTime: DateTime.now().add(const Duration(hours: 1)),
        endTime: DateTime.now().add(const Duration(hours: 2)),
        status: ScheduleStatus.confirmed,
        priority: Priority.normal,
      ),
      ScheduledSession(
        id: '2',
        patientName: 'Meera Patel',
        therapyType: 'Shirodhara',
        therapistName: 'Dr. Anuj Verma',
        roomNumber: 'R102',
        startTime: DateTime.now().add(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 3, minutes: 30)),
        status: ScheduleStatus.pending,
        priority: Priority.urgent,
      ),
    ]);

    // Mock conflicts
    _conflicts.addAll([
      SchedulingConflict(
        id: '1',
        type: ConflictType.therapistUnavailable,
        description: 'Dr. Priya Sharma has overlapping appointments',
        affectedSessions: ['1', '3'],
        suggestedResolution:
            'Reschedule to 3:00 PM or assign different therapist',
        severity: ConflictSeverity.medium,
      ),
    ]);

    // Mock patients
    _patients.addAll([
      PatientScheduleData(
        id: '1',
        name: 'Rajesh Kumar',
        photo: null,
        currentPhase: 'Purvakarma',
        nextSession: DateTime.now().add(const Duration(hours: 1)),
        totalSessions: 14,
        completedSessions: 5,
        priority: Priority.normal,
      ),
      PatientScheduleData(
        id: '2',
        name: 'Meera Patel',
        photo: null,
        currentPhase: 'Pradhankarma',
        nextSession: DateTime.now().add(const Duration(hours: 2)),
        totalSessions: 21,
        completedSessions: 12,
        priority: Priority.urgent,
      ),
    ]);

    setState(() {});
  }

  void _handleQuickSchedule() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Quick Schedule',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AI-powered scheduling will automatically find the best time slots based on:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            _buildQuickScheduleFeature('Patient preferences and history'),
            _buildQuickScheduleFeature('Therapist availability and expertise'),
            _buildQuickScheduleFeature('Room and equipment requirements'),
            _buildQuickScheduleFeature('Optimal therapy sequencing'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSchedulingSuccess();
            },
            child: const Text('Schedule Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickScheduleFeature(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  void _showSchedulingSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            '3 appointments scheduled successfully with optimal timing'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleBulkScheduling() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bulk Scheduling'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Schedule multiple patients with template-based therapy sequences'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_file),
              label: const Text('Import Patient List'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/Ayursutra_Logo_1_-1759156879861.png',
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.healing,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                );
              },
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Automated Scheduling',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'AI-Powered Therapy Management',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // View Mode Toggle
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'day', label: Text('Day')),
              ButtonSegment(value: 'week', label: Text('Week')),
              ButtonSegment(value: 'month', label: Text('Month')),
            ],
            selected: {_selectedViewMode},
            onSelectionChanged: (Set<String> selection) {
              setState(() {
                _selectedViewMode = selection.first;
              });
            },
            style: SegmentedButton.styleFrom(
              textStyle: GoogleFonts.inter(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          // Quick Actions
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'quick_schedule':
                  _handleQuickSchedule();
                  break;
                case 'bulk_schedule':
                  _handleBulkScheduling();
                  break;
                case 'export':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Export functionality coming soon')),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'quick_schedule',
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome),
                    SizedBox(width: 8),
                    Text('AI Quick Schedule'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'bulk_schedule',
                child: Row(
                  children: [
                    Icon(Icons.group_add),
                    SizedBox(width: 8),
                    Text('Bulk Scheduling'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Schedule'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
          unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400),
          tabs: const [
            Tab(text: 'Calendar', icon: Icon(Icons.calendar_month, size: 16)),
            Tab(text: 'Patients', icon: Icon(Icons.people, size: 16)),
            Tab(text: 'Resources', icon: Icon(Icons.help_outline, size: 16)),
            Tab(text: 'Conflicts', icon: Icon(Icons.warning, size: 16)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Calendar View Tab
          _buildCalendarTab(),
          // Patients Tab
          _buildPatientsTab(),
          // Resources Tab
          _buildResourcesTab(),
          // Conflicts Tab
          _buildConflictsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleQuickSchedule,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('AI Schedule'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildCalendarTab() {
    return Column(
      children: [
        // Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('All')),
                    ButtonSegment(value: 'urgent', label: Text('Urgent')),
                    ButtonSegment(
                        value: 'therapist', label: Text('By Therapist')),
                    ButtonSegment(
                        value: 'therapy_type', label: Text('By Therapy')),
                  ],
                  selected: {_selectedFilter},
                  onSelectionChanged: (Set<String> selection) {
                    setState(() {
                      _selectedFilter = selection.first;
                    });
                  },
                  style: SegmentedButton.styleFrom(
                    textStyle: GoogleFonts.inter(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Switch(
                value: _showConflicts,
                onChanged: (value) {
                  setState(() {
                    _showConflicts = value;
                  });
                },
              ),
              Text(
                'Show Conflicts',
                style: GoogleFonts.inter(fontSize: 12),
              ),
            ],
          ),
        ),
        // Calendar
        Expanded(
          child: CalendarViewWidget(
            sessions: _scheduledSessions,
            conflicts: _showConflicts ? _conflicts : [],
            viewMode: _selectedViewMode,
            selectedFilter: _selectedFilter,
            onSessionTap: (session) {
              _showSessionDetails(session);
            },
            onTimeSlotTap: (dateTime) {
              _showQuickScheduleDialog(dateTime);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPatientsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _patients.length,
      itemBuilder: (context, index) {
        return PatientSchedulingCardWidget(
          patient: _patients[index],
          onSchedule: () => _handlePatientScheduling(_patients[index]),
          onViewHistory: () => _showPatientHistory(_patients[index]),
        );
      },
    );
  }

  Widget _buildResourcesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ResourceUtilizationWidget(
            therapistData: [
              TherapistUtilization('Dr. Priya Sharma', 85, 12, 2),
              TherapistUtilization('Dr. Anuj Verma', 72, 10, 1),
              TherapistUtilization('Dr. Kavita Singh', 91, 15, 0),
            ],
            roomData: [
              RoomUtilization('Room 101', 78, true),
              RoomUtilization('Room 102', 65, true),
              RoomUtilization('Room 103', 90, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConflictsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _conflicts.length,
      itemBuilder: (context, index) {
        return ConflictResolutionWidget(
          conflict: _conflicts[index],
          onResolve: (resolution) =>
              _handleConflictResolution(_conflicts[index], resolution),
        );
      },
    );
  }

  void _showSessionDetails(ScheduledSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${session.therapyType} Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Patient:', session.patientName),
            _buildDetailRow('Therapist:', session.therapistName),
            _buildDetailRow('Room:', session.roomNumber),
            _buildDetailRow('Time:',
                '${_formatTime(session.startTime)} - ${_formatTime(session.endTime)}'),
            _buildDetailRow('Status:', session.status.name),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
          if (session.status == ScheduleStatus.pending) ...[
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Reschedule')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Confirm')),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showQuickScheduleDialog(DateTime dateTime) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Schedule Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Quick schedule for ${_formatDate(dateTime)} at ${_formatTime(dateTime)}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _handleQuickSchedule();
              },
              child: const Text('Use AI Scheduling'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _handlePatientScheduling(PatientScheduleData patient) {
    // Navigate to patient-specific scheduling
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening scheduler for ${patient.name}')),
    );
  }

  void _showPatientHistory(PatientScheduleData patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${patient.name} - Treatment History'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Phase: ${patient.currentPhase}'),
            Text(
                'Progress: ${patient.completedSessions}/${patient.totalSessions} sessions'),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: patient.completedSessions / patient.totalSessions,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }

  void _handleConflictResolution(
      SchedulingConflict conflict, String resolution) {
    setState(() {
      _conflicts.remove(conflict);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Conflict resolved: $resolution'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

// Data Models
class ScheduledSession {
  final String id;
  final String patientName;
  final String therapyType;
  final String therapistName;
  final String roomNumber;
  final DateTime startTime;
  final DateTime endTime;
  final ScheduleStatus status;
  final Priority priority;

  ScheduledSession({
    required this.id,
    required this.patientName,
    required this.therapyType,
    required this.therapistName,
    required this.roomNumber,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.priority,
  });
}

class SchedulingConflict {
  final String id;
  final ConflictType type;
  final String description;
  final List<String> affectedSessions;
  final String suggestedResolution;
  final ConflictSeverity severity;

  SchedulingConflict({
    required this.id,
    required this.type,
    required this.description,
    required this.affectedSessions,
    required this.suggestedResolution,
    required this.severity,
  });
}

class PatientScheduleData {
  final String id;
  final String name;
  final String? photo;
  final String currentPhase;
  final DateTime nextSession;
  final int totalSessions;
  final int completedSessions;
  final Priority priority;

  PatientScheduleData({
    required this.id,
    required this.name,
    this.photo,
    required this.currentPhase,
    required this.nextSession,
    required this.totalSessions,
    required this.completedSessions,
    required this.priority,
  });
}

class TherapistUtilization {
  final String name;
  final int utilization;
  final int sessionsToday;
  final int conflicts;

  TherapistUtilization(
      this.name, this.utilization, this.sessionsToday, this.conflicts);
}

class RoomUtilization {
  final String name;
  final int utilization;
  final bool available;

  RoomUtilization(this.name, this.utilization, this.available);
}

enum ScheduleStatus { pending, confirmed, inProgress, completed, cancelled }

enum Priority { low, normal, urgent, emergency }

enum ConflictType {
  therapistUnavailable,
  roomBooked,
  equipmentUnavailable,
  patientConflict
}

enum ConflictSeverity { low, medium, high, critical }
