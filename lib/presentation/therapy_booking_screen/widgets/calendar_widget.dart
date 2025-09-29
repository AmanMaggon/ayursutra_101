import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/app_export.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;
  final CalendarFormat calendarFormat;
  final Function(CalendarFormat) onFormatChanged;

  const CalendarWidget({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    required this.calendarFormat,
    required this.onFormatChanged,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late final ValueNotifier<List<TherapyEvent>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();

  // Mock therapy availability data
  final Map<DateTime, List<TherapyEvent>> _therapyEvents = {
    DateTime(2025, 1, 15): [
      TherapyEvent(
          'Abhyanga', TherapyPhase.purva, AvailabilityStatus.available),
      TherapyEvent('Swedana', TherapyPhase.purva, AvailabilityStatus.limited),
    ],
    DateTime(2025, 1, 16): [
      TherapyEvent(
          'Panchakarma', TherapyPhase.pradhana, AvailabilityStatus.available),
    ],
    DateTime(2025, 1, 17): [
      TherapyEvent(
          'Basti', TherapyPhase.pradhana, AvailabilityStatus.unavailable),
    ],
    DateTime(2025, 1, 18): [
      TherapyEvent(
          'Nasya', TherapyPhase.pradhana, AvailabilityStatus.available),
      TherapyEvent(
          'Karnapurana', TherapyPhase.paschat, AvailabilityStatus.limited),
    ],
    DateTime(2025, 1, 20): [
      TherapyEvent(
          'Rasayana', TherapyPhase.paschat, AvailabilityStatus.available),
    ],
    DateTime(2025, 1, 22): [
      TherapyEvent('Abhyanga', TherapyPhase.purva, AvailabilityStatus.limited),
    ],
    DateTime(2025, 1, 25): [
      TherapyEvent(
          'Panchakarma', TherapyPhase.pradhana, AvailabilityStatus.unavailable),
    ],
    DateTime(2025, 1, 28): [
      TherapyEvent('Swedana', TherapyPhase.purva, AvailabilityStatus.available),
      TherapyEvent(
          'Dhara', TherapyPhase.pradhana, AvailabilityStatus.available),
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedEvents = ValueNotifier(_getEventsForDay(widget.selectedDay));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<TherapyEvent> _getEventsForDay(DateTime day) {
    return _therapyEvents[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Color _getAvailabilityColor(List<TherapyEvent> events) {
    if (events.isEmpty) return Colors.grey.withValues(alpha: 0.3);

    final hasUnavailable =
        events.any((e) => e.status == AvailabilityStatus.unavailable);
    final hasLimited =
        events.any((e) => e.status == AvailabilityStatus.limited);
    final hasAvailable =
        events.any((e) => e.status == AvailabilityStatus.available);

    if (hasUnavailable && !hasAvailable)
      return AppTheme.lightTheme.colorScheme.error;
    if (hasLimited) return Colors.orange;
    if (hasAvailable) return AppTheme.lightTheme.colorScheme.primary;

    return Colors.grey.withValues(alpha: 0.3);
  }

  Widget _buildPhaseIndicator(List<TherapyEvent> events) {
    if (events.isEmpty) return const SizedBox.shrink();

    final phases = events.map((e) => e.phase).toSet().toList();

    return Positioned(
      bottom: 2,
      right: 2,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: phases.map((phase) {
          Color phaseColor;
          switch (phase) {
            case TherapyPhase.purva:
              phaseColor = Colors.blue;
              break;
            case TherapyPhase.pradhana:
              phaseColor = Colors.red;
              break;
            case TherapyPhase.paschat:
              phaseColor = Colors.green;
              break;
          }

          return Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(left: 1),
            decoration: BoxDecoration(
              color: phaseColor,
              shape: BoxShape.circle,
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: TableCalendar<TherapyEvent>(
        firstDay: DateTime.now().subtract(const Duration(days: 30)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        calendarFormat: widget.calendarFormat,
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        selectedDayPredicate: (day) {
          return isSameDay(widget.selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(widget.selectedDay, selectedDay)) {
            widget.onDaySelected(selectedDay);
            _selectedEvents.value = _getEventsForDay(selectedDay);
          }
          setState(() {
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: widget.onFormatChanged,
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: GoogleFonts.inter(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.w500,
          ),
          holidayTextStyle: GoogleFonts.inter(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.w500,
          ),
          selectedDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: GoogleFonts.inter(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
          todayDecoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          todayTextStyle: GoogleFonts.inter(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
          defaultTextStyle: GoogleFonts.inter(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w400,
          ),
          weekendDecoration: const BoxDecoration(),
          markerDecoration: BoxDecoration(
            color: theme.colorScheme.tertiary,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
          canMarkersOverflow: false,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          formatButtonTextStyle: GoogleFonts.inter(
            color: theme.colorScheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          leftChevronIcon: CustomIconWidget(
            iconName: 'chevron_left',
            color: theme.colorScheme.primary,
            size: 20,
          ),
          rightChevronIcon: CustomIconWidget(
            iconName: 'chevron_right',
            color: theme.colorScheme.primary,
            size: 20,
          ),
          titleTextStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.inter(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          weekendStyle: GoogleFonts.inter(
            color: theme.colorScheme.error.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final events = _getEventsForDay(day);
            return Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _getAvailabilityColor(events),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: GoogleFonts.inter(
                        color: events.isNotEmpty
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                _buildPhaseIndicator(events),
              ],
            );
          },
          todayBuilder: (context, day, focusedDay) {
            final events = _getEventsForDay(day);
            return Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _getAvailabilityColor(events).withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: GoogleFonts.inter(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                _buildPhaseIndicator(events),
              ],
            );
          },
        ),
      ),
    );
  }
}

enum TherapyPhase { purva, pradhana, paschat }

enum AvailabilityStatus { available, limited, unavailable }

class TherapyEvent {
  final String name;
  final TherapyPhase phase;
  final AvailabilityStatus status;

  TherapyEvent(this.name, this.phase, this.status);
}
