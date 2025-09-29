import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../automated_therapy_scheduling_dashboard.dart';

class CalendarViewWidget extends StatefulWidget {
  final List<ScheduledSession> sessions;
  final List<SchedulingConflict> conflicts;
  final String viewMode;
  final String selectedFilter;
  final Function(ScheduledSession) onSessionTap;
  final Function(DateTime) onTimeSlotTap;

  const CalendarViewWidget({
    super.key,
    required this.sessions,
    required this.conflicts,
    required this.viewMode,
    required this.selectedFilter,
    required this.onSessionTap,
    required this.onTimeSlotTap,
  });

  @override
  State<CalendarViewWidget> createState() => _CalendarViewWidgetState();
}

class _CalendarViewWidgetState extends State<CalendarViewWidget> {
  DateTime _selectedDate = DateTime.now();
  ScrollController _timeScrollController = ScrollController();

  @override
  void dispose() {
    _timeScrollController.dispose();
    super.dispose();
  }

  List<ScheduledSession> get filteredSessions {
    switch (widget.selectedFilter) {
      case 'urgent':
        return widget.sessions
            .where((s) =>
                s.priority == Priority.urgent ||
                s.priority == Priority.emergency)
            .toList();
      case 'therapist':
        return widget.sessions; // In real app, filter by selected therapist
      case 'therapy_type':
        return widget.sessions; // In real app, filter by selected therapy type
      default:
        return widget.sessions;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Date Navigation
        _buildDateNavigation(),
        // Calendar Content
        Expanded(
          child: _buildCalendarContent(),
        ),
      ],
    );
  }

  Widget _buildDateNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(Duration(
                    days: widget.viewMode == 'month'
                        ? 30
                        : widget.viewMode == 'week'
                            ? 7
                            : 1));
              });
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Center(
              child: Text(
                _getDateRangeText(),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(Duration(
                    days: widget.viewMode == 'month'
                        ? 30
                        : widget.viewMode == 'week'
                            ? 7
                            : 1));
              });
            },
            icon: const Icon(Icons.chevron_right),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
              });
            },
            child: const Text('Today'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarContent() {
    switch (widget.viewMode) {
      case 'month':
        return _buildMonthView();
      case 'week':
        return _buildWeekView();
      case 'day':
        return _buildDayView();
      default:
        return _buildWeekView();
    }
  }

  Widget _buildMonthView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 35, // 5 weeks
      itemBuilder: (context, index) {
        final date = _getMonthViewDate(index);
        final daysSessions = filteredSessions
            .where((s) => _isSameDay(s.startTime, date))
            .toList();
        final hasConflicts = widget.conflicts.any((c) => c.affectedSessions
            .any((sessionId) => daysSessions.any((s) => s.id == sessionId)));

        return GestureDetector(
          onTap: () => widget.onTimeSlotTap(date),
          child: Container(
            decoration: BoxDecoration(
              color: _isSameDay(date, DateTime.now())
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: _isSameDay(date, DateTime.now())
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: date.month != _selectedDate.month
                        ? Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.5)
                        : null,
                  ),
                ),
                if (daysSessions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: hasConflicts
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${daysSessions.length}',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeekView() {
    return Row(
      children: [
        // Time column
        SizedBox(
          width: 60,
          child: Column(
            children: [
              const SizedBox(height: 40), // Header space
              Expanded(
                child: ListView.builder(
                  controller: _timeScrollController,
                  itemCount: 24,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: 60,
                      child: Center(
                        child: Text(
                          '${index.toString().padLeft(2, '0')}:00',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Days columns
        Expanded(
          child: Column(
            children: [
              // Days header
              SizedBox(
                height: 40,
                child: Row(
                  children: List.generate(7, (index) {
                    final date = _getWeekDate(index);
                    return Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          '${_getDayName(date.weekday)}\n${date.day}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: _isSameDay(date, DateTime.now())
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: _isSameDay(date, DateTime.now())
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // Time grid
              Expanded(
                child: ListView.builder(
                  controller: _timeScrollController,
                  itemCount: 24,
                  itemBuilder: (context, timeIndex) {
                    return SizedBox(
                      height: 60,
                      child: Row(
                        children: List.generate(7, (dayIndex) {
                          final date = _getWeekDate(dayIndex);
                          final timeSlot = DateTime(
                              date.year, date.month, date.day, timeIndex);
                          final sessionsInSlot = filteredSessions
                              .where((s) => _isInTimeSlot(s, timeSlot))
                              .toList();

                          return Expanded(
                            child: GestureDetector(
                              onTap: () => widget.onTimeSlotTap(timeSlot),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                    width: 0.25,
                                  ),
                                ),
                                child: Stack(
                                  children: sessionsInSlot
                                      .map((session) =>
                                          _buildSessionBlock(session))
                                      .toList(),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayView() {
    final daysSessions = filteredSessions
        .where((s) => _isSameDay(s.startTime, _selectedDate))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: daysSessions.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildDayHeader();
        }

        final session = daysSessions[index - 1];
        return _buildDaySessionCard(session);
      },
    );
  }

  Widget _buildDayHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatFullDate(_selectedDate),
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${filteredSessions.where((s) => _isSameDay(s.startTime, _selectedDate)).length} sessions scheduled',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.calendar_today,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySessionCard(ScheduledSession session) {
    final hasConflict =
        widget.conflicts.any((c) => c.affectedSessions.contains(session.id));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasConflict
              ? Theme.of(context).colorScheme.error
              : _getTherapyColor(session.therapyType).withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getTherapyColor(session.therapyType).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTherapyIcon(session.therapyType),
            color: _getTherapyColor(session.therapyType),
            size: 20,
          ),
        ),
        title: Text(
          session.therapyType,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Patient: ${session.patientName}'),
            Text('Therapist: ${session.therapistName}'),
            Text('Room: ${session.roomNumber}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_formatTime(session.startTime)} - ${_formatTime(session.endTime)}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            _buildStatusChip(session.status),
          ],
        ),
        onTap: () => widget.onSessionTap(session),
      ),
    );
  }

  Widget _buildSessionBlock(ScheduledSession session) {
    final hasConflict =
        widget.conflicts.any((c) => c.affectedSessions.contains(session.id));

    return Positioned.fill(
      child: GestureDetector(
        onTap: () => widget.onSessionTap(session),
        child: Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: hasConflict
                ? Theme.of(context).colorScheme.error.withValues(alpha: 0.8)
                : _getTherapyColor(session.therapyType).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.therapyType,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  session.patientName,
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ScheduleStatus status) {
    Color color;
    switch (status) {
      case ScheduleStatus.confirmed:
        color = Theme.of(context).colorScheme.primary;
        break;
      case ScheduleStatus.pending:
        color = Colors.orange;
        break;
      case ScheduleStatus.inProgress:
        color = Colors.blue;
        break;
      case ScheduleStatus.completed:
        color = Colors.green;
        break;
      case ScheduleStatus.cancelled:
        color = Theme.of(context).colorScheme.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // Helper methods
  DateTime _getMonthViewDate(int index) {
    final firstDayOfMonth =
        DateTime(_selectedDate.year, _selectedDate.month, 1);
    final firstDayWeekday = firstDayOfMonth.weekday % 7;
    return firstDayOfMonth
        .subtract(Duration(days: firstDayWeekday))
        .add(Duration(days: index));
  }

  DateTime _getWeekDate(int dayIndex) {
    final firstDayOfWeek =
        _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    return firstDayOfWeek.add(Duration(days: dayIndex));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isInTimeSlot(ScheduledSession session, DateTime timeSlot) {
    return session.startTime.hour == timeSlot.hour &&
        _isSameDay(session.startTime, timeSlot);
  }

  String _getDateRangeText() {
    switch (widget.viewMode) {
      case 'month':
        return '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}';
      case 'week':
        final weekStart = _getWeekDate(0);
        final weekEnd = _getWeekDate(6);
        return '${weekStart.day} - ${weekEnd.day} ${_getMonthName(weekEnd.month)} ${weekEnd.year}';
      case 'day':
        return _formatFullDate(_selectedDate);
      default:
        return '';
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  String _formatFullDate(DateTime date) {
    return '${_getDayName(date.weekday)}, ${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getTherapyColor(String therapyType) {
    switch (therapyType.toLowerCase()) {
      case 'abhyanga':
        return Colors.green;
      case 'shirodhara':
        return Colors.blue;
      case 'swedana':
        return Colors.orange;
      case 'nasya':
        return Colors.purple;
      case 'basti':
        return Colors.teal;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _getTherapyIcon(String therapyType) {
    switch (therapyType.toLowerCase()) {
      case 'abhyanga':
        return Icons.spa;
      case 'shirodhara':
        return Icons.water_drop;
      case 'swedana':
        return Icons.thermostat;
      case 'nasya':
        return Icons.air;
      case 'basti':
        return Icons.healing;
      default:
        return Icons.medical_services;
    }
  }
}
