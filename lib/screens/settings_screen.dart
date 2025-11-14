
import 'package:brand_store_app/providers/theme_provider.dart';
import 'package:brand_store_app/providers/favorite_provider.dart';
import 'package:brand_store_app/providers/cart_provider.dart';
import 'package:brand_store_app/screens/onboarding.dart';
import 'package:brand_store_app/services/auth_service.dart';
import 'package:brand_store_app/services/storage_service.dart';
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
  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Clear Cache',
            style: GoogleFonts.imprima(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'This will clear all stored data including:\n• Cart items\n• Favorite items\n• Theme settings\n• Checkout information\n\nThis action cannot be undone.',
            style: GoogleFonts.imprima(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.imprima(fontSize: 16, color: Colors.grey[600]),
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
                style: GoogleFonts.imprima(fontSize: 16, color: Colors.red),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.inverseSurface,
        elevation: 0,
        forceMaterialTransparency: true,
        // toolbarHeight: 100,
        leadingWidth: 100,
        primary: true,
        // leading: IconButton(
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        //   icon: const ImageIcon(
        //     size: 30,
        //     AssetImage("assets/icons/back_arrow.png"),
        //   ),
        // ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const ImageIcon(
              size: 40,
              AssetImage("assets/icons/profile.png"),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Settings",
              style: GoogleFonts.imprima(
                  fontWeight: FontWeight.w500,
                  fontSize: MediaQuery.textScalerOf(context).scale(40)),
            ),
            // Text(
            //   "Your Neighborhood, Your Market..",
            //   style: GoogleFonts.imprima(
            //     fontWeight: FontWeight.w300,
            //     color: Theme.of(context)
            //         .colorScheme
            //         .inverseSurface
            //         .withOpacity(0.7),
            //     fontSize: MediaQuery.textScalerOf(context).scale(15),
            //   ),
            // ),
            Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                ListTile(
                  title: Text('Dark Theme',
                      style: GoogleFonts.imprima(fontSize: 18)),
                  trailing: ShadSwitch(
                    value: ref.watch(themeModeProvider) == ThemeMode.dark,
                    onChanged: (value) {
                      ref.read(themeModeProvider.notifier).toggleTheme();
                    },
                  ),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  title:
                      Text('Favorite', style: GoogleFonts.imprima(fontSize: 18)),
                  trailing: Consumer(
                    builder: (context, ref, child) {
                      final favorites = ref.watch(favoriteProvider);
                      return Text(
                        '${favorites.length} Item',
                        style: GoogleFonts.imprima(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.7),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/favorites');
                  },
                ),
                const Divider(),
                ListTile(
                  title: Text('Clear Cache', style: GoogleFonts.imprima(fontSize: 18)),
                  subtitle: Text('Clear all stored data', style: GoogleFonts.imprima(fontSize: 14)),
                  trailing: const Icon(Icons.delete_outline),
                  onTap: () {
                    _showClearCacheDialog(context);
                  },
                ),
                const Divider(),
                // ListTile(
                //   title:
                //       Text('Logout', style: GoogleFonts.imprima(fontSize: 18)),
                //   onTap: () async {
                //     if (mounted) {
                //       showDialog(
                //         context: context,
                //         builder: (context) => const Center(
                //           child: CircularProgressIndicator(),
                //         ),
                //       );
                //       await AuthService().signOut();
                //       await Future.delayed(const Duration(seconds: 1));

                //       Navigator.pop(context);
                //       Navigator.pushAndRemoveUntil(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => const Onboarding(),
                //         ),
                //         (route) => false,
                //       );
                //     }
                //   },
                // ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
