import 'package:brand_store_app/models/category_model.dart';
import 'package:brand_store_app/models/shirt_model.dart';
import 'package:brand_store_app/providers/cart_provider.dart';
import 'package:brand_store_app/resources/app_data.dart';
import 'package:brand_store_app/widgets/items_gridview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.inverseSurface,
        elevation: 0,
        forceMaterialTransparency: true,
        toolbarHeight: 100,
        leadingWidth: 100,
        primary: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
          icon: const ImageIcon(
            size: 30,
            AssetImage("assets/icons/menu.png"),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/cart");
            },
            icon: _buildCartIconWithBadge(),
          )
        ],
      ),
      bottomNavigationBar: null,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "47 Market",
                            style: GoogleFonts.imprima(
                                fontWeight: FontWeight.w500,
                                fontSize: MediaQuery.textScalerOf(context).scale(40)),
                          ),
                          Text(
                            "Your Neighborhood, Your Market..",
                            style: GoogleFonts.imprima(
                              fontWeight: FontWeight.w300,
                              color: Theme.of(context)
                                  .colorScheme
                                  .inverseSurface
                                  .withOpacity(0.7),
                              fontSize: MediaQuery.textScalerOf(context).scale(15),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            height: 30,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: AppData.categories.length,
                              itemBuilder: (context, index) {
                                final category = AppData.categories[index];
                                final isSelected = category.type == selectedCategory;
                                
                                return Container(
                                  width: 120,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: isSelected
                                          ? Colors.orange
                                          : Colors.transparent),
                                  margin: const EdgeInsets.only(right: 20),
                                  child: GestureDetector(
                                    onTap: () {
                                      _filterProductsByCategory(category.type);
                                    },
                                    child: Center(
                                      child: Text(
                                        category.displayName,
                                        style: GoogleFonts.imprima(
                                          color: isSelected
                                              ? Colors.white
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .inverseSurface,
                                          fontSize: MediaQuery.textScalerOf(context)
                                              .scale(15),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const Spacer()
                        ],
                      ),
                    )),
                Expanded(
                    flex: 10,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0,left: 20.0),
                      child: ItemsGridview(
                        selectedItems: selectedItems,
                        tagPrefix: "home",
                      ),
                    ))
              ],
            ),
      ),
    );
  }
}