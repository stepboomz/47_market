import 'package:brand_store_app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Cart extends ConsumerStatefulWidget {
  const Cart({super.key});

  @override
  ConsumerState<Cart> createState() => _CartState();
}

class _CartState extends ConsumerState<Cart> {

  Widget _buildListItem(BuildContext context, CartItem selectedCartItem,
      int index, Animation<double>? animation) {
    final selectedShirt = selectedCartItem.shirt;
    
    Widget content = Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      // decoration: BoxDecoration(
      //   color: Theme.of(context).colorScheme.surface,
      //   borderRadius: BorderRadius.circular(16),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.05),
      //       blurRadius: 10,
      //       offset: const Offset(0, 2),
      //     ),
      //   ],
      // ),
      child: Slidable(
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
                    ref.read(cartProvider.notifier).removeItem(selectedShirt, selectedVariant: selectedCartItem.selectedVariant);
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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // รูปสินค้า
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: (selectedShirt.networkImage == null ||
                        selectedShirt.networkImage! == false)
                    ? Image.asset(
                        selectedShirt.image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        selectedShirt.image.replaceAll('/1.png', '/thumbnail.png'),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(width: 16),
              
              // ข้อมูลสินค้า
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ชื่อสินค้า
                    Text(
                      selectedShirt.name,
                      style: GoogleFonts.imprima(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Variant
                    if (selectedCartItem.selectedVariant != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          selectedCartItem.selectedVariant!.name,
                          style: GoogleFonts.imprima(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    // ราคา
                    Text(
                      '฿${(selectedCartItem.selectedVariant?.price ?? selectedShirt.price).toStringAsFixed(0)}',
                      style: GoogleFonts.imprima(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              
              // ปุ่มควบคุมจำนวน
              Column(
                children: [
                  // ปุ่มเพิ่ม
                  GestureDetector(
                    onTap: () {
                      ref.read(cartProvider.notifier).addItem(selectedShirt, selectedVariant: selectedCartItem.selectedVariant);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // จำนวน
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${selectedCartItem.quantity}",
                      style: GoogleFonts.imprima(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // ปุ่มลด
                  GestureDetector(
                    onTap: () {
                      ref.read(cartProvider.notifier).decrementItem(selectedShirt, selectedVariant: selectedCartItem.selectedVariant);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.remove,
                        size: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
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
                            color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "No items in cart",
                            style: GoogleFonts.imprima(
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.7),
                            ),
                          ),
                          // const SizedBox(height: 10),
                          // Text(
                          //   "เพิ่มสินค้าเพื่อเริ่มช้อปปิ้ง",
                          //   style: GoogleFonts.imprima(
                          //     fontSize: 14,
                          //     color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.5),
                          //   ),
                          // ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final selectedCartItem = cartItems[index];
                        return _buildListItem(
                            context, selectedCartItem, index, null);
                      },
                    ),
            ),
            
            // สรุปราคา
            if (cartItems.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.all(20),
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