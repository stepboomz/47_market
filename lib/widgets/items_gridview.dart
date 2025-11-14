import 'package:brand_store_app/models/shirt_model.dart';
import 'package:brand_store_app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class ItemsGridview extends ConsumerWidget {
  const ItemsGridview(
      {super.key, required this.selectedItems, required this.tagPrefix});

  final List<ShirtModel> selectedItems;
  final String tagPrefix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
      ),
      child: MasonryGridView.builder(
        itemCount: selectedItems.length,
        crossAxisSpacing: 25,
        mainAxisSpacing: 10,
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 3 : 2),
        itemBuilder: (context, index) {
          final selectedShirt = selectedItems[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/details',
                arguments: {
                  'shirt': selectedShirt,
                  'prefix': tagPrefix,
                },
              );
            },
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Hero(
                tag: tagPrefix + selectedShirt.image,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    (selectedShirt.networkImage == null ||
                            selectedShirt.networkImage! == false)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.asset(selectedShirt.image),
                          )
                        : Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Container(
                                      height: 200,
                                      // Replace with your actual height
                                      width: double.infinity,
                                      color: Theme.of(context).canvasColor,
                                    ),
                                  ),
                                  Center(
                                    child: Image.network(
                                      selectedShirt.image.replaceAll(
                                          '/1.png', '/thumbnail.png'),
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child; // Image fully loaded
                                        }
                                        return Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            height: 200,
                                            // Replace with your actual height
                                            width: double.infinity,
                                            color: Colors.grey[300],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    Positioned(
                      right: 15,
                      bottom: -25,
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          backgroundColor: Colors.black,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/details',
                                arguments: {
                                  'shirt': selectedShirt,
                                  'prefix': tagPrefix,
                                },
                              );
                            },
                            icon: const ImageIcon(
                              AssetImage("assets/icons/bag.png"),
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Hero(
                tag: tagPrefix + selectedShirt.price.toString(),
                child: Text(
                  "฿${selectedShirt.price.toStringAsFixed(0)}",
                  style: GoogleFonts.chakraPetch(
                      fontSize: MediaQuery.textScalerOf(context).scale(20),
                      fontWeight: FontWeight.bold),
                ),
              ),
              Hero(
                tag: tagPrefix + selectedShirt.name,
                child: Text(
                  selectedShirt.name,
                  style: GoogleFonts.chakraPetch(
                    fontSize: MediaQuery.textScalerOf(context).scale(14),
                    color: Theme.of(context).colorScheme.inverseSurface,
                  ),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}
