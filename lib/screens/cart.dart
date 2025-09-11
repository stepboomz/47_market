import 'package:brand_store_app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shimmer/shimmer.dart';

class Cart extends ConsumerStatefulWidget {
  const Cart({super.key});

  @override
  ConsumerState<Cart> createState() => _CartState();
}

class _CartState extends ConsumerState<Cart> {

  Widget _buildListItem(BuildContext context, CartItem selectedCartItem,
      int index, Animation<double>? animation) {
    final selectedShirt = selectedCartItem.shirt;
    
    Widget content = Slidable(
        child: Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.25,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          bottomLeft: Radius.circular(25),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Spacer(),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.favorite_border_outlined,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              ref.read(cartProvider.notifier).removeItem(selectedShirt, selectedVariant: selectedCartItem.selectedVariant);
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal:40, vertical: 10),
            child: Row(
              children: [
                (selectedShirt.networkImage == null ||
                        selectedShirt.networkImage! == false)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.asset(
                          selectedShirt.image,
                          width: 150,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Stack(
                          children: [
                            Container(
                              width: 150,
                              height: 180,
                              color: Theme.of(context).canvasColor,
                            ),
                            Image.network(
                              selectedShirt.image
                                  .replaceAll('/1.png', '/thumbnail.png'),
                              width: 150,
                              height: 180,
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
                                    width: 150,
                                    height: 180,
                                    color: Colors.grey[300],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                const SizedBox(width: 20),
                Expanded(
                  child: SizedBox(
                    height: 180,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       Row(children: [
                         Expanded(
                           child: Text(
                            selectedShirt.name,
                            style: GoogleFonts.imprima(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                         ),
                       ],),
                        const SizedBox(height: 8),
                        // แสดง variant ที่เลือก
                        if (selectedCartItem.selectedVariant != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            // decoration: BoxDecoration(
                            //   border: Border.all(
                            //     color: Colors.orange.withOpacity(0.5),
                            //     width: 1,
                            //   ),
                            //   borderRadius: BorderRadius.circular(12),
                            //   color: Colors.orange.withOpacity(0.1),
                            // ),
                            child: Text(
                              selectedCartItem.selectedVariant!.name,
                              style: GoogleFonts.imprima(
                                fontSize: 16,
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                              softWrap: false,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        // แสดง colors และ sizes ถ้าไม่มี variant
                     
                        const Spacer(),
                        Text(
                          '฿${(selectedCartItem.selectedVariant?.price ?? selectedShirt.price).toStringAsFixed(0)}',
                          style: GoogleFonts.imprima(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
               
               
                SizedBox(
                  height: 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              ref.read(cartProvider.notifier).decrementItem(selectedShirt, selectedVariant: selectedCartItem.selectedVariant);
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.remove,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "${selectedCartItem.quantity}",
                            style: GoogleFonts.imprima(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              ref.read(cartProvider.notifier).addItem(selectedShirt, selectedVariant: selectedCartItem.selectedVariant);
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    
    
    // ถ้ามี animation ให้ wrap ด้วย SlideTransition และ FadeTransition
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
    
    // ถ้าไม่มี animation ให้ return content ตรงๆ
    return content;
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
      ),
      child: Scaffold(
      appBar: AppBar(
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
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const ImageIcon(
            size: 30,
            AssetImage("assets/icons/back_arrow.png"),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "My Orders",
              style: GoogleFonts.imprima(
                fontSize: MediaQuery.textScalerOf(context).scale(30),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: cartItems.isEmpty
                ? Center(
                    child: Text(
                    "No items in cart",
                    style: GoogleFonts.imprima(
                      fontSize: 30,
                      color: Theme.of(context)
                          .colorScheme
                          .inverseSurface
                          .withOpacity(0.7),
                    ),
                  ))
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final selectedCartItem = cartItems[index];
                      return _buildListItem(
                          context, selectedCartItem, index, null);
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const Divider(),
                Row(
                  children: [
                    Text(
                      "Total Items (${cartItems.length})",
                      style: GoogleFonts.imprima(
                        color: Theme.of(context)
                            .colorScheme
                            .inverseSurface
                            .withOpacity(0.7),
                        fontSize: MediaQuery.textScalerOf(context).scale(15),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '฿${(ref.watch(cartProvider.notifier).totalCost).toStringAsFixed(0)}',
                      style: GoogleFonts.imprima(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      "Standard Delivery",
                      style: GoogleFonts.imprima(
                        color: Theme.of(context)
                            .colorScheme
                            .inverseSurface
                            .withOpacity(0.7),
                        fontSize: MediaQuery.textScalerOf(context).scale(15),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Free',
                      style: GoogleFonts.imprima(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      "Total Payment",
                      style: GoogleFonts.imprima(
                        color: Theme.of(context)
                            .colorScheme
                            .inverseSurface
                            .withOpacity(0.7),
                        fontSize: MediaQuery.textScalerOf(context).scale(15),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '฿${(ref.watch(cartProvider.notifier).totalCost + 0).toStringAsFixed(0)}',
                      style: GoogleFonts.imprima(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: FilledButton(
                    onPressed: () {
                      if (cartItems.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => ShadDialog(
                            child: Column(
                              children: [
                                Text(
                                  "No items in cart",
                                  style: GoogleFonts.imprima(fontSize: 20),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Close",
                                    style: GoogleFonts.imprima(fontSize: 20),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                        return;
                      }
                      Navigator.pushNamed(context, '/checkout');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "Check Out",
                      style: GoogleFonts.imprima(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          )
        ],
      ),
      ),
    );
  }
}
