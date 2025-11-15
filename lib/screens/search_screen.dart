import 'package:brand_store_app/models/shirt_model.dart';
import 'package:brand_store_app/providers/cart_provider.dart';
import 'package:brand_store_app/resources/app_data.dart';
import 'package:brand_store_app/widgets/items_gridview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  List<ShirtModel> allItems = [];
  List<ShirtModel> selectedItems = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await AppData.loadAllData();
      setState(() {
        allItems = AppData.products;
        selectedItems = allItems;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterItems(String query) {
    // กรองตามคำค้นหาเท่านั้น
    if (query.isEmpty) {
      setState(() {
        selectedItems = allItems;
      });
    } else {
      setState(() {
        selectedItems = allItems
            .where(
                (item) => item.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
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
        body: isLoading
            ? const Center(
                child: SpinKitDancingSquare(
                  color: Colors.red,
                  size: 50.0,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Search",
                              style: GoogleFonts.chakraPetch(
                                  fontWeight: FontWeight.w500,
                                  fontSize: MediaQuery.textScalerOf(context)
                                      .scale(40)),
                            ),
                            Text(
                              "Your Neighborhood, Your Market..",
                              style: GoogleFonts.chakraPetch(
                                fontWeight: FontWeight.w300,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inverseSurface
                                    .withOpacity(0.7),
                                fontSize:
                                    MediaQuery.textScalerOf(context).scale(15),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            // Search Bar
                            TextField(
                              controller: _searchController,
                              onChanged: (query) => _filterItems(query),
                              decoration: InputDecoration(
                                hintText: "ค้นหาสินค้า...",
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(context).colorScheme.surface,
                              ),
                            ),
                            // const Spacer()
                          ],
                        ),
                      )),
                  Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0, left: 20.0),
                        child: selectedItems.isEmpty
                            ? Center(
                                child: Text(
                                  "ไม่พบสินค้าที่ค้นหา",
                                  style: GoogleFonts.chakraPetch(
                                    fontSize: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inverseSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                              )
                            : ItemsGridview(
                                selectedItems: selectedItems,
                                tagPrefix: "search"),
                      )),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
