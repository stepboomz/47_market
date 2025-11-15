import 'package:brand_store_app/models/category_model.dart';
import 'package:brand_store_app/models/shirt_model.dart';
import 'package:brand_store_app/providers/cart_provider.dart';
import 'package:brand_store_app/resources/app_data.dart';
import 'package:brand_store_app/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      await AppData.loadAllData();
      setState(() {
        selectedItems = _getFilteredProducts(selectedCategory, _searchQuery);
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
          selectedItems = _getFilteredProducts(selectedCategory, _searchQuery);
        });
      } else {
        setState(() {
          categories = AppData.categories;
          isCategoryLoading = false;
          selectedItems = _getFilteredProducts(selectedCategory, _searchQuery);
        });
      }
    } catch (e) {
      print('Error loading categories from Supabase: $e');
      setState(() {
        categories = AppData.categories;
        isCategoryLoading = false;
        selectedItems = _getFilteredProducts(selectedCategory, _searchQuery);
      });
    }
  }

  void _filterProductsByCategory(BrandType category) {
    setState(() {
      selectedCategory = category;
      selectedItems = _getFilteredProducts(category, _searchQuery);
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      selectedItems = _getFilteredProducts(selectedCategory, query);
    });
  }

  List<ShirtModel> _getFilteredProducts(BrandType category, String searchQuery) {
    List<ShirtModel> filtered = [];
    final isCategoryActive = _isCategoryActive(category);

    if (!isCategoryActive && category != BrandType.all) {
      filtered = [];
    } else if (category == BrandType.all) {
      final activeCategories = categories
          .where((cat) => cat.type != BrandType.all)
          .map((cat) => cat.type.name)
          .toList();
      filtered = AppData.products
          .where((product) => activeCategories.contains(product.category))
          .toList();
    } else {
      filtered = AppData.products
          .where((product) => product.category == category.name)
          .toList();
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((product) =>
              product.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  bool _isCategoryActive(BrandType type) {
    try {
      categories.firstWhere((c) => c.type == type);
      return true;
    } catch (e) {
      return type == BrandType.all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: isLoading
          ? const Center(
              child: SpinKitDancingSquare(
                color: Colors.red,
                size: 50.0,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNewArrivalsBanner(context),
                    // const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSearchBar(context),
                    ),
                    if (_searchQuery.isEmpty) ...[
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildCategoriesSection(context),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildForYouSection(context),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNewArrivalsBanner(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top icons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Grid icon
                Container(
                  padding: const EdgeInsets.all(8),
                  // decoration: BoxDecoration(
                  //   color: isDark
                  //       ? Colors.white.withOpacity(0.1)
                  //       : Colors.grey.shade200,
                  //   borderRadius: BorderRadius.circular(8),
                  // ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/logo.jpg',
                        width: 34,
                        height: 34,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 8),
                      Padding(
      padding: const EdgeInsets.only(top: 3), // <-- ขยับลง
      child: Text(
        '47Market',
        style: GoogleFonts.chakraPetch(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
          letterSpacing: 1.5,
            decoration: TextDecoration.lineThrough, // <-- ขีดฆ่า
    decorationThickness: 1,        
        ),
      ),
    ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Main headline text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Everything you need',
                  style: GoogleFonts.chakraPetch(
                    fontSize: 28,
                    fontWeight: FontWeight.normal,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'right to your door',
                  style: GoogleFonts.chakraPetch(
                    fontSize: 28,
                    fontWeight: FontWeight.normal,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Make the right purchases and order right home',
                  style: GoogleFonts.chakraPetch(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: GoogleFonts.chakraPetch(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: GoogleFonts.chakraPetch(
          color: theme.colorScheme.onSurface,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Default categories if none loaded
    final defaultCategories = [
      {'emoji': '🍎', 'label': 'Fruits', 'type': BrandType.all},
      {'emoji': '🥦', 'label': 'vegetables', 'type': BrandType.all},
      {'emoji': '🧀', 'label': 'Diary', 'type': BrandType.all},
      {'emoji': '🥩', 'label': 'Meat', 'type': BrandType.all},
    ];

    final displayCategories = categories.isNotEmpty
        ? categories.take(4).map((cat) {
            final splitIndex = cat.displayName.indexOf(' ');
            final emoji = splitIndex > 0
                ? cat.displayName.substring(0, splitIndex)
                : '📦';
            final label = splitIndex > 0
                ? cat.displayName.substring(splitIndex + 1)
                : cat.displayName;
            return {'emoji': emoji, 'label': label, 'type': cat.type};
          }).toList()
        : defaultCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Categories',
                  style: GoogleFonts.chakraPetch(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('😉', style: TextStyle(fontSize: 20)),
              ],
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'See all',
                style: GoogleFonts.chakraPetch(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: displayCategories.map((category) {
            final categoryType = category['type'] as BrandType;
            final isSelected = selectedCategory == categoryType;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  _filterProductsByCategory(categoryType);
                },
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : (isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade100),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          category['emoji'] as String,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['label'] as String,
                      style: GoogleFonts.chakraPetch(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildForYouSection(BuildContext context) {
    if (selectedItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            "No products to show",
            style: GoogleFonts.chakraPetch(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
      );
    }

    final itemsSnapshot = List<ShirtModel>.from(selectedItems);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.colorScheme.surface;
    final shadowColor =
        isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.06);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'For You',
              style: GoogleFonts.chakraPetch(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'See All',
                style: GoogleFonts.chakraPetch(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MasonryGridView.count(
          itemCount: itemsSnapshot.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          itemBuilder: (context, index) {
            final product = itemsSnapshot[index];
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: [180.0, 210.0, 240.0][index % 3],
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.grey,
                        image: DecorationImage(
                          image: (product.networkImage ?? false)
                              ? NetworkImage(product.thumbnail ?? product.image)
                              : AssetImage(product.image) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.chakraPetch(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${product.price.toStringAsFixed(2)}',
                                    style: GoogleFonts.chakraPetch(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "per pack",
                                    style: GoogleFonts.chakraPetch(
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
                                  ShadToaster.of(context).show(const ShadToast(
                                    title: Text("เพิ่มสินค้า ใส่ตะกร้าเรียบร้อยแล้ว"),
                                    duration: Duration(milliseconds: 1000),
                                  ));
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
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
