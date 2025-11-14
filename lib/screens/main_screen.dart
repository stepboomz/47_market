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
    final navItems = [
      {"icon": Icons.home_outlined, "label": "Home"},
      {
        "icon": Icons.shopping_bag_outlined,
        "tag": "cart",
        "label": "Cart"
      },
      {
        "icon": null,
        "asset": "assets/icons/save.png",
        "tag": "favorites",
        "label": "favorites"
      },
      {"icon": Icons.person_outline, "label": "Profile"},
    ];

    return Positioned(
      bottom: 10,
      left: 16,
      right: 16,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFF2B2B2B), // Dark grey background
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
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
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 12,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // White circular background for active icon
                            if (isSelected)
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            // Icon
                            Center(
                              child: navItems[index]["asset"] != null
                                  ? ImageIcon(
                                      AssetImage(
                                          navItems[index]["asset"] as String),
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.white,
                                      size: 24,
                                    )
                                  : navItems[index]["icon"] != null
                                      ? Icon(
                                          navItems[index]["icon"] as IconData,
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.white,
                                          size: 24,
                                        )
                                      : const SizedBox.shrink(),
                            ),
                            // Cart badge
                            if (navItems[index]["tag"] == "cart")
                              Positioned(
                                right: -6,
                                top: -6,
                                child: _CartBadge(),
                              ),
                          ],
                        ),
                      ),
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
