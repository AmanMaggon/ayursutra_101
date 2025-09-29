import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationSettingsWidget extends StatefulWidget {
  final VoidCallback onSettingsChanged;

  const NotificationSettingsWidget({
    super.key,
    required this.onSettingsChanged,
  });

  @override
  State<NotificationSettingsWidget> createState() =>
      _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState
    extends State<NotificationSettingsWidget> {
  // Notification channel preferences
  bool _smsNotifications = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;

  // Notification type preferences
  bool _appointmentAlerts = true;
  bool _paymentNotifications = true;
  bool _progressUpdates = true;
  bool _careInstructions = true;
  bool _emergencyAlerts = true;
  bool _systemNotifications = false;

  // Time preferences
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 8, minute: 0);
  bool _respectQuietHours = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: 1.h),
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withAlpha(77),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),

              // Header
              Container(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    Text(
                      'Notification Settings',
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, size: 24),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  children: [
                    // Delivery Channels Section
                    _buildSectionHeader('Delivery Channels'),
                    _buildSettingsTile(
                      'SMS Notifications',
                      'Receive notifications via text message',
                      Icons.sms,
                      _smsNotifications,
                      (value) => setState(() => _smsNotifications = value),
                    ),
                    _buildSettingsTile(
                      'Email Notifications',
                      'Receive notifications via email',
                      Icons.email,
                      _emailNotifications,
                      (value) => setState(() => _emailNotifications = value),
                    ),
                    _buildSettingsTile(
                      'Push Notifications',
                      'Receive push notifications on your device',
                      Icons.notifications,
                      _pushNotifications,
                      (value) => setState(() => _pushNotifications = value),
                    ),

                    SizedBox(height: 3.h),

                    // Notification Types Section
                    _buildSectionHeader('Notification Types'),
                    _buildSettingsTile(
                      'Appointment Alerts',
                      'Reminders for upcoming appointments',
                      Icons.event,
                      _appointmentAlerts,
                      (value) => setState(() => _appointmentAlerts = value),
                      color: Colors.blue,
                    ),
                    _buildSettingsTile(
                      'Payment Notifications',
                      'Updates about payment status',
                      Icons.payment,
                      _paymentNotifications,
                      (value) => setState(() => _paymentNotifications = value),
                      color: Colors.green,
                    ),
                    _buildSettingsTile(
                      'Progress Updates',
                      'Your therapy progress milestones',
                      Icons.trending_up,
                      _progressUpdates,
                      (value) => setState(() => _progressUpdates = value),
                      color: Colors.purple,
                    ),
                    _buildSettingsTile(
                      'Care Instructions',
                      'Pre and post-therapy care guidelines',
                      Icons.medical_services,
                      _careInstructions,
                      (value) => setState(() => _careInstructions = value),
                      color: Colors.orange,
                    ),
                    _buildSettingsTile(
                      'Emergency Alerts',
                      'Critical health and safety alerts',
                      Icons.warning,
                      _emergencyAlerts,
                      (value) => setState(() => _emergencyAlerts = value),
                      color: Colors.red,
                      isEmergency: true,
                    ),
                    _buildSettingsTile(
                      'System Notifications',
                      'App updates and maintenance notices',
                      Icons.info,
                      _systemNotifications,
                      (value) => setState(() => _systemNotifications = value),
                      color: Colors.grey,
                    ),

                    SizedBox(height: 3.h),

                    // Time Preferences Section
                    _buildSectionHeader('Time Preferences'),
                    _buildSettingsTile(
                      'Respect Quiet Hours',
                      'Pause non-emergency notifications during quiet hours',
                      Icons.bedtime,
                      _respectQuietHours,
                      (value) => setState(() => _respectQuietHours = value),
                    ),

                    if (_respectQuietHours) ...[
                      SizedBox(height: 2.h),
                      _buildTimePickerTile(
                        'Quiet Hours Start',
                        _quietHoursStart,
                        (time) => setState(() => _quietHoursStart = time),
                      ),
                      _buildTimePickerTile(
                        'Quiet Hours End',
                        _quietHoursEnd,
                        (time) => setState(() => _quietHoursEnd = time),
                      ),
                    ],

                    SizedBox(height: 4.h),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 6.h,
                      child: ElevatedButton(
                        onPressed: _saveSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Save Settings',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged, {
    Color? color,
    bool isEmergency = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tileColor = color ?? colorScheme.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.onSurface.withAlpha(26),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: tileColor.withAlpha(26),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: tileColor,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isEmergency) ...[
              SizedBox(width: 2.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.2.h),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(26),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red, width: 0.5),
                ),
                child: Text(
                  'CRITICAL',
                  style: GoogleFonts.inter(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: colorScheme.onSurface.withAlpha(153),
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: isEmergency
              ? null
              : onChanged, // Emergency alerts cannot be disabled
          activeColor: tileColor,
        ),
      ),
    );
  }

  Widget _buildTimePickerTile(
    String title,
    TimeOfDay time,
    Function(TimeOfDay) onChanged,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(26),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(Icons.access_time,
            color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Text(
          time.format(context),
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        onTap: () => _selectTime(time, onChanged),
      ),
    );
  }

  Future<void> _selectTime(
      TimeOfDay currentTime, Function(TimeOfDay) onChanged) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (picked != null && picked != currentTime) {
      onChanged(picked);
    }
  }

  void _saveSettings() {
    // Save notification settings to backend
    // Implementation would involve calling the notification service
    // to update user preferences

    widget.onSettingsChanged();
  }
}
