import 'package:brand_store_app/models/category_model.dart';
import 'package:brand_store_app/models/shirt_model.dart';
import 'package:brand_store_app/providers/cart_provider.dart';
import 'package:brand_store_app/resources/app_data.dart';
import 'package:brand_store_app/services/supabase_service.dart';
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
  List<BrandCategory> categories = [];
  bool isLoading = true;
  bool isCategoryLoading = true;
  int _currentCarouselIndex = 0;
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
    _loadCategories();
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

  Future<void> _loadCategories() async {
    setState(() {
      isCategoryLoading = true;
    });

    try {
      final fetched = await SupabaseService.getCategories();
      if (fetched.isNotEmpty) {
        setState(() {
          categories = fetched;
          isCategoryLoading = false;
        });
      } else {
        // Fallback to AppData (local JSON) if Supabase empty
        setState(() {
          categories = AppData.categories;
          isCategoryLoading = false;
        });
      }
    } catch (e) {
      print('Error loading categories from Supabase: $e');
      setState(() {
        categories = AppData.categories;
        isCategoryLoading = false;
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

  // ignore: unused_element
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGreeting(context),
                        const SizedBox(height: 24),
                        _buildCarousel(context),
                        const SizedBox(height: 28),
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
            color:
                Theme.of(context).colorScheme.inverseSurface.withOpacity(0.6),
            fontSize: MediaQuery.textScalerOf(context).scale(15),
          ),
        ),
      ],
    );
  }

  Widget _buildCarousel(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get first 5 products as deal items
    final dealItems = AppData.products.take(2).toList();

    if (dealItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Carousel
        SizedBox(
          height: 200,
          child: PageView.builder(
            onPageChanged: (index) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
            itemCount: dealItems.length,
            itemBuilder: (context, index) {
              final product = dealItems[index];
              return _buildCarouselCard(context, product, isDark);
            },
          ),
        ),
        const SizedBox(height: 12),
        // Dots indicator
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              dealItems.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentCarouselIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentCarouselIndex == index
                      ? Colors.red.shade400
                      : Colors.red.shade400.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselCard(
      BuildContext context, ShirtModel product, bool isDark) {
    final theme = Theme.of(context);

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
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              isDark ? Colors.grey.shade800 : Colors.white,
              isDark ? Colors.grey.shade700 : Colors.white
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Left side - Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Top deal!",
                      style: GoogleFonts.imprima(
                        fontSize: 13,
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.name.toUpperCase(),
                      style: GoogleFonts.imprima(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "UP TO 15% OFF",
                      style: GoogleFonts.imprima(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Shop Now",
                        style: GoogleFonts.imprima(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Right side - Product image
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isDark
                        ? Colors.grey.shade700
                        : Colors.white.withOpacity(0.4),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
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
            ],
          ),
        ),
      ),
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
    return SizedBox(
      height: 90,
      child: isCategoryLoading
          ? const Center(
              child: SizedBox(
                  height: 24, width: 24, child: CircularProgressIndicator()))
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final dynamic rawCategory = categories[index];

                // Normalize category shape — support BrandCategory or Map from Supabase
                BrandCategory? categoryModel;
                String disp = '';
                BrandType catType = BrandType.all;

                if (rawCategory is BrandCategory) {
                  categoryModel = rawCategory;
                  disp = categoryModel.displayName;
                  catType = categoryModel.type;
                } else if (rawCategory is Map<String, dynamic>) {
                  disp = (rawCategory['display_name'] ?? rawCategory['name'] ?? rawCategory['id'] ?? '').toString();
                  // try to map id to BrandType
                  final id = (rawCategory['id'] ?? 'all').toString();
                  switch (id) {
                    case 'readyMeals':
                      catType = BrandType.readyMeals;
                      break;
                    case 'ingredients':
                      catType = BrandType.ingredients;
                      break;
                    case 'snacks':
                      catType = BrandType.snacks;
                      break;
                    case 'beverages':
                      catType = BrandType.beverages;
                      break;
                    case 'seasonings':
                      catType = BrandType.seasonings;
                      break;
                    case 'all':
                    default:
                      catType = BrandType.all;
                  }
                } else if (rawCategory != null) {
                  disp = rawCategory.toString();
                }

                final isSelected = catType == selectedCategory;

                return GestureDetector(
                  onTap: () => _filterProductsByCategory(catType),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    width: 110,
                    decoration: BoxDecoration(
                      color:
                          isSelected ? Colors.red.shade400 : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: Colors.red.shade400.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display emoji + label parsed from `disp` safely
                        Builder(builder: (ctx) {
                          final splitIndex = disp.indexOf(' ');
                          final emoji = splitIndex > 0
                              ? disp.substring(0, splitIndex)
                              : (disp.isNotEmpty ? disp.substring(0, 1) : '');
                          final label = splitIndex > 0
                              ? disp.substring(splitIndex + 1)
                              : (disp.length > 1 ? disp.substring(1) : '');

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                emoji,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                label,
                                style: GoogleFonts.imprima(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context)
                                          .colorScheme
                                          .inverseSurface
                                          .withOpacity(0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        }),
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
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
    final accentPalette = isDark ? _cardAccentColorsDark : _cardAccentColors;
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

  // removed hardcoded emoji/label mapping; categories come from Supabase/BrandCategory
}
