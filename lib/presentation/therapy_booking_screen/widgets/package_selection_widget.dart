import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class PackageSelectionWidget extends StatefulWidget {
  final List<TherapyPackage> packages;
  final TherapyPackage? selectedPackage;
  final Function(TherapyPackage) onPackageSelected;

  const PackageSelectionWidget({
    super.key,
    required this.packages,
    this.selectedPackage,
    required this.onPackageSelected,
  });

  @override
  State<PackageSelectionWidget> createState() => _PackageSelectionWidgetState();
}

class _PackageSelectionWidgetState extends State<PackageSelectionWidget> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);

    // Set initial selection if provided
    if (widget.selectedPackage != null) {
      _currentIndex = widget.packages.indexWhere(
        (package) => package.id == widget.selectedPackage!.id,
      );
      if (_currentIndex == -1) _currentIndex = 0;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Therapy Packages',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all packages view
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Package cards
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              widget.onPackageSelected(widget.packages[index]);
            },
            itemCount: widget.packages.length,
            itemBuilder: (context, index) {
              final package = widget.packages[index];
              final isSelected = widget.selectedPackage?.id == package.id;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildPackageCard(context, package, isSelected),
              );
            },
          ),
        ),

        // Page indicator
        if (widget.packages.length > 1) ...[
          const SizedBox(height: 16),
          _buildPageIndicator(theme),
        ],
      ],
    );
  }

  Widget _buildPackageCard(
      BuildContext context, TherapyPackage package, bool isSelected) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => widget.onPackageSelected(package),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.2)
                  : theme.colorScheme.shadow.withValues(alpha: 0.1),
              offset: const Offset(0, 4),
              blurRadius: isSelected ? 12 : 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Package image and badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: CustomImageWidget(
                    imageUrl: package.imageUrl,
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),

                // Popular badge
                if (package.isPopular) ...[
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Popular',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onTertiary,
                        ),
                      ),
                    ),
                  ),
                ],

                // Discount badge
                if (package.discountPercentage > 0) ...[
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${package.discountPercentage}% OFF',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onError,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Package details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Package name
                    Text(
                      package.name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Duration and sessions
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          color: theme.colorScheme.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${package.duration} days',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(width: 12),
                        CustomIconWidget(
                          iconName: 'event',
                          color: theme.colorScheme.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${package.sessions} sessions',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Benefits
                    Expanded(
                      child: Text(
                        package.benefits,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (package.discountPercentage > 0) ...[
                              Text(
                                '₹${package.originalPrice.toStringAsFixed(0)}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                            Text(
                              '₹${package.finalPrice.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),

                        // GST info
                        Text(
                          '+GST',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(ThemeData theme) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          widget.packages.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentIndex == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentIndex == index
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}

class TherapyPackage {
  final String id;
  final String name;
  final String imageUrl;
  final int duration;
  final int sessions;
  final String benefits;
  final double originalPrice;
  final double finalPrice;
  final int discountPercentage;
  final bool isPopular;
  final List<String> therapySequence;

  TherapyPackage({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.duration,
    required this.sessions,
    required this.benefits,
    required this.originalPrice,
    required this.finalPrice,
    required this.discountPercentage,
    required this.isPopular,
    required this.therapySequence,
  });
}
