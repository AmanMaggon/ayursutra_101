import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomTabBarVariant {
  primary,
  secondary,
  pills,
  underline,
}

class CustomTabBar extends StatefulWidget implements PreferredSizeWidget {
  final List<CustomTab> tabs;
  final CustomTabBarVariant variant;
  final int initialIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? indicatorColor;
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;
  final double? indicatorWeight;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.variant = CustomTabBarVariant.primary,
    this.initialIndex = 0,
    this.onTap,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.indicatorColor,
    this.isScrollable = false,
    this.padding,
    this.indicatorWeight,
  });

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();

  @override
  Size get preferredSize => const Size.fromHeight(48);
}

class _CustomTabBarState extends State<CustomTabBar>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      initialIndex: widget.initialIndex,
      vsync: this,
    );
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _tabController.addListener(() {
      if (widget.onTap != null && _tabController.indexIsChanging) {
        widget.onTap!(_tabController.index);
        HapticFeedback.lightImpact();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (widget.variant) {
      case CustomTabBarVariant.pills:
        return _buildPillsTabBar(context, colorScheme);
      case CustomTabBarVariant.underline:
        return _buildUnderlineTabBar(context, colorScheme);
      case CustomTabBarVariant.secondary:
        return _buildSecondaryTabBar(context, colorScheme);
      default:
        return _buildPrimaryTabBar(context, colorScheme);
    }
  }

  Widget _buildPrimaryTabBar(BuildContext context, ColorScheme colorScheme) {
    return Container(
      color: widget.backgroundColor ?? colorScheme.surface,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        isScrollable: widget.isScrollable,
        labelColor: widget.selectedColor ?? colorScheme.primary,
        unselectedLabelColor: widget.unselectedColor ??
            colorScheme.onSurface.withOpacity(0.6),
        indicatorColor: widget.indicatorColor ?? colorScheme.primary,
        indicatorWeight: widget.indicatorWeight ?? 2.0,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabs: widget.tabs
            .map((tab) => Tab(
                  text: tab.text,
                  icon: tab.icon != null ? Icon(tab.icon) : null,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSecondaryTabBar(BuildContext context, ColorScheme colorScheme) {
    return Container(
      color: widget.backgroundColor ?? colorScheme.primary,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        isScrollable: widget.isScrollable,
        labelColor: widget.selectedColor ?? colorScheme.onPrimary,
        unselectedLabelColor: widget.unselectedColor ??
            colorScheme.onPrimary.withOpacity(0.7),
        indicatorColor: widget.indicatorColor ?? colorScheme.onPrimary,
        indicatorWeight: widget.indicatorWeight ?? 2.0,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabs: widget.tabs
            .map((tab) => Tab(
                  text: tab.text,
                  icon: tab.icon != null ? Icon(tab.icon) : null,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildPillsTabBar(BuildContext context, ColorScheme colorScheme) {
    return Container(
      color: widget.backgroundColor ?? colorScheme.surface,
      padding: widget.padding ?? const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: widget.tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = index == _tabController.index;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  _tabController.animateTo(index);
                  HapticFeedback.lightImpact();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (widget.selectedColor ?? colorScheme.primary)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? (widget.selectedColor ?? colorScheme.primary)
                          : colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (tab.icon != null) ...[
                        Icon(
                          tab.icon,
                          size: 16,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : (widget.unselectedColor ??
                                  colorScheme.onSurface.withOpacity(0.6)),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        tab.text,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : (widget.unselectedColor ??
                                  colorScheme.onSurface.withOpacity(0.6)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildUnderlineTabBar(BuildContext context, ColorScheme colorScheme) {
    return Container(
      color: widget.backgroundColor ?? colorScheme.surface,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: widget.isScrollable,
            labelColor: widget.selectedColor ?? colorScheme.primary,
            unselectedLabelColor: widget.unselectedColor ??
                colorScheme.onSurface.withOpacity(0.6),
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                color: widget.indicatorColor ?? colorScheme.primary,
                width: widget.indicatorWeight ?? 3.0,
              ),
              insets: const EdgeInsets.symmetric(horizontal: 16),
            ),
            labelStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            tabs: widget.tabs
                .map((tab) => Tab(
                      text: tab.text,
                      icon: tab.icon != null ? Icon(tab.icon) : null,
                    ))
                .toList(),
          ),
          Container(
            height: 1,
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}

class CustomTab {
  final String text;
  final IconData? icon;
  final String? route;

  const CustomTab({
    required this.text,
    this.icon,
    this.route,
  });
}

// Healthcare-specific tab bar for medical sections
class HealthcareTabBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const HealthcareTabBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  static const List<CustomTab> healthcareTabs = [
    CustomTab(
      text: 'Treatments',
      icon: Icons.medical_services_outlined,
      route: '/therapy-booking-screen',
    ),
    CustomTab(
      text: 'Consultations',
      icon: Icons.video_call_outlined,
      route: '/live-session-tracking-screen',
    ),
    CustomTab(
      text: 'Reports',
      icon: Icons.assessment_outlined,
    ),
    CustomTab(
      text: 'Medicines',
      icon: Icons.medication_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomTabBar(
      tabs: healthcareTabs,
      variant: CustomTabBarVariant.primary,
      initialIndex: currentIndex,
      onTap: (index) {
        if (onTap != null) {
          onTap!(index);
        }

        // Handle navigation based on tab selection
        final selectedTab = healthcareTabs[index];
        if (selectedTab.route != null) {
          Navigator.pushNamed(context, selectedTab.route!);
        }
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}

// Therapy progress tab bar for treatment tracking
class TherapyProgressTabBar extends StatelessWidget
    implements PreferredSizeWidget {
  final int currentPhase;
  final ValueChanged<int>? onPhaseChanged;

  const TherapyProgressTabBar({
    super.key,
    this.currentPhase = 0,
    this.onPhaseChanged,
  });

  static const List<CustomTab> therapyPhases = [
    CustomTab(text: 'Assessment', icon: Icons.assignment_outlined),
    CustomTab(text: 'Treatment', icon: Icons.healing_outlined),
    CustomTab(text: 'Recovery', icon: Icons.trending_up_outlined),
    CustomTab(text: 'Maintenance', icon: Icons.health_and_safety_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomTabBar(
      tabs: therapyPhases,
      variant: CustomTabBarVariant.pills,
      initialIndex: currentPhase,
      selectedColor: theme.colorScheme.tertiary, // Ayurvedic accent color
      onTap: onPhaseChanged,
      isScrollable: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}
