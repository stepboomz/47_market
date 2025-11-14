import 'package:brand_store_app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';

class Cart extends ConsumerStatefulWidget {
  const Cart({super.key});

  @override
  ConsumerState<Cart> createState() => _CartState();
}

class _CartState extends ConsumerState<Cart> {

  Widget _buildListItem(BuildContext context, CartItem selectedCartItem,
      int index, Animation<double>? animation) {
    final selectedShirt = selectedCartItem.shirt;
    final variantPrice =
        selectedCartItem.selectedVariant?.price ?? selectedShirt.price;
    final hasDiscount = variantPrice != selectedShirt.price;
    Widget content = Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.2,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () {
                  ref.read(cartProvider.notifier).removeItem(selectedShirt,
                      selectedVariant: selectedCartItem.selectedVariant);
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: (selectedShirt.networkImage == null ||
                        selectedShirt.networkImage! == false)
                    ? Image.asset(
                        selectedShirt.image,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        selectedShirt.image
                            .replaceAll('/1.png', '/thumbnail.png'),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedShirt.name,
                    style: GoogleFonts.imprima(
                      fontSize: 16,
                      // fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (selectedCartItem.selectedVariant != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      selectedCartItem.selectedVariant!.name,
                      style: GoogleFonts.imprima(
                        fontSize: 13,
                        color:
                            Theme.of(context).colorScheme.inverseSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '฿${variantPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.imprima(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.inverseSurface,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          '฿${selectedShirt.price.toStringAsFixed(2)}',
                          style: GoogleFonts.imprima(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .inverseSurface
                                .withOpacity(0.5),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildQuantityButton(
                    icon: Icons.remove,
                    onTap: () {
                      ref.read(cartProvider.notifier).decrementItem(selectedShirt,
                          selectedVariant: selectedCartItem.selectedVariant);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "${selectedCartItem.quantity}",
                      style: GoogleFonts.imprima(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildQuantityButton(
                    icon: Icons.add,
                    onTap: () {
                      ref.read(cartProvider.notifier).addItem(selectedShirt,
                          selectedVariant: selectedCartItem.selectedVariant);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (animation != null) {
      return SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOut)),
        ),
        child: FadeTransition(
          opacity: animation,
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildQuantityButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
      ),
      child: Scaffold(
        // backgroundColor: const Color(0xFFF8F8F8),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          foregroundColor: Theme.of(context).colorScheme.inverseSurface,
          elevation: 0,
          forceMaterialTransparency: true,
          toolbarHeight: 100,
          leadingWidth: 100,
          primary: true,
          centerTitle: true,
          title: Text(
            "Cart",
            style: GoogleFonts.imprima(fontSize: 25),
          ),
          // leading: IconButton(
          //   onPressed: () {
          //     Navigator.pop(context);
          //   },
          //   icon: const ImageIcon(
          //     size: 30,
          //     AssetImage("assets/icons/back_arrow.png"),
          //   ),
          // ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         "Cart Items",
            //         style: GoogleFonts.imprima(
            //           fontSize: 24,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //       const SizedBox(height: 8),
            //       Text(
            //         "${cartItems.length} items",
            //         style: GoogleFonts.imprima(
            //           fontSize: 14,
            //           color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.7),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 20),
            
            // รายการสินค้า
            Expanded(
              child: cartItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 80,
                            color: Theme.of(context)
                                .colorScheme
                                .inverseSurface
                                .withOpacity(0.3),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "No items in cart",
                            style: GoogleFonts.imprima(
                              fontSize: 20,
                              color: Theme.of(context)
                                  .colorScheme
                                  .inverseSurface
                                  .withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: cartItems.length,
                      separatorBuilder: (_, __) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Divider(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      itemBuilder: (context, index) {
                        final selectedCartItem = cartItems[index];
                        return _buildListItem(
                            context, selectedCartItem, index, null);
                      },
                    ),
            ),
            if (cartItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: Colors.teal,
                    textStyle: GoogleFonts.imprima(fontSize: 15),
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.local_offer_outlined, size: 20),
                  label: const Text("Add promo code"),
                ),
              ),
            
            // สรุปราคา
            if (cartItems.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // สรุปราคา
                    Row(
                      children: [
                        Text(
                          "Total Items (${cartItems.length})",
                          style: GoogleFonts.imprima(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.7),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '฿${(ref.watch(cartProvider.notifier).totalCost).toStringAsFixed(0)}',
                          style: GoogleFonts.imprima(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "Standard Delivery",
                          style: GoogleFonts.imprima(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.7),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "Free",
                          style: GoogleFonts.imprima(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Text(
                          "Total Payment",
                          style: GoogleFonts.imprima(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '฿${(ref.watch(cartProvider.notifier).totalCost).toStringAsFixed(0)}',
                          style: GoogleFonts.imprima(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // ปุ่มชำระเงิน
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/checkout');
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Check Out",
                          style: GoogleFonts.imprima(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}