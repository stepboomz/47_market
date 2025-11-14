import 'package:brand_store_app/models/shirt_model.dart';
import 'package:brand_store_app/models/product_variant.dart';
import 'package:brand_store_app/providers/cart_provider.dart';
import 'package:brand_store_app/providers/favorite_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Details extends ConsumerStatefulWidget {
  const Details({super.key, required this.shirt, required this.tagPrefix});

  final ShirtModel shirt;
  final String tagPrefix;

  @override
  ConsumerState<Details> createState() => _DetailsState();
}

class _DetailsState extends ConsumerState<Details> {
  ProductVariant? selectedVariant;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    // ถ้าม�?variants ให้เลือกตัวแรกเป็�?default
    if (widget.shirt.variants.isNotEmpty) {
      selectedVariant = widget.shirt.variants.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoriteProvider);
    final isFavorite = favorites.any((item) => item.id == widget.shirt.id);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = theme.colorScheme.surface;
    final cardShadow = isDark
        ? Colors.black.withOpacity(0.45)
        : Colors.black.withOpacity(0.08);
    final accentBubble = isDark
        ? theme.colorScheme.primary.withOpacity(0.15)
        : const Color(0xFFFFF1C9);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildCircleIcon(
                    context,
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  _buildCircleIcon(
                    context,
                    assetIcon: 'assets/icons/save.png',
                    color: isFavorite ? Colors.red.shade400 : null,
                    onTap: () {
                      ref
                          .read(favoriteProvider.notifier)
                          .toggleFavorite(widget.shirt);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorite
                                ? "ลบออกจากรายการโปรด"
                                : "เพิ่มในรายการโปรด",
                            style: GoogleFonts.chakraPetch(),
                          ),
                          duration: const Duration(milliseconds: 800),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 260,
                // decoration: BoxDecoration(
                //   color: accentBubble,
                //   borderRadius: BorderRadius.circular(32),
                // ),
                child: Center(
                  child: Hero(
                    tag: widget.tagPrefix +
                        (selectedVariant?.image ?? widget.shirt.image),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: (widget.shirt.networkImage ?? false)
                          ? Image.network(
                              (selectedVariant?.image ?? widget.shirt.image)
                                  .replaceAll('/1.png', '/thumbnail.png'),
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              selectedVariant?.image ?? widget.shirt.image,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                selectedVariant?.name ?? widget.shirt.name,
                style: GoogleFonts.chakraPetch(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.shirt.description.isNotEmpty
                    ? widget.shirt.description.split('\n').first
                    : "Each (500g - 700g)",
                style: GoogleFonts.chakraPetch(
                  fontSize: 15,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                (selectedVariant?.description ?? widget.shirt.description)
                        .isNotEmpty
                    ? selectedVariant?.description ?? widget.shirt.description
                    : "The orange is the fruit of various citrus species in the family Rutaceae. Sweet oranges are a natural mutation.",
                style: GoogleFonts.chakraPetch(
                  fontSize: 15,
                  height: 1.5,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 20),
              // Container(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              //   decoration: BoxDecoration(
              //     color: surfaceColor,
              //     borderRadius: BorderRadius.circular(18),
              //     boxShadow: [
              //       BoxShadow(
              //         color: cardShadow,
              //         blurRadius: 12,
              //         offset: const Offset(0, 6),
              //       ),
              //     ],
              //   ),
              //   child: Row(
              //     children: [
              //       Container(
              //         padding: const EdgeInsets.all(10),
              //         decoration: BoxDecoration(
              //           color: theme.colorScheme.primary.withOpacity(0.12),
              //           borderRadius: BorderRadius.circular(12),
              //         ),
              //         child: Icon(Icons.watch_later_outlined,
              //             color: theme.colorScheme.primary),
              //       ),
              //       const SizedBox(width: 12),
              //       Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text(
              //             "Delivery Time",
              //             style: GoogleFonts.chakraPetch(
              //               fontSize: 15,
              //               fontWeight: FontWeight.w600,
              //             ),
              //           ),
              //           Text(
              //             "10 - 15 Min",
              //             style: GoogleFonts.chakraPetch(
              //               fontSize: 13,
              //               color: theme.colorScheme.onSurface.withOpacity(0.6),
              //             ),
              //           ),
              //         ],
              //       ),
              //       const Spacer(),
              //       IconButton(
              //         icon: Icon(
              //           isFavorite ? Icons.favorite : Icons.favorite_border,
              //           color: isFavorite
              //               ? Colors.red
              //               : theme.colorScheme.onSurface.withOpacity(0.7),
              //         ),
              //         onPressed: () {
              //           ref
              //               .read(favoriteProvider.notifier)
              //               .toggleFavorite(widget.shirt);
              //           ShadToaster.of(context).show(ShadToast(
              //             title: Text(isFavorite
              //                 ? "ลบออกจากรายการโปรด"
              //                 : "เพิ่มในรายการโปรด"),
              //             duration: const Duration(milliseconds: 1000),
              //           ));
              //         },
              //       ),

              //     ],
              //   ),
              // ),

              if (widget.shirt.variants.isNotEmpty) ...[
                const SizedBox(height: 20),
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
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surface.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Text(
                            variant.name,
                            style: GoogleFonts.chakraPetch(
                              fontSize: 14,
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${(selectedVariant?.price ?? widget.shirt.price).toStringAsFixed(2)}",
                        style: GoogleFonts.chakraPetch(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                      Text(
                        "per pack",
                        style: GoogleFonts.chakraPetch(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _buildQuantityStepper(),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    for (int i = 0; i < quantity; i++) {
                      ref.read(cartProvider.notifier).addItem(
                            widget.shirt,
                            selectedVariant: selectedVariant,
                          );
                    }
                    ShadToaster.of(context).show(const ShadToast(
                      title: Text("เพิ่มสินค้า ใส่ตะกร้าเรียบร้อยแล้ว"),
                      duration: Duration(milliseconds: 1000),
                    ));
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Add to cart",
                    style: GoogleFonts.chakraPetch(
                      fontSize: 18,
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
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

  Widget _buildCircleIcon(BuildContext context,
      {IconData? icon,
      String? assetIcon,
      required VoidCallback onTap,
      Color? color}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.4)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: assetIcon != null
            ? ColorFiltered(
                colorFilter: ColorFilter.mode(
                  color ?? theme.colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
                child: Image.asset(assetIcon, fit: BoxFit.scaleDown),
              )
            : Icon(
                icon,
                color: color ?? theme.colorScheme.onSurface,
                size: 20,
              ),
      ),
    );
  }

  Widget _buildQuantityStepper() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _quantityButton(
            icon: Icons.remove,
            onTap: () {
              if (quantity > 1) {
                setState(() {
                  quantity--;
                });
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              quantity.toString().padLeft(2, '0'),
              style: GoogleFonts.chakraPetch(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _quantityButton(
            icon: Icons.add,
            onTap: () {
              setState(() {
                quantity++;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _quantityButton(
      {required IconData icon, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
