import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeInAnimation;
  Timer? _minimumDisplayTimer;

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.authenticationEntryScreen);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    _minimumDisplayTimer = Timer(const Duration(seconds: 3), _navigateToLogin);
  }

  @override
  void dispose() {
    _minimumDisplayTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Size size = MediaQuery.of(context).size;
    final bool isDark = theme.brightness == Brightness.dark;

    return Semantics(
      label: 'Splash screen',
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth > 600;
              final double logoSize = isWide ? size.width * 0.2 : size.width * 0.35;

              return Stack(
                children: [
                  // Background image with graceful fallback to gradient
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isDark
                              ? [
                                  const Color(0xFF0B1F14),
                                  const Color(0xFF133821),
                                ]
                              : [
                                  const Color(0xFFE9F5EC),
                                  const Color(0xFFCDE7D8),
                                ],
                        ),
                      ),
                    ),
                  ),
                  // Background pattern or texture can be added here if needed
                  Center(
                    child: FadeTransition(
                      opacity: _fadeInAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Semantics(
                            label: 'Ayursutra logo',
                            image: true,
                            child: Image.asset(
                              'assets/images/Ayursutra_Logo_1_-1759156879861.png',
                              width: logoSize,
                              height: logoSize,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to a simple icon if image fails to load
                                return Icon(
                                  Icons.health_and_safety,
                                  size: logoSize,
                                  color: theme.colorScheme.primary,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'AyurSutra',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Personalized panchakarma care, guided by AI-driven wellness.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                              ),
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(height: 28),
                          const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Semantics(
                      button: true,
                      label: 'Skip splash',
                      child: TextButton(
                        onPressed: _navigateToLogin,
                        child: const Text('Skip'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}


