import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomAppBarVariant {
  primary,
  secondary,
  transparent,
  search,
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final CustomAppBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onSearchTap;
  final String? searchHint;
  final bool showNotificationBadge;
  final VoidCallback? onNotificationTap;

  const CustomAppBar({
    super.key,
    this.title,
    this.variant = CustomAppBarVariant.primary,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = false,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
    this.onSearchTap,
    this.searchHint,
    this.showNotificationBadge = false,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: _buildTitle(context),
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      elevation: _getElevation(),
      backgroundColor: _getBackgroundColor(colorScheme),
      foregroundColor: _getForegroundColor(colorScheme),
      systemOverlayStyle: _getSystemOverlayStyle(colorScheme),
      actions: _buildActions(context),
      bottom: bottom,
      flexibleSpace: variant == CustomAppBarVariant.transparent
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget? _buildTitle(BuildContext context) {
    if (title == null) return null;

    final theme = Theme.of(context);

    switch (variant) {
      case CustomAppBarVariant.search:
        return GestureDetector(
          onTap: onSearchTap,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(
                  Icons.search,
                  size: 20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    searchHint ?? 'Search treatments, doctors...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      default:
        return Text(
          title!,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _getForegroundColor(theme.colorScheme),
          ),
        );
    }
  }

  List<Widget>? _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final defaultActions = <Widget>[];

    // Add notification icon for healthcare apps
    if (variant != CustomAppBarVariant.search) {
      defaultActions.add(
        Stack(
          children: [
            IconButton(
              onPressed: onNotificationTap ??
                  () {
                    // Default navigation to notifications
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifications feature coming soon'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
              icon: const Icon(Icons.notifications_outlined),
              tooltip: 'Notifications',
            ),
            if (showNotificationBadge)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Add profile/menu icon
    defaultActions.add(
      PopupMenuButton<String>(
        onSelected: (value) => _handleMenuSelection(context, value),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'profile',
            child: Row(
              children: [
                const Icon(Icons.person_outline),
                const SizedBox(width: 12),
                Text(
                  'Profile',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'settings',
            child: Row(
              children: [
                const Icon(Icons.settings_outlined),
                const SizedBox(width: 12),
                Text(
                  'Settings',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'help',
            child: Row(
              children: [
                const Icon(Icons.help_outline),
                const SizedBox(width: 12),
                Text(
                  'Help & Support',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                const Icon(Icons.logout),
                const SizedBox(width: 12),
                Text(
                  'Logout',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
        icon: const Icon(Icons.more_vert),
        tooltip: 'More options',
      ),
    );

    return actions ?? defaultActions;
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'profile':
        // Navigate to profile or show profile options
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile feature coming soon'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'settings':
        // Navigate to settings
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings feature coming soon'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'help':
        // Navigate to help
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Help & Support feature coming soon'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'logout':
        // Navigate to authentication
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/multi-role-authentication-screen',
          (route) => false,
        );
        break;
    }
  }

  double _getElevation() {
    if (elevation != null) return elevation!;

    switch (variant) {
      case CustomAppBarVariant.transparent:
        return 0.0;
      case CustomAppBarVariant.search:
        return 0.0;
      default:
        return 1.0; // Minimal elevation for healthcare trust
    }
  }

  Color _getBackgroundColor(ColorScheme colorScheme) {
    if (backgroundColor != null) return backgroundColor!;

    switch (variant) {
      case CustomAppBarVariant.primary:
        return colorScheme.surface;
      case CustomAppBarVariant.secondary:
        return colorScheme.primary;
      case CustomAppBarVariant.transparent:
        return Colors.transparent;
      case CustomAppBarVariant.search:
        return colorScheme.surface;
    }
  }

  Color _getForegroundColor(ColorScheme colorScheme) {
    if (foregroundColor != null) return foregroundColor!;

    switch (variant) {
      case CustomAppBarVariant.primary:
        return colorScheme.onSurface;
      case CustomAppBarVariant.secondary:
        return colorScheme.onPrimary;
      case CustomAppBarVariant.transparent:
        return Colors.white;
      case CustomAppBarVariant.search:
        return colorScheme.onSurface;
    }
  }

  SystemUiOverlayStyle _getSystemOverlayStyle(ColorScheme colorScheme) {
    switch (variant) {
      case CustomAppBarVariant.transparent:
        return SystemUiOverlayStyle.light;
      case CustomAppBarVariant.secondary:
        return colorScheme.brightness == Brightness.light
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark;
      default:
        return colorScheme.brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light;
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
