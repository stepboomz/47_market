import 'package:brand_store_app/providers/cart_provider.dart';
import 'package:brand_store_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class Cart extends ConsumerStatefulWidget {
  const Cart({super.key});

  @override
  ConsumerState<Cart> createState() => _CartState();
}

class _CartState extends ConsumerState<Cart> {
  bool _isCheckingProfile = false;

  Widget _buildCartItem(CartItem cartItem) {
    final selectedShirt = cartItem.shirt;
    final variantPrice = cartItem.selectedVariant?.price ?? selectedShirt.price;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // รูปสินค้า
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: (selectedShirt.networkImage == null ||
                      selectedShirt.networkImage! == false)
                  ? Image.asset(selectedShirt.image, fit: BoxFit.cover)
                  : Image.network(
                      selectedShirt.image
                          .replaceAll('/1.png', '/thumbnail.png'),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // ข้อมูลสินค้า
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedShirt.name,
                  style: GoogleFonts.chakraPetch(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (cartItem.selectedVariant != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    cartItem.selectedVariant!.name,
                    style: GoogleFonts.chakraPetch(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '฿${variantPrice.toStringAsFixed(0)}',
                  style: GoogleFonts.chakraPetch(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // ปุ่มควบคุมจำนวน
          Column(
            children: [
              Row(
                children: [
                  _buildCircleButton(
                    icon: Icons.remove,
                    onTap: () {
                      ref.read(cartProvider.notifier).decrementItem(
                            selectedShirt,
                            selectedVariant: cartItem.selectedVariant,
                          );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${cartItem.quantity}',
                      style: GoogleFonts.chakraPetch(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  _buildCircleButton(
                    icon: Icons.add,
                    onTap: () {
                      ref.read(cartProvider.notifier).addItem(
                            selectedShirt,
                            selectedVariant: cartItem.selectedVariant,
                          );
                    },
                    color: Colors.red.shade400,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  ref.read(cartProvider.notifier).removeItem(
                        selectedShirt,
                        selectedVariant: cartItem.selectedVariant,
                      );
                },
                icon: Icon(Icons.delete_outline,
                    size: 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.5)),
                label: Text(
                  'Delete',
                  style: GoogleFonts.chakraPetch(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: color ?? theme.colorScheme.onSurface.withOpacity(0.3),
              width: 1.5),
        ),
        child: Icon(
          icon,
          size: 18,
          color: color ?? theme.colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
    );
  }

  Future<bool> _checkProfileComplete() async {
    if (!AuthService().isLoggedIn) {
      return false;
    }

    try {
      final profile = await AuthService().getCurrentUserProfile();
      if (profile == null) {
        return false;
      }

      final name = profile['full_name'] as String?;
      final phone = profile['phone'] as String?;
      final address = profile['address'] as String?;

      return (name != null && name.trim().isNotEmpty) &&
          (phone != null && phone.trim().isNotEmpty) &&
          (address != null && address.trim().isNotEmpty);
    } catch (e) {
      print('Error checking profile: $e');
      return false;
    }
  }

  void _showProfileIncompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        return AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          title: Text(
            'Profile Incomplete',
            style: GoogleFonts.chakraPetch(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Please complete your profile information (Name, Phone Number, and Address) before proceeding to checkout.',
            style: GoogleFonts.chakraPetch(
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.chakraPetch(
                  fontSize: 16,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/edit-profile');
              },
              child: Text(
                'Go to Edit Profile',
                style: GoogleFonts.chakraPetch(
                  fontSize: 16,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleProceedToPay() async {
    setState(() {
      _isCheckingProfile = true;
    });

    try {
      // Check if user is logged in first
      if (!AuthService().isLoggedIn) {
        if (!mounted) return;
        setState(() {
          _isCheckingProfile = false;
        });
        // Navigate to onboarding page
        Navigator.pushNamed(context, '/onboarding');
        return;
      }

      // If logged in, check profile completeness
      final isComplete = await _checkProfileComplete();
      if (!mounted) return;
      
      setState(() {
        _isCheckingProfile = false;
      });

      if (isComplete) {
        Navigator.pushNamed(context, '/checkout');
      } else {
        _showProfileIncompleteDialog();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCheckingProfile = false;
      });
      print('Error checking profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final totalCost = ref.watch(cartProvider.notifier).totalCost;
    final shippingCharge = 0.0;
    final subtotal = totalCost + shippingCharge;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor =
        isDark ? theme.colorScheme.background : const Color(0xFFF5F5F5);

    return Scaffold(
      // backgroundColor: bgColor,
      body: SafeArea(
        child: cartItems.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "No items in cart",
                      style: GoogleFonts.chakraPetch(
                        fontSize: 20,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${cartItems.length} Items',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            // Navigate to add more items
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add More'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red.shade400,
                            textStyle: GoogleFonts.chakraPetch(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // รายการสินค้า
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        return _buildCartItem(cartItems[index]);
                      },
                    ),
                  ),

                  // Apply Promo Code
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.red.shade900.withOpacity(0.3)
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.local_offer_outlined,
                            color: Colors.red.shade400,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Apply Promo Code',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right,
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.3)),
                      ],
                    ),
                  ),

                  // Bill Details
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bill Details',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildBillRow('Subtotal',
                            '฿${totalCost.toStringAsFixed(0)}', theme),
                        const SizedBox(height: 8),
                        _buildBillRow('Shipping Charges', 'Free', theme),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Divider(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.1),
                              height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal',
                              style: GoogleFonts.chakraPetch(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '฿${subtotal.toStringAsFixed(0)}',
                              style: GoogleFonts.chakraPetch(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Proceed To Pay Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isCheckingProfile ? null : _handleProceedToPay,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                              disabledBackgroundColor: Colors.red.shade300,
                            ),
                            child: _isCheckingProfile
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Proceed To Pay · ฿${subtotal.toStringAsFixed(0)}',
                                    style: GoogleFonts.chakraPetch(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBillRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.chakraPetch(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.chakraPetch(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
