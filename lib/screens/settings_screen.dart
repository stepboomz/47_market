import 'package:brand_store_app/providers/theme_provider.dart';
import 'package:brand_store_app/providers/favorite_provider.dart';
import 'package:brand_store_app/providers/cart_provider.dart';
import 'package:brand_store_app/services/auth_service.dart';
import 'package:brand_store_app/screens/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!AuthService().isLoggedIn) {
      return;
    }

    try {
      final profile = await AuthService().getCurrentUserProfile();
      setState(() {
        _userProfile = profile;
      });
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  void _showClearCacheDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          title: Text(
            'Clear Cache',
            style: GoogleFonts.chakraPetch(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'This will clear all stored data including:\n• Cart items\n• Favorite items\n• Theme settings\n• Checkout information\n\nThis action cannot be undone.',
            style: GoogleFonts.chakraPetch(
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.chakraPetch(
                  fontSize: 16,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _clearAllData();
                if (mounted) {
                  ShadToaster.of(context).show(
                    ShadToast(
                      title: Text('Cache cleared successfully'),
                      duration: const Duration(milliseconds: 2000),
                    ),
                  );
                }
              },
              child: Text(
                'Clear',
                style: GoogleFonts.chakraPetch(
                  fontSize: 16,
                  color: colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearAllData() async {
    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Clear providers
      ref.read(cartProvider.notifier).clearCart();
      ref.read(favoriteProvider.notifier).clearFavorites();

      // Reset theme to default
      ref.read(themeModeProvider.notifier).setTheme(ThemeMode.light);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
                          // Show confirmation dialog for logout
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
                                title: Text(
                                  'Logout',
                                  style: GoogleFonts.chakraPetch(
                                      fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
                                ),
                                content: Text(
                                  'Are you sure you want to logout?',
            style: GoogleFonts.chakraPetch(
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
                                ),
                                actions: [
                                  TextButton(
              onPressed: () => Navigator.of(context).pop(),
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.chakraPetch(
                                          fontSize: 16,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                // Close confirmation dialog first
                                      Navigator.of(context).pop();

                                      // Show loading indicator
                if (!mounted) return;
                
                // Store navigator before async operations
                final navigator = Navigator.of(context);
                
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                  builder: (dialogContext) => Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                                        ),
                                      );

                                      try {
                                        await AuthService().signOut();

                  // Navigate to onboarding screen (this will remove all routes including loading dialog)
                                        if (mounted) {
                    navigator.pushAndRemoveUntil(
                                            MaterialPageRoute(
                        builder: (context) => const Onboarding(),
                                            ),
                                            (route) => false,
                                          );
                                        }
                                      } catch (e) {
                  // Only pop loading dialog if still mounted and navigator is valid
                                        if (mounted) {
                    try {
                      navigator.pop(); // Remove loading indicator
                    } catch (_) {
                      // Navigator might be disposed, ignore
                    }

                    // Show error message only if context is still valid
                    if (mounted) {
                      try {
                                          ShadToaster.of(context).show(
                                            ShadToast(
                                              title: Text('Logout Failed'),
                                              description: Text(e.toString()),
                            duration: const Duration(milliseconds: 3000),
                                            ),
                                          );
                      } catch (_) {
                        // Context might be disposed, ignore
                      }
                    }
                                        }
                                      }
                                    },
                                    child: Text(
                                      'Logout',
                                      style: GoogleFonts.chakraPetch(
                  fontSize: 16,
                  color: colorScheme.error,
                ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
  }

  String _getInitials(String? name, String? email) {
    if (name != null && name.isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
      } else if (parts.isNotEmpty) {
        return parts[0][0].toUpperCase();
      }
    }
    if (email != null && email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return 'U';
  }

  double _calculateProfileCompletion() {
    if (!AuthService().isLoggedIn) return 0.0;
    
    int completed = 0;
    int total = 5;
    
    if (_userProfile?['full_name'] != null && 
        (_userProfile!['full_name'] as String).isNotEmpty) completed++;
    if (_userProfile?['email'] != null && 
        (_userProfile!['email'] as String).isNotEmpty) completed++;
    if (_userProfile?['phone'] != null && 
        (_userProfile!['phone'] as String).isNotEmpty) completed++;
    if (_userProfile?['address'] != null && 
        (_userProfile!['address'] as String).isNotEmpty) completed++;
    if (AuthService().currentUserEmail != null) completed++;
    
    return completed / total;
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isLoggedIn = AuthService().isLoggedIn;
    final userEmail = AuthService().currentUserEmail;
    final userName = _userProfile?['full_name'] as String?;
    final profileCompletion = _calculateProfileCompletion();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName ?? 'Guest User',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail ?? 'Not logged in',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 14,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Progress Bar (always show to maintain layout)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: isLoggedIn ? profileCompletion : 0.0,
                                backgroundColor: isDark
                                    ? colorScheme.surfaceVariant
                                    : Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.primary,
                                ),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isLoggedIn
                                  ? '${(profileCompletion * 100).toInt()}% Complete profile'
                                  : '0% Complete profile',
                              style: GoogleFonts.chakraPetch(
                                fontSize: 12,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Edit Profile Button (only show if logged in)
                        if (isLoggedIn)
                          OutlinedButton(
                            onPressed: () async {
                              final result = await Navigator.pushNamed(
                                context,
                                '/edit-profile',
                              );
                              if (result == true) {
                                // Reload profile if saved successfully
                                await _loadProfile();
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: colorScheme.primary,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: Text(
                              'Edit Profile',
                              style: GoogleFonts.chakraPetch(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Profile Picture
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(userName, userEmail),
                        style: GoogleFonts.chakraPetch(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Menu Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Order History
                  if (isLoggedIn)
                    _buildMenuItem(
                      context,
                      icon: Icons.history,
                      title: 'Order History',
                      subtitle: 'View your order history',
                      onTap: () {
                        Navigator.pushNamed(context, '/order-history');
                      },
                    ),
                  
                  // Favorites
                  // _buildMenuItem(
                  //   context,
                  //   icon: Icons.favorite_outline,
                  //   title: 'Favorites',
                  //   subtitle: '${ref.watch(favoriteProvider).length} items saved',
                  //   onTap: () {
                  //     Navigator.pushNamed(context, '/favorites');
                  //   },
                  // ),

                  // Theme
                  _buildMenuItem(
                    context,
                    icon: Icons.palette_outlined,
                    title: 'Theme',
                    subtitle: ref.watch(themeModeProvider) == ThemeMode.dark
                        ? 'Dark mode enabled'
                        : 'Light mode enabled',
                    trailing: ShadSwitch(
                      value: ref.watch(themeModeProvider) == ThemeMode.dark,
                      onChanged: (value) {
                        ref.read(themeModeProvider.notifier).toggleTheme();
                      },
                    ),
                    onTap: () {
                      ref.read(themeModeProvider.notifier).toggleTheme();
                    },
                  ),

                  // Notifications
                  // _buildMenuItem(
                  //   context,
                  //   icon: Icons.notifications_outlined,
                  //   title: 'Notifications',
                  //   subtitle: 'Customize app notifications',
                  //   onTap: () {
                  //     // TODO: Navigate to notifications settings
                  //   },
                  // ),

                  // Clear Cache
                  _buildMenuItem(
                    context,
                    icon: Icons.delete_outline,
                    title: 'Clear Cache',
                    subtitle: 'Clear all stored data',
                    onTap: () {
                      _showClearCacheDialog(context);
                    },
                  ),

                  // Get Help
                  // _buildMenuItem(
                  //   context,
                  //   icon: Icons.help_outline,
                  //   title: 'Get Help',
                  //   subtitle: 'Contact support',
                  //   onTap: () {
                  //     // TODO: Navigate to help screen
                  //   },
                  // ),

                  // Give Feedback
                  // _buildMenuItem(
                  //   context,
                  //   icon: Icons.feedback_outlined,
                  //   title: 'Give us feedback',
                  //   subtitle: 'Share your thoughts',
                  //   onTap: () {
                  //     // TODO: Navigate to feedback screen
                //   },
                // ),

                  if (isLoggedIn)
                    _buildMenuItem(
                      context,
                      icon: Icons.logout,
                      title: 'Logout',
                      subtitle: 'Sign out from your account',
                      onTap: () {
                        _handleLogout(context);
                      },
                    )
                  else
                    _buildMenuItem(
                      context,
                      icon: Icons.login,
                      title: 'Login',
                      subtitle: 'Sign in to your account',
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surfaceVariant
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: colorScheme.onSurface,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.chakraPetch(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.chakraPetch(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Trailing widget or arrow
            if (trailing != null)
              trailing
            else
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withOpacity(0.4),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
