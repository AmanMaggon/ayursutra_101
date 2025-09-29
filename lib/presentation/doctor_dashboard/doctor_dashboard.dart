import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/analytics_preview_widget.dart';
import './widgets/critical_alerts_widget.dart';
import './widgets/patient_card_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/schedule_card_widget.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isLoading = false;
  String _selectedFilter = 'all';

  // Mock data for doctor dashboard
  final Map<String, dynamic> doctorInfo = {
    "name": "Dr. Rajesh Kumar",
    "specialization": "Ayurveda Specialist",
    "center": "Panchakarma Wellness Center",
    "experience": "15 years",
    "rating": 4.8,
    "totalPatients": 156,
    "criticalAlerts": 3,
  };

  final List<Map<String, dynamic>> patientsList = [
    {
      "id": 1,
      "name": "Priya Sharma",
      "age": 34,
      "gender": "Female",
      "photo":
          "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face",
      "currentPhase": "Treatment",
      "priority": "critical",
      "condition": "Chronic Arthritis",
      "nextSession": "Today 2:00 PM",
      "lastVisit": "2 days ago",
      "progress": 65,
    },
    {
      "id": 2,
      "name": "Amit Patel",
      "age": 42,
      "gender": "Male",
      "photo":
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
      "currentPhase": "Recovery",
      "priority": "attention",
      "condition": "Digestive Disorders",
      "nextSession": "Tomorrow 10:00 AM",
      "lastVisit": "1 week ago",
      "progress": 80,
    },
    {
      "id": 3,
      "name": "Sunita Devi",
      "age": 28,
      "gender": "Female",
      "photo":
          "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face",
      "currentPhase": "Assessment",
      "priority": "normal",
      "condition": "Stress Management",
      "nextSession": "Friday 11:00 AM",
      "lastVisit": "3 days ago",
      "progress": 25,
    },
    {
      "id": 4,
      "name": "Ravi Kumar",
      "age": 55,
      "gender": "Male",
      "photo":
          "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
      "currentPhase": "Maintenance",
      "priority": "normal",
      "condition": "Hypertension",
      "nextSession": "Next week",
      "lastVisit": "5 days ago",
      "progress": 90,
    },
    {
      "id": 5,
      "name": "Meera Singh",
      "age": 38,
      "gender": "Female",
      "photo":
          "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop&crop=face",
      "currentPhase": "Treatment",
      "priority": "attention",
      "condition": "Migraine",
      "nextSession": "Today 4:00 PM",
      "lastVisit": "Yesterday",
      "progress": 45,
    },
  ];

  final List<Map<String, dynamic>> todaySchedule = [
    {
      "id": 1,
      "patientName": "Priya Sharma",
      "patientPhoto":
          "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100&h=100&fit=crop&crop=face",
      "time": "2:00 PM",
      "duration": 45,
      "type": "consultation",
      "condition": "Chronic Arthritis",
      "room": "Room 101",
    },
    {
      "id": 2,
      "patientName": "Meera Singh",
      "patientPhoto":
          "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&h=100&fit=crop&crop=face",
      "time": "4:00 PM",
      "duration": 30,
      "type": "telemedicine",
      "condition": "Migraine",
      "room": "Virtual",
    },
  ];

  final List<Map<String, dynamic>> criticalAlerts = [
    {
      "id": 1,
      "patientName": "Priya Sharma",
      "type": "vital_signs",
      "severity": "high",
      "description": "Blood pressure readings consistently high for 3 days",
      "timestamp": "2 hours ago",
    },
    {
      "id": 2,
      "patientName": "Rajesh Gupta",
      "type": "side_effects",
      "severity": "medium",
      "description": "Reported severe nausea after Panchakarma session",
      "timestamp": "4 hours ago",
    },
    {
      "id": 3,
      "patientName": "Kavita Joshi",
      "type": "missed_session",
      "severity": "low",
      "description": "Missed 2 consecutive therapy sessions without notice",
      "timestamp": "1 day ago",
    },
  ];

  final Map<String, dynamic> analyticsData = {
    "totalPatients": 156,
    "totalSessions": 89,
    "recoveryRate": 87,
    "excellentOutcomes": 45,
    "goodOutcomes": 32,
    "fairOutcomes": 12,
    "weeklyData": [15, 18, 22, 19, 25, 20, 23],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);
  }

  Future<void> _refreshData() async {
    HapticFeedback.lightImpact();
    await _loadDashboardData();
  }

  List<Map<String, dynamic>> get filteredPatients {
    var filtered = patientsList;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((patient) {
        final name = (patient['name'] as String).toLowerCase();
        final condition = (patient['condition'] as String).toLowerCase();
        return name.contains(query) || condition.contains(query);
      }).toList();
    }

    // Apply priority filter
    if (_selectedFilter != 'all') {
      filtered = filtered
          .where((patient) => patient['priority'] == _selectedFilter)
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Doctor Dashboard',
        variant: CustomAppBarVariant.primary,
        showNotificationBadge: criticalAlerts.isNotEmpty,
        onNotificationTap: () => _showNotifications(context),
      ),
      body: Column(
        children: [
          // Doctor Info Header
          _buildDoctorHeader(context, theme),

          // Tab Bar
          Container(
            color: theme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor:
                  theme.colorScheme.onSurface.withValues(alpha: 0.6),
              indicatorColor: theme.colorScheme.primary,
              tabs: const [
                Tab(text: 'Patients', icon: Icon(Icons.people)),
                Tab(text: 'Schedule', icon: Icon(Icons.calendar_today)),
                Tab(text: 'Protocols', icon: Icon(Icons.assignment)),
                Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPatientsTab(context),
                _buildScheduleTab(context),
                _buildProtocolsTab(context),
                _buildAnalyticsTab(context),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomBar(
        currentIndex: 3, // Doctor dashboard index
        variant: CustomBottomBarVariant.primary,
      ),
    );
  }

  Widget _buildDoctorHeader(BuildContext context, ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: CustomImageWidget(
                imageUrl:
                    "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=150&h=150&fit=crop&crop=face",
                width: 15.w,
                height: 15.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorInfo['name'] as String,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  doctorInfo['specialization'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  doctorInfo['center'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (criticalAlerts.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'warning',
                    size: 16,
                    color: theme.colorScheme.error,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '${criticalAlerts.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPatientsTab(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Column(
        children: [
          // Search and Filter Bar
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search patients or conditions...',
                      prefixIcon: CustomIconWidget(
                        iconName: 'search',
                        size: 20,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: CustomIconWidget(
                                iconName: 'clear',
                                size: 20,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            )
                          : IconButton(
                              onPressed: () => _startVoiceSearch(),
                              icon: CustomIconWidget(
                                iconName: 'mic',
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    ),
                  ),
                ),

                SizedBox(height: 2.h),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'All Patients'),
                      SizedBox(width: 2.w),
                      _buildFilterChip('critical', 'Critical'),
                      SizedBox(width: 2.w),
                      _buildFilterChip('attention', 'Attention'),
                      SizedBox(width: 2.w),
                      _buildFilterChip('normal', 'Normal'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Critical Alerts
          if (criticalAlerts.isNotEmpty)
            CriticalAlertsWidget(
              criticalAlerts: criticalAlerts,
              onViewAllAlerts: () => _showAllAlerts(context),
            ),

          // Today's Schedule Card
          ScheduleCardWidget(
            todaySchedule: todaySchedule,
            onViewFullSchedule: () => _tabController.animateTo(1),
          ),

          // Patients List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredPatients.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: 2.h),
                        itemCount: filteredPatients.length,
                        itemBuilder: (context, index) {
                          final patient = filteredPatients[index];
                          return PatientCardWidget(
                            patient: patient,
                            onTap: () => _viewPatientDetails(context, patient),
                            onViewProgress: () =>
                                _viewPatientProgress(context, patient),
                            onSendMessage: () => _sendMessage(context, patient),
                            onAdjustProtocol: () =>
                                _adjustProtocol(context, patient),
                            onViewHistory: () =>
                                _viewPatientHistory(context, patient),
                            onLabResults: () =>
                                _viewLabResults(context, patient),
                            onEmergencyContact: () =>
                                _emergencyContact(context, patient),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScheduleCardWidget(
            todaySchedule: todaySchedule,
            onViewFullSchedule: () => _showFullSchedule(context),
          ),
          SizedBox(height: 2.h),
          QuickActionsWidget(
            onPrescription: () => _openPrescription(context),
            onProtocols: () => _tabController.animateTo(2),
            onAnalytics: () => _tabController.animateTo(3),
            onPatientSearch: () => _tabController.animateTo(0),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Treatment Protocols',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 2.h),

          // Protocol management content
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .shadow
                      .withValues(alpha: 0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              children: [
                CustomIconWidget(
                  iconName: 'assignment',
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Protocol Management',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Create and manage standardized treatment protocols for different conditions',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                ElevatedButton(
                  onPressed: () => _manageProtocols(context),
                  child: const Text('Manage Protocols'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        children: [
          AnalyticsPreviewWidget(
            analyticsData: analyticsData,
            onViewFullAnalytics: () => _showFullAnalytics(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final theme = Theme.of(context);
    final isSelected = _selectedFilter == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            SizedBox(height: 2.h),
            Text(
              'No patients found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Try adjusting your search or filter criteria',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Action Methods
  void _startVoiceSearch() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice search feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _viewPatientDetails(BuildContext context, Map<String, dynamic> patient) {
    Navigator.pushNamed(context, '/patient-dashboard');
  }

  void _viewPatientProgress(
      BuildContext context, Map<String, dynamic> patient) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing progress for ${patient['name']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _sendMessage(BuildContext context, Map<String, dynamic> patient) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sending message to ${patient['name']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _adjustProtocol(BuildContext context, Map<String, dynamic> patient) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Adjusting protocol for ${patient['name']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _viewPatientHistory(BuildContext context, Map<String, dynamic> patient) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing history for ${patient['name']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _viewLabResults(BuildContext context, Map<String, dynamic> patient) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing lab results for ${patient['name']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _emergencyContact(BuildContext context, Map<String, dynamic> patient) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Emergency contact for ${patient['name']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAllAlerts(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Showing all critical alerts'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showFullSchedule(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Full schedule view coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openPrescription(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('E-prescription feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _manageProtocols(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Protocol management feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showFullAnalytics(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Full analytics view coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
