import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/app_export.dart';
import './widgets/booking_confirmation_widget.dart';
import './widgets/calendar_widget.dart' as calendar_widget; // ✅ ADD PREFIX HERE
import './widgets/contraindication_checker_widget.dart';
import './widgets/package_selection_widget.dart';
import './widgets/time_slot_widget.dart';

class TherapyBookingScreen extends StatefulWidget {
  const TherapyBookingScreen({super.key});

  @override
  State<TherapyBookingScreen> createState() => _TherapyBookingScreenState();
}

class _TherapyBookingScreenState extends State<TherapyBookingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  TimeSlot? _selectedTimeSlot;
  TherapyPackage? _selectedPackage;
  bool _isLoading = false;
  bool _showTimeSlots = false;
  bool _showBookingConfirmation = false;

  // Mock data
  final List<TherapyPackage> _therapyPackages = [
    TherapyPackage(
      id: '1',
      name: 'Panchakarma Complete',
      imageUrl:
          'https://images.pexels.com/photos/3757942/pexels-photo-3757942.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      duration: 21,
      sessions: 15,
      benefits:
          'Complete detoxification, stress relief, improved immunity and mental clarity',
      originalPrice: 45000,
      finalPrice: 38250,
      discountPercentage: 15,
      isPopular: true,
      therapySequence: ['Purva Karma', 'Pradhana Karma', 'Paschat Karma'],
    ),
    TherapyPackage(
      id: '2',
      name: 'Abhyanga Therapy',
      imageUrl:
          'https://images.pexels.com/photos/3757942/pexels-photo-3757942.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      duration: 7,
      sessions: 7,
      benefits: 'Deep relaxation, improved circulation, muscle tension relief',
      originalPrice: 12000,
      finalPrice: 10800,
      discountPercentage: 10,
      isPopular: false,
      therapySequence: ['Purva Karma', 'Abhyanga'],
    ),
    TherapyPackage(
      id: '3',
      name: 'Shirodhara Package',
      imageUrl:
          'https://images.pexels.com/photos/3757942/pexels-photo-3757942.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      duration: 14,
      sessions: 10,
      benefits:
          'Mental peace, stress reduction, improved sleep quality, nervous system balance',
      originalPrice: 25000,
      finalPrice: 22500,
      discountPercentage: 10,
      isPopular: false,
      therapySequence: ['Purva Karma', 'Shirodhara', 'Paschat Karma'],
    ),
  ];

  final List<TimeSlot> _availableTimeSlots = [
    TimeSlot(
      id: '1',
      time: '09:00 AM',
      therapistName: 'Dr. Priya Sharma',
      therapistImage:
          'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
      roomName: 'Ayurveda Room 1',
      status: SlotStatus.available,
      price: 2500,
    ),
    TimeSlot(
      id: '2',
      time: '11:00 AM',
      therapistName: 'Dr. Rajesh Kumar',
      therapistImage:
          'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
      roomName: 'Ayurveda Room 2',
      status: SlotStatus.limited,
      price: 2500,
    ),
    TimeSlot(
      id: '3',
      time: '02:00 PM',
      therapistName: 'Dr. Meera Nair',
      therapistImage:
          'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
      roomName: 'Ayurveda Room 3',
      status: SlotStatus.available,
      price: 2500,
    ),
    TimeSlot(
      id: '4',
      time: '04:00 PM',
      therapistName: 'Dr. Arjun Patel',
      therapistImage:
          'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
      roomName: 'Ayurveda Room 1',
      status: SlotStatus.unavailable,
      price: 2500,
    ),
  ];

  final List<ContraindicationWarning> _contraindicationWarnings = [
    ContraindicationWarning(
      id: '1',
      title: 'Age Consideration',
      description:
          'Patients above 65 years require special monitoring during Panchakarma treatments.',
      detailedDescription:
          'Advanced age may affect the body\'s ability to handle intensive detoxification processes. Elderly patients may experience increased fatigue, dehydration, or blood pressure fluctuations during treatment.',
      recommendation:
          'Consult with our senior Ayurvedic physician for a modified treatment plan suitable for your age group.',
      severity: WarningSeverity.medium,
      category: 'Age',
    ),
    ContraindicationWarning(
      id: '2',
      title: 'Hypertension Alert',
      description:
          'Your medical history indicates high blood pressure. Some therapies may affect blood pressure.',
      detailedDescription:
          'Certain Panchakarma procedures like Virechana and Basti can cause temporary fluctuations in blood pressure. Steam treatments and oil massages may also impact cardiovascular function.',
      recommendation:
          'Blood pressure monitoring during treatment and possible medication adjustments may be required.',
      severity: WarningSeverity.high,
      category: 'Cardiovascular',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedPackage = _therapyPackages.first;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Tab bar
          _buildTabBar(context),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCalendarTab(context),
                _buildPackagesTab(context),
                _buildBookingTab(context),
              ],
            ),
          ),
        ],
      ),
      bottomSheet:
          _showBookingConfirmation ? _buildBookingConfirmation(context) : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        'Book Therapy Session',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: theme.colorScheme.onSurface,
          size: 24,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            _showAvailabilityFilter(context);
          },
          icon: CustomIconWidget(
            iconName: 'filter_list',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/patient-dashboard');
          },
          icon: CustomIconWidget(
            iconName: 'home',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
        ),
      ],
      backgroundColor: theme.colorScheme.surface,
      elevation: 1,
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor:
            theme.colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorColor: theme.colorScheme.primary,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'Calendar'),
          Tab(text: 'Packages'),
          Tab(text: 'Booking'),
        ],
      ),
    );
  }

  Widget _buildCalendarTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar widget - ✅ NOW USES PREFIX
          calendar_widget.CalendarWidget(
            selectedDay: _selectedDay,
            onDaySelected: (selectedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _showTimeSlots = true;
                _selectedTimeSlot = null;
              });
            },
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
          ),

          const SizedBox(height: 24),

          // Legend
          _buildCalendarLegend(context),

          const SizedBox(height: 24),

          // Time slots
          if (_showTimeSlots) ...[
            Text(
              'Available Time Slots',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            TimeSlotWidget(
              timeSlots: _availableTimeSlots,
              selectedSlot: _selectedTimeSlot,
              onSlotSelected: (slot) {
                setState(() {
                  _selectedTimeSlot = slot;
                  _showBookingConfirmation = true;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPackagesTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          PackageSelectionWidget(
            packages: _therapyPackages,
            selectedPackage: _selectedPackage,
            onPackageSelected: (package) {
              setState(() {
                _selectedPackage = package;
              });
            },
          ),
          const SizedBox(height: 100), // Space for bottom sheet
        ],
      ),
    );
  }

  Widget _buildBookingTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contraindication checker
          ContraindicationCheckerWidget(
            warnings: _contraindicationWarnings,
            onConsultDoctor: () {
              Navigator.pushNamed(context, '/doctor-dashboard');
            },
            onDismiss: () {
              setState(() {
                // Remove warnings after user acknowledgment
              });
            },
          ),

          const SizedBox(height: 24),

          // Booking summary
          if (_selectedPackage != null && _selectedTimeSlot != null) ...[
            _buildBookingSummary(context),
          ] else ...[
            _buildBookingGuidance(context),
          ],
        ],
      ),
    );
  }

  Widget _buildCalendarLegend(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legend',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildLegendItem(context, theme.colorScheme.primary, 'Available'),
              const SizedBox(width: 16),
              _buildLegendItem(context, Colors.orange, 'Limited'),
              const SizedBox(width: 16),
              _buildLegendItem(context, theme.colorScheme.error, 'Unavailable'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Phase indicators: Blue (Purva), Red (Pradhana), Green (Paschat)',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingSummary(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Summary',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Package details
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImageWidget(
                  imageUrl: _selectedPackage!.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedPackage!.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${_selectedPackage!.duration} days • ${_selectedPackage!.sessions} sessions',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      '₹${_selectedPackage!.finalPrice.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Time slot details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year} at ${_selectedTimeSlot!.time}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${_selectedTimeSlot!.therapistName} • ${_selectedTimeSlot!.roomName}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingGuidance(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'event_note',
            color: theme.colorScheme.outline,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Complete Your Booking',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please select a therapy package and time slot to proceed with your booking.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _tabController.animateTo(1);
                  },
                  child: Text(
                    'Select Package',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _tabController.animateTo(0);
                  },
                  child: Text(
                    'Select Time',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget? _buildBookingConfirmation(BuildContext context) {
    if (_selectedPackage == null || _selectedTimeSlot == null) return null;

    final bookingDetails = BookingDetails(
      therapyType: _selectedPackage!.name,
      packageName: _selectedPackage!.name,
      phase: TherapyPhase.purva, // ✅ USES TherapyPhase from booking_confirmation_widget.dart
      selectedDate: _selectedDay,
      timeSlot: _selectedTimeSlot!.time,
      duration: '${_selectedPackage!.duration} days',
      therapistName: _selectedTimeSlot!.therapistName,
      therapistImage: _selectedTimeSlot!.therapistImage,
      roomName: _selectedTimeSlot!.roomName,
      totalPrice: _selectedPackage!.finalPrice,
      preparationRequirements: [
        'Fast for 12 hours before the session',
        'Avoid alcohol and smoking 24 hours prior',
        'Wear comfortable, loose-fitting clothes',
        'Bring a change of clothes',
        'Inform about any medications you are taking',
      ],
    );

    return BookingConfirmationWidget(
      bookingDetails: bookingDetails,
      isLoading: _isLoading,
      onBookNow: () {
        _handleBookNow();
      },
      onReschedule: () {
        setState(() {
          _showBookingConfirmation = false;
          _selectedTimeSlot = null;
        });
        _tabController.animateTo(0);
      },
      onJoinWaitlist: () {
        _handleJoinWaitlist();
      },
    );
  }

  void _handleBookNow() {
    setState(() {
      _isLoading = true;
    });

    // Simulate booking process
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      // Navigate to payment gateway
      Navigator.pushNamed(context, '/payment-gateway-screen');
    });
  }

  void _handleJoinWaitlist() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added to waitlist. We\'ll notify you when a slot becomes available.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    setState(() {
      _showBookingConfirmation = false;
    });
  }

  void _showAvailabilityFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Filter Availability',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              // Filter options would go here
              Text(
                'Filter options coming soon...',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
