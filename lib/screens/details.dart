import 'package:brand_store_app/models/shirt_model.dart';
import 'package:brand_store_app/models/product_variant.dart';
import 'package:brand_store_app/providers/cart_provider.dart';
import 'package:brand_store_app/providers/favorite_provider.dart';
import 'package:brand_store_app/widgets/animated_price.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shimmer/shimmer.dart';

class Details extends ConsumerStatefulWidget {
  const Details({super.key, required this.shirt, required this.tagPrefix});

  final ShirtModel shirt;
  final String tagPrefix;

  @override
  ConsumerState<Details> createState() => _DetailsState();
}

class _DetailsState extends ConsumerState<Details> {
  ProductVariant? selectedVariant;

  @override
  void initState() {
    super.initState();
    // ถ้ามี variants ให้เลือกตัวแรกเป็น default
    if (widget.shirt.variants.isNotEmpty) {
      selectedVariant = widget.shirt.variants.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          foregroundColor: Theme.of(context).colorScheme.inverseSurface,
          elevation: 0,
          forceMaterialTransparency: true,
          toolbarHeight: 100,
          leadingWidth: 100,
          primary: true,
          centerTitle: true,
          title: Text("Details", style: GoogleFonts.imprima(fontSize: 25)),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const ImageIcon(
              size: 30,
              AssetImage("assets/icons/back_arrow.png"),
            ),
          ),
          actions: [
            Consumer(
              builder: (context, ref, child) {
                final favorites = ref.watch(favoriteProvider);
                final isFavorite = favorites.any((item) => item.id == widget.shirt.id);
                return IconButton(
                  padding: const EdgeInsets.only(right: 30),
                  onPressed: () {
                    ref.read(favoriteProvider.notifier).toggleFavorite(widget.shirt);
                    ShadToaster.of(context).show(ShadToast(
                      title: Text(isFavorite ? "ลบออกจากรายการโปรด" : "เพิ่มในรายการโปรด"),
                      duration: const Duration(milliseconds: 1000),
                    ));
                  },
                  icon: ImageIcon(
                    size: 30,
                    AssetImage("assets/icons/save.png"),
                    color: isFavorite ? Colors.red : null,
                  ),
                );
              },
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: Hero(
                  tag: widget.tagPrefix + (selectedVariant?.image ?? widget.shirt.image),
                  child: (widget.shirt.networkImage == null ||
                          widget.shirt.networkImage! == false)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            selectedVariant?.image ?? widget.shirt.image,
                            fit: BoxFit.cover,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                color: Theme.of(context).canvasColor,
                              ),
                              Center(
                                child: Image.network(
                                  (selectedVariant?.image ?? widget.shirt.image)
                                      .replaceAll('/1.png', '/thumbnail.png'),
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return Shimmer.fromColors(
                                      baseColor: Theme.of(context)
                                          .colorScheme
                                          .surfaceDim,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
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
              ),
              Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Hero(
                                tag: widget.tagPrefix + (selectedVariant?.name ?? widget.shirt.name),
                                child: Text(
                                  selectedVariant?.name ?? widget.shirt.name,
                                  softWrap: true,
                                  style: GoogleFonts.imprima(
                                    fontSize: 30,
                                    height: 1.2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      
                      // แสดงตัวเลือก variants ถ้ามี
                      if (widget.shirt.variants.isNotEmpty) ...[
                        // Text(
                        //   "ตัวเลือก",
                        //   style: GoogleFonts.imprima(
                        //     fontSize: 20,
                        //     // fontWeight: FontWeight.bold,
                        //     letterSpacing: 1.0
                        //   ),
                        // ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.shirt.variants.length,
                            itemBuilder: (context, index) {
                              final variant = widget.shirt.variants[index];
                              final isSelected = selectedVariant?.id == variant.id;
                              
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedVariant = variant;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.orange : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: isSelected ? Colors.orange : Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    variant.name,
                                    style: GoogleFonts.imprima(
                                      color: isSelected ? Colors.white : Colors.black,
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                      
                      
                      // แสดงรายละเอียดสินค้า
                      if ((selectedVariant?.description ?? widget.shirt.description).isNotEmpty) ...[
                        Text(
                          "- รายละเอียด",
                          style: GoogleFonts.imprima(
                            fontSize: 17,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              selectedVariant?.description ?? widget.shirt.description,
                              style: GoogleFonts.imprima(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.7),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                      
                      // const Spacer(),
                      Row(
                        children: [
                          Hero(
                            tag: widget.tagPrefix +
                                (selectedVariant?.price ?? widget.shirt.price).toString(),
                            child: AnimatedPrice(
                                priceString: (selectedVariant?.price ?? widget.shirt.price).toString()),
                          ),
                          const Spacer(),
                          FilledButton(
                            onPressed: () async {
                              ref
                                  .read(cartProvider.notifier)
                                  .addItem(widget.shirt, selectedVariant: selectedVariant);
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: Center(
                                      child: ShadDialog(
                                        title: Text('Adding to Cart'),
                                        child: ShadProgress(),
                                      ),
                                    ),
                                  );
                                },
                              );
                              await Future.delayed(const Duration(seconds: 1));
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              ShadToaster.of(context).show(const ShadToast(
                                title:
                                    Text("เพิ่มสินค้า ใส่ตะกร้าเรียบร้อยแล้ว"),
                                duration: Duration(milliseconds: 1000),
                              ));
                              Navigator.pop(context);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              "Add To Cart",
                              style: GoogleFonts.imprima(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  ))
            ],
          ),
        ));
  }
}