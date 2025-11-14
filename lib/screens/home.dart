import 'package:brand_store_app/models/category_model.dart';
import 'package:brand_store_app/models/shirt_model.dart';
import 'package:brand_store_app/providers/cart_provider.dart';
import 'package:brand_store_app/resources/app_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  BrandType selectedCategory = BrandType.all;
  List<ShirtModel> selectedItems = [];
  bool isLoading = true;
  final _cardAccentColors = const [
    Color(0xFFFFF1F5),
    Color(0xFFEFF6FF),
    Color(0xFFFFF8E7),
    Color(0xFFF4F1FF),
  ];
  final _cardAccentColorsDark = const [
    Color(0xFF2B2B3A),
    Color(0xFF1F2A36),
    Color(0xFF2F2622),
    Color(0xFF1F2F2A),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await AppData.loadAllData();
      setState(() {
        selectedItems = AppData.products;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterProductsByCategory(BrandType category) {
    setState(() {
      selectedCategory = category;
      if (category == BrandType.all) {
        selectedItems = AppData.products;
      } else {
        selectedItems = AppData.products
            .where((product) => product.category == category.name)
            .toList();
      }
    });
  }

  Widget _buildCartIconWithBadge() {
    final cartItems = ref.watch(cartProvider);
    final totalQuantity = cartItems.fold(0, (sum, item) => sum + item.quantity);
    
    return Stack(
      children: [
        const ImageIcon(
          AssetImage("assets/icons/bag.png"),
          size: 30,
        ),
        if (totalQuantity > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '$totalQuantity',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
      ),
      child: Scaffold(
        // backgroundColor: Theme.of(context).brightness == Brightness.dark
        //     ? Theme.of(context).colorScheme.background
        //     : const Color(0xFFF5F6FF),
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   foregroundColor: Theme.of(context).colorScheme.inverseSurface,
        //   elevation: 0,
        //   forceMaterialTransparency: true,
        //   toolbarHeight: 72,
        //   leadingWidth: 72,
        //   leading: IconButton(
        //     onPressed: () {
        //       Navigator.pushNamed(context, '/settings');
        //     },
        //     icon: const ImageIcon(
        //       size: 28,
        //       AssetImage("assets/icons/menu.png"),
        //     ),
        //   ),
        //   actions: [
        //     IconButton(
        //       onPressed: () {
        //         Navigator.pushNamed(context, "/cart");
        //       },
        //       icon: _buildCartIconWithBadge(),
        //     )
        //   ],
        // ),
        
        // bottomNavigationBar: null,
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGreeting(context),
                        const SizedBox(height: 24),
                        _buildSectionHeader(
                          context,
                          title: "Categories",
                          actionLabel: "",
                        ),
                        const SizedBox(height: 16),
                        _buildCategoryList(context),
                        const SizedBox(height: 28),
                        _buildSectionHeader(
                          context,
                          title: "Most Popular",
                          actionLabel: "",
                        ),
                        const SizedBox(height: 12),
                        // _buildHeadline(context),
                        // const SizedBox(height: 18),
                        _buildProductGrid(context),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "47 Market",
          style: GoogleFonts.imprima(
            fontSize: MediaQuery.textScalerOf(context).scale(32),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Your neighborhood, your market",
          style: GoogleFonts.imprima(
            color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.6),
            fontSize: MediaQuery.textScalerOf(context).scale(15),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String actionLabel,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.imprima(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            padding: EdgeInsets.zero,
          ),
          child: Text(
            actionLabel,
            style: GoogleFonts.imprima(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedColor =
        isDark ? theme.colorScheme.surface : Colors.white;
    final unselectedColor = isDark
        ? theme.colorScheme.surface.withOpacity(0.5)
        : Colors.white.withOpacity(0.5);
    final selectedShadow = isDark
        ? Colors.black.withOpacity(0.35)
        : Colors.black.withOpacity(0.08);

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppData.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = AppData.categories[index];
          final isSelected = category.type == selectedCategory;

          return GestureDetector(
            onTap: () => _filterProductsByCategory(category.type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              width: 110,
              decoration: BoxDecoration(
                color: isSelected ? selectedColor : unselectedColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: selectedShadow,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _categoryEmoji(category.type),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _categoryLabel(category.type),
                    style: GoogleFonts.imprima(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Theme.of(context).colorScheme.inverseSurface
                          : Theme.of(context)
                              .colorScheme
                              .inverseSurface
                              .withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    if (selectedItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            "No products to show",
            style: GoogleFonts.imprima(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.5),
            ),
          ),
        ),
      );
    }

    final itemsSnapshot = List<ShirtModel>.from(selectedItems);

    return MasonryGridView.count(
      itemCount: itemsSnapshot.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemBuilder: (context, index) {
        final product = itemsSnapshot[index];
        return _buildProductCard(context, product, index);
      },
    );
  }

  Widget _buildProductCard(
      BuildContext context, ShirtModel product, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentPalette =
        isDark ? _cardAccentColorsDark : _cardAccentColors;
    final accent = accentPalette[index % accentPalette.length];
    final cardColor = theme.colorScheme.surface;
    final shadowColor =
        isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.06);
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/details',
          arguments: {
            'shirt': product,
            'prefix': 'home',
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: [180.0, 210.0, 240.0][index % 3],
                decoration: BoxDecoration(
                  color: isDark ? accent.withOpacity(0.8) : accent,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: (product.networkImage ?? false)
                        ? Image.network(
                            product.thumbnail ?? product.image,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            product.image,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.imprima(
                  fontSize: 16,
                  // fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '฿${product.price.toStringAsFixed(2)}',
                        style: GoogleFonts.imprima(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "per pack",
                        style: GoogleFonts.imprima(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .inverseSurface
                              .withOpacity(0.45),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      ref.read(cartProvider.notifier).addItem(product);
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.add,
                        color: theme.colorScheme.onPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  String _categoryEmoji(BrandType type) {
    switch (type) {
      case BrandType.all:
        return "🛍";
      case BrandType.readyMeals:
        return "🍱";
      case BrandType.ingredients:
        return "🥬";
      case BrandType.snacks:
        return "🍪";
      case BrandType.beverages:
        return "🥤";
      case BrandType.seasonings:
        return "🧂";
    }
  }

  String _categoryLabel(BrandType type) {
    switch (type) {
      case BrandType.all:
        return "All";
      case BrandType.readyMeals:
        return "Prepared";
      case BrandType.ingredients:
        return "Ingredients";
      case BrandType.snacks:
        return "Snacks";
      case BrandType.beverages:
        return "Drinks";
      case BrandType.seasonings:
        return "Seasonings";
    }
  }
}