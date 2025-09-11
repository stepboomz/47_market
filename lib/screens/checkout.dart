import 'package:brand_store_app/providers/cart_provider.dart';
import 'package:brand_store_app/services/storage_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Checkout extends ConsumerStatefulWidget {
  const Checkout({super.key});

  @override
  ConsumerState<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends ConsumerState<Checkout> {
  bool showAddressForm = true;
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

  Future<void> _loadSavedAddress() async {
    final info = await StorageService.loadCheckoutInfo();
    setState(() {
      savedName = info['name'];
      savedPhone = info['phone'];
      savedAddress = info['address'];
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
        title: Text("Checkout", style: GoogleFonts.imprima(fontSize: 25)),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Delivery Address",
              style: GoogleFonts.imprima(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .inverseSurface
                      .withOpacity(0.7)),
            ),
            if (!showAddressForm) ...[
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 120,
                        width: MediaQuery.sizeOf(context).width * 0.6,
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
                                    style: GoogleFonts.imprima(
                                        fontSize: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inverseSurface,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  if (savedName != null && savedName!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      "Name: $savedName",
                                      style: GoogleFonts.imprima(
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inverseSurface
                                            .withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                   if (savedAddress != null && savedAddress!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      "Address: $savedAddress",
                                      style: GoogleFonts.imprima(
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inverseSurface
                                            .withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                  if (savedPhone != null && savedPhone!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      "Phone: $savedPhone",
                                      style: GoogleFonts.imprima(
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inverseSurface
                                            .withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                 
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showAddressForm = true;
                      });
                    },
                    child: Text("Change", style: GoogleFonts.imprima(fontSize: 15)),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
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
                        // ล้างข้อมูลใน text field (ไม่ลบที่บันทึกไว้)
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
                        "ยกเลิก",
                        style: GoogleFonts.imprima(
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
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "บันทึก",
                        style: GoogleFonts.imprima(
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
                  "Delivered in 15–20 minutes",
                  style: GoogleFonts.imprima(
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
              style: GoogleFonts.imprima(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .inverseSurface
                      .withOpacity(0.7)),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  "assets/images/payment/promptpay.png",
                  width: 50,
                ),
              
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            // Center(
            //   child: Text(
            //     "Add Voucher",
            //     style: GoogleFonts.imprima(
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
                style: GoogleFonts.imprima(
                  fontSize: 15,
                  color: Colors.red,
                  fontWeight: FontWeight.w300,
                ),
                children: [
                  TextSpan(
                    text: "Don’t forget to fill in your name, phone number, and house address in the village",
                    style: GoogleFonts.imprima(
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
                  //   style: GoogleFonts.imprima(
                  //     fontSize: 15,
                  //     fontWeight: FontWeight.w300,
                  //   ),
                  // ),
                  // TextSpan(
                  //   text:
                  //       " if you forget to put your order id we can’t confirm the payment.",
                  //   style: GoogleFonts.imprima(
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
            const Spacer(),
            Column(
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
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: ShadDialog(
                                title: Text("Processing Payment"),
                                child: ShadProgress(),
                              ),
                            ),
                          );
                        },
                      );
                      await Future.delayed(const Duration(seconds: 1));
                      ref.read(cartProvider.notifier).clearCart();
                      if (!context.mounted) return;
                      ShadToaster.of(context).show(
                        const ShadToast(
                          title: Text("Paymemt Successful"),
                          duration: Duration(milliseconds: 1000),
                        ),
                      );
                      // Navigator.of(context)
                      //     .popUntil(ModalRoute.withName('/main'));
                      // Navigator.of(context)
                      //     .pushNamedAndRemoveUntil('/main', (route) => false);
                      Navigator.of(context).popUntil((route) => route.isFirst);
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
            )
          ],
        ),
      ),
    );
  }
}
