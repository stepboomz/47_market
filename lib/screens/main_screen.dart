import 'package:brand_store_app/providers/cart_provider.dart';
import 'package:brand_store_app/screens/cart.dart';
import 'package:brand_store_app/screens/favorites_screen.dart';
import 'package:brand_store_app/screens/home.dart';
import 'package:brand_store_app/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: selectedIndex,
            children: const [
              Home(),
              Cart(),
              FavoritesScreen(),
              SettingsScreen(),
            ],
          ),
          _buildFloatingBottomNav(context),
        ],
      ),
    );
  }

  Widget _buildFloatingBottomNav(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF1F1F2B) : theme.colorScheme.surface;

    final navItems = [
      {"icon": Icons.home_rounded, "label": "Home"},
      {
        "icon": null,
        "asset": "assets/icons/bag.png",
        "tag": "cart",
        "label": "Cart"
      },
      {
        "icon": null,
        "asset": "assets/icons/save.png",
        "tag": "Favorites",
        "label": "Favorites"
      },
      {"icon": Icons.person_rounded, "label": "Profile"},
    ];

    return Positioned(
      bottom: 10,
      left: 16,
      right: 16,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.5 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(navItems.length, (index) {
            final isSelected = selectedIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          navItems[index]["asset"] != null
                              ? ImageIcon(
                                  AssetImage(
                                      navItems[index]["asset"] as String),
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                  size: 24,
                                )
                              : Icon(
                                  navItems[index]["icon"] as IconData,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                  size: 24,
                                ),
                          if (navItems[index]["tag"] == "cart")
                            Positioned(
                              right: -6,
                              top: -6,
                              child: _CartBadge(),
                            ),
                        ],
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 4),
                        Text(
                          navItems[index]["label"] as String,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _CartBadge extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(cartProvider.select(
        (items) => items.fold<int>(0, (sum, item) => sum + item.quantity)));
    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        total > 99 ? '99+' : '$total',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
