import 'package:brand_store_app/providers/cart_provider.dart';
import 'package:brand_store_app/screens/slip_verification.dart';
import 'package:brand_store_app/services/storage_service.dart';
import 'package:brand_store_app/services/auth_service.dart';
import 'package:brand_store_app/services/supabase_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:promptpay_qrcode_generate/promptpay_qrcode_generate.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Checkout extends ConsumerStatefulWidget {
  const Checkout({super.key});

  @override
  ConsumerState<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends ConsumerState<Checkout> {
  bool showAddressForm = false;
  bool isLoadingAddress = true;
  String selectedPaymentMethod = 'qr'; // 'qr' or 'cash'
  String? promoCodeId;
  double? discountAmount;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? savedName;
  String? savedPhone;
  String? savedAddress;

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  bool _hasLoadedPromoCode = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get promo code info from arguments (moved here because context is available)
    // Only load once to avoid multiple calls
    if (!_hasLoadedPromoCode) {
      print('Checkout didChangeDependencies: Loading promo code from arguments...');
      // Use WidgetsBinding to wait for route to be ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final route = ModalRoute.of(context);
        print('Checkout didChangeDependencies: route=$route');
        if (route != null) {
          final args = route.settings.arguments as Map<String, dynamic>?;
          print('Checkout didChangeDependencies: args=$args');
          if (args != null) {
            promoCodeId = args['promoCodeId'] as String?;
            // Handle both double and num types
            final discount = args['discountAmount'];
            print('Checkout didChangeDependencies: discount (raw)=$discount, type=${discount.runtimeType}');
            if (discount != null) {
              discountAmount = (discount is num) ? discount.toDouble() : (discount as double?);
            }
            _hasLoadedPromoCode = true;
            // Debug: print to verify
            print('Checkout received promo code: promoCodeId=$promoCodeId, discountAmount=$discountAmount');
            print('Checkout state: promoCodeId=$promoCodeId, discountAmount=$discountAmount');
            // Trigger rebuild to show discount
            if (mounted) {
              print('Checkout: Calling setState to rebuild UI...');
              setState(() {});
            }
          } else {
            print('Checkout didChangeDependencies: No arguments found in route');
          }
        } else {
          print('Checkout didChangeDependencies: Route is null');
        }
      });
    } else {
      print('Checkout didChangeDependencies: Already loaded promo code, skipping');
    }
  }

  Future<void> _loadSavedAddress() async {
    setState(() {
      isLoadingAddress = true;
    });

    // Try to load from user profile first
    if (AuthService().isLoggedIn) {
      try {
        final profile = await AuthService().getCurrentUserProfile();
        if (profile != null) {
          setState(() {
            savedName = profile['full_name'] as String?;
            savedPhone = profile['phone'] as String?;
            savedAddress = profile['address'] as String?;
            isLoadingAddress = false;
            // if we have profile info, show display mode
            if ((savedName?.isNotEmpty ?? false) ||
                (savedPhone?.isNotEmpty ?? false) ||
                (savedAddress?.isNotEmpty ?? false)) {
              showAddressForm = false;
            }
          });
          return;
        }
      } catch (e) {
        print('Error loading profile: $e');
      }
    }
    
    // Fallback to saved checkout info
    final info = await StorageService.loadCheckoutInfo();
    setState(() {
      savedName = info['name'];
      savedPhone = info['phone'];
      savedAddress = info['address'];
      isLoadingAddress = false;
      // if we already have saved info, show display mode
      if ((savedName?.isNotEmpty ?? false) ||
          (savedPhone?.isNotEmpty ?? false) ||
          (savedAddress?.isNotEmpty ?? false)) {
        showAddressForm = false;
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    if (showAddressForm) {
      // Check if form fields are filled
      return nameController.text.trim().isNotEmpty &&
          phoneController.text.trim().isNotEmpty &&
          addressController.text.trim().isNotEmpty;
    } else {
      // Check if saved data exists
      return (savedName?.trim().isNotEmpty ?? false) &&
          (savedPhone?.trim().isNotEmpty ?? false) &&
          (savedAddress?.trim().isNotEmpty ?? false);
    }
  }

  double _calculateFinalTotal(double totalCost) {
    print('_calculateFinalTotal: totalCost=$totalCost, discountAmount=$discountAmount');
    if (discountAmount != null && discountAmount! > 0) {
      final finalTotal = (totalCost - discountAmount!).clamp(0.0, double.infinity);
      print('_calculateFinalTotal: finalTotal=$finalTotal (after discount)');
      return finalTotal;
    }
    print('_calculateFinalTotal: no discount, returning totalCost=$totalCost');
    return totalCost;
  }

  Future<void> _processCashPayment(double finalTotal) async {
    final items = ref
        .read(cartProvider)
        .map((it) => {
              'product_id': it.shirt.id,
              'variant_id': it.selectedVariant?.id,
              'name': it.selectedVariant?.name ?? it.shirt.name,
              'price': (it.selectedVariant?.price ?? it.shirt.price),
              'quantity': it.quantity,
            })
        .toList();

    // Calculate original total (before discount)
    final originalTotal = ref.read(cartProvider.notifier).totalCost;

    try {
      // Create order for cash payment
      // Note: totalAmount should be original total, createOrder will apply discount
      final orderResult = await SupabaseService.createOrder(
        customerName: savedName ?? '',
        customerPhone: savedPhone ?? '',
        customerAddress: savedAddress ?? '',
        totalAmount: originalTotal,
        items: items,
        slipImageUrl: null, // No slip for cash payment
        paymentMethod: 'cash',
        promoCodeId: promoCodeId,
        discountAmount: discountAmount,
      );

      if (orderResult == null) {
        if (mounted) {
          ShadToaster.of(context).show(
            const ShadToast(
              title: Text('Error creating order. Please try again.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      final orderNumber = orderResult['orderNumber']!;

      // Update order status to "completed" for cash payment
      final orderId = orderResult['orderId']!;
      await SupabaseService.updateOrderStatus(orderId, 'completed');

      // Clear cart
      ref.read(cartProvider.notifier).clearCart();

      // Navigate to order success page
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/order-success',
          arguments: {
            'orderNumber': orderNumber,
            'totalAmount': finalTotal,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast(
            title: Text('Error: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showSlipVerificationModal(double totalAmount) {
    final items = ref
        .read(cartProvider)
        .map((it) => {
              'product_id': it.shirt.id,
              'variant_id': it.selectedVariant?.id,
              'name': it.selectedVariant?.name ?? it.shirt.name,
              'price': (it.selectedVariant?.price ?? it.shirt.price),
              'quantity': it.quantity,
            })
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SlipVerification(
        orderNumber: '', // Will be generated after verification
        totalAmount: totalAmount,
        customerName: savedName ?? '',
        customerPhone: savedPhone ?? '',
        customerAddress: savedAddress ?? '',
        orderItems: items,
        promoCodeId: promoCodeId,
        discountAmount: discountAmount,
      ),
    );
  }

  void _showQRCodeModal(double finalTotal) {
    // Save parent context before showing modal
    final parentContext = context;
    // Use finalTotal (after discount) for QR code
    final qrAmount = finalTotal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Container(
        height: MediaQuery.of(modalContext).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(modalContext).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    "Pay with PromptPay",
                    style: GoogleFonts.chakraPetch(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Scan QR Code to make payment",
                    style: GoogleFonts.chakraPetch(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // QR Code
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: QRCodeGenerate(
                    promptPayId:
                        "0957728931", // You can change this to your PromptPay ID
                    amount: qrAmount,
                    width: 250,
                    height: 250,
                  ),
                ),
              ),
            ),
            // Amount display
            // Container(
            //   margin: const EdgeInsets.symmetric(horizontal: 20),
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: Colors.orange.withOpacity(0.1),
            //     borderRadius: BorderRadius.circular(12),
            //     border: Border.all(color: Colors.orange.withOpacity(0.3)),
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Text(
            //         "Total Amount",
            //         style: GoogleFonts.chakraPetch(
            //           fontSize: 18,
            //           fontWeight: FontWeight.w500,
            //         ),
            //       ),
            //       Text(
            //         "�?{totalAmount.toStringAsFixed(0)}",
            //         style: GoogleFonts.chakraPetch(
            //           fontSize: 24,
            //           fontWeight: FontWeight.bold,
            //           color: Colors.orange,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            // Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(modalContext),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.chakraPetch(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        // Calculate original total (before discount) for order creation
                        final originalTotalForOrder = ref.read(cartProvider.notifier).totalCost;
                        final items = ref
                            .read(cartProvider)
                            .map((it) => {
                                  'product_id': it.shirt.id,
                                  'variant_id': it.selectedVariant?.id,
                                  'name':
                                      it.selectedVariant?.name ?? it.shirt.name,
                                  'price': (it.selectedVariant?.price ??
                                      it.shirt.price),
                                  'quantity': it.quantity,
                                })
                            .toList();

                        // Close QR modal and show slip verification modal
                        if (mounted) {
                          Navigator.pop(modalContext);
                          // Small delay to ensure modal is fully closed
                          await Future.delayed(
                              const Duration(milliseconds: 300));
                          if (mounted) {
                            showModalBottomSheet(
                              context: parentContext,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => SlipVerification(
                                orderNumber: '', // Will be generated after verification
                                totalAmount: originalTotalForOrder,
                                customerName: savedName ?? '',
                                customerPhone: savedPhone ?? '',
                                customerAddress: savedAddress ?? '',
                                orderItems: items,
                              ),
                            );
                          }
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Payment Complete",
                        style: GoogleFonts.chakraPetch(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
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

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.inverseSurface,
        elevation: 0,
        forceMaterialTransparency: true,
        toolbarHeight: 100,
        leadingWidth: 100,
        primary: true,
        centerTitle: true,
        title: Text("Checkout", style: GoogleFonts.chakraPetch(fontSize: 25)),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: isLoadingAddress
          ? const Center(
              child: SpinKitDancingSquare(
                color: Colors.red,
                size: 50.0,
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                    "Delivery Address",
                    style: GoogleFonts.chakraPetch(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .inverseSurface
                            .withOpacity(0.7)),
                  ),
                  if (!showAddressForm) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 120,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset("assets/images/quickmap.png"),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Siri Place Phaholyothin 52 ",
                                      softWrap: true,
                                      style: GoogleFonts.chakraPetch(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .inverseSurface,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    if (savedName != null &&
                                        savedName!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        "Name: $savedName",
                                        style: GoogleFonts.chakraPetch(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .inverseSurface
                                              .withOpacity(0.8),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    if (savedPhone != null &&
                                        savedPhone!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        "Phone: $savedPhone",
                                        style: GoogleFonts.chakraPetch(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .inverseSurface
                                              .withOpacity(0.8),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    if (savedAddress != null &&
                                        savedAddress!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        "Address: $savedAddress",
                                        style: GoogleFonts.chakraPetch(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .inverseSurface
                                              .withOpacity(0.8),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // const SizedBox(height: 16), // Add spacing before delivery time
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () async {
                      // If user is logged in, navigate to edit profile
                      if (AuthService().isLoggedIn) {
                        final result = await Navigator.pushNamed(
                          context,
                          '/edit-profile',
                        );
                        if (result == true && mounted) {
                          // Reload profile data after editing
                          await _loadSavedAddress();
                        }
                      } else {
                        // If not logged in, show form in checkout
                        nameController.text = savedName ?? '';
                        phoneController.text = savedPhone ?? '';
                        addressController.text = savedAddress ?? '';
                        setState(() {
                          showAddressForm = true;
                        });
                      }
                    },
                    child: Text("Edit",
                        style: GoogleFonts.chakraPetch(fontSize: 15)),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: "Phone",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addressController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showAddressForm = false;
                        });
                        // Clear text fields (don't delete saved data)
                        nameController.clear();
                        phoneController.clear();
                        addressController.clear();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.chakraPetch(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          showAddressForm = false;
                          savedName = nameController.text;
                          savedPhone = phoneController.text;
                          savedAddress = addressController.text;
                        });
                        await StorageService.saveCheckoutInfo(
                          name: savedName ?? '',
                          phone: savedPhone ?? '',
                          address: savedAddress ?? '',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Save",
                        style: GoogleFonts.chakraPetch(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const Icon(
                  CupertinoIcons.clock,
                  color: Colors.grey,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "Delivered in 15-20 minutes",
                  style: GoogleFonts.chakraPetch(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              "Payment Method",
              style: GoogleFonts.chakraPetch(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .inverseSurface
                      .withOpacity(0.7)),
            ),
            const SizedBox(
              height: 10,
            ),
            Builder(
              builder: (context) {
                final theme = Theme.of(context);
                final colorScheme = theme.colorScheme;
                final isDark = theme.brightness == Brightness.dark;
                
                return Row(
                  children: [
                    // PromptPay (QR Code) option
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedPaymentMethod = 'qr';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedPaymentMethod == 'qr'
                                ? (isDark
                                    ? Colors.red.shade900.withOpacity(0.3)
                                    : Colors.red.shade50)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedPaymentMethod == 'qr'
                                  ? Colors.red.shade400
                                  : (isDark
                                      ? colorScheme.onSurface.withOpacity(0.3)
                                      : Colors.grey.shade300),
                              width: selectedPaymentMethod == 'qr' ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                "assets/images/payment/promptpay.png",
                                width: 32,
                                height: 32,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  "PromptPay",
                                  style: GoogleFonts.chakraPetch(
                                    fontSize: 13,
                                    fontWeight: selectedPaymentMethod == 'qr'
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: colorScheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Cash option
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedPaymentMethod = 'cash';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedPaymentMethod == 'cash'
                                ? (isDark
                                    ? Colors.red.shade900.withOpacity(0.3)
                                    : Colors.red.shade50)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedPaymentMethod == 'cash'
                                  ? Colors.red.shade400
                                  : (isDark
                                      ? colorScheme.onSurface.withOpacity(0.3)
                                      : Colors.grey.shade300),
                              width: selectedPaymentMethod == 'cash' ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                "assets/icons/cash.png",
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  "Cash",
                                  style: GoogleFonts.chakraPetch(
                                    fontSize: 13,
                                    fontWeight: selectedPaymentMethod == 'cash'
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: colorScheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(
              height: 30,
            ),
            // Center(
            //   child: Text(
            //     "Add Voucher",
            //     style: GoogleFonts.chakraPetch(
            //       fontSize: 15,
            //       color: Theme.of(context)
            //           .colorScheme
            //           .inverseSurface
            //           .withOpacity(0.7),
            //     ),
            //   ),
            // ),
            // const SizedBox(
            //   height: 20,
            // ),
            Text.rich(
              TextSpan(
                text: "Note : ",
                style: GoogleFonts.chakraPetch(
                  fontSize: 15,
                  color: Colors.red,
                  fontWeight: FontWeight.w300,
                ),
                children: [
                  TextSpan(
                    text:
                        "Don’t forget to verify your name and address before placing your order",
                    style: GoogleFonts.chakraPetch(
                      fontSize: 15,
                      color: Theme.of(context)
                          .colorScheme
                          .inverseSurface
                          .withOpacity(0.7),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  // TextSpan(
                  //   text: "#154619",
                  //   style: GoogleFonts.chakraPetch(
                  //     fontSize: 15,
                  //     fontWeight: FontWeight.w300,
                  //   ),
                  // ),
                  // TextSpan(
                  //   text:
                  //       " if you forget to put your order id we can’t confirm the payment.",
                  //   style: GoogleFonts.chakraPetch(
                  //     fontSize: 15,
                  //     color: Theme.of(context)
                  //         .colorScheme
                  //         .inverseSurface
                  //         .withOpacity(0.7),
                  //     fontWeight: FontWeight.w300,
                  //   ),
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                const Divider(),
                Row(
                  children: [
                    Text(
                      "Total Items (${cartItems.length})",
                      style: GoogleFonts.chakraPetch(
                        color: Theme.of(context)
                            .colorScheme
                            .inverseSurface
                            .withOpacity(0.7),
                        fontSize: MediaQuery.textScalerOf(context).scale(15),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\฿${(ref.watch(cartProvider.notifier).totalCost).toStringAsFixed(0)}',
                      style: GoogleFonts.chakraPetch(
                          fontSize: 15, fontWeight: FontWeight.w500),
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
                      style: GoogleFonts.chakraPetch(
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
                      style: GoogleFonts.chakraPetch(
                          fontSize: 15, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
                Builder(
                  builder: (context) {
                    print('Checkout build: discountAmount=$discountAmount, promoCodeId=$promoCodeId');
                    if (discountAmount != null && discountAmount! > 0) {
                      print('Checkout build: Showing discount row with amount=${discountAmount!.toStringAsFixed(0)}');
                      return Column(
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                "Discount",
                                style: GoogleFonts.chakraPetch(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface
                                      .withOpacity(0.7),
                                  fontSize: MediaQuery.textScalerOf(context).scale(15),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '-฿${discountAmount!.toStringAsFixed(0)}',
                                style: GoogleFonts.chakraPetch(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green),
                              )
                            ],
                          ),
                        ],
                      );
                    } else {
                      print('Checkout build: No discount to show (discountAmount=$discountAmount)');
                      return const SizedBox.shrink();
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      "Total Payment",
                      style: GoogleFonts.chakraPetch(
                        color: Theme.of(context)
                            .colorScheme
                            .inverseSurface
                            .withOpacity(0.7),
                        fontSize: MediaQuery.textScalerOf(context).scale(15),
                      ),
                    ),
                    const Spacer(),
                    Builder(
                      builder: (context) {
                        final totalCost = ref.watch(cartProvider.notifier).totalCost;
                        final finalTotal = _calculateFinalTotal(totalCost);
                        print('Checkout build Total Payment: totalCost=$totalCost, discountAmount=$discountAmount, finalTotal=$finalTotal');
                        return Text(
                          '\฿${finalTotal.toStringAsFixed(0)}',
                          style: GoogleFonts.chakraPetch(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        );
                      },
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                if (!_isFormValid())
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            "Please add your address before checkout",
                            style: GoogleFonts.chakraPetch(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                Center(
                  child: FilledButton(
                    onPressed: _isFormValid()
                        ? () {
                            // Calculate total amount
                            double totalAmount = 0;
                            for (var item in cartItems) {
                              totalAmount +=
                                  (item.selectedVariant?.price ??
                                          item.shirt.price) *
                                      item.quantity;
                            }
                            // Apply discount if available
                            final finalTotal = _calculateFinalTotal(totalAmount);

                            // Show different modal based on selected payment method
                            if (selectedPaymentMethod == 'cash') {
                              _processCashPayment(finalTotal);
                            } else {
                              _showQRCodeModal(finalTotal);
                            }
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: _isFormValid()
                          ? Colors.red.shade400
                          : Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "Check Out",
                      style: GoogleFonts.chakraPetch(
                        color: _isFormValid() ? Colors.white : Colors.grey.shade600,
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
            )
          ],
        ),
        ),
      ),
    );
  }
}
