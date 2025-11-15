import 'dart:typed_data';
import 'package:brand_store_app/providers/cart_provider.dart';
import 'package:brand_store_app/services/slip_verification_service.dart';
import 'package:brand_store_app/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SlipVerification extends ConsumerStatefulWidget {
  final String orderNumber;
  final double totalAmount;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final List<Map<String, dynamic>> orderItems;
  final String? promoCodeId;
  final double? discountAmount;

  const SlipVerification({
    super.key,
    required this.orderNumber,
    required this.totalAmount,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.orderItems,
    this.promoCodeId,
    this.discountAmount,
  });

  @override
  ConsumerState<SlipVerification> createState() => _SlipVerificationState();
}

class _SlipVerificationState extends ConsumerState<SlipVerification> {
  XFile? _selectedImage;
  Uint8List? _imageBytes;
  bool _isVerifying = false;
  Map<String, dynamic>? _verificationResult;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = pickedFile;
        _imageBytes = bytes;
        _verificationResult = null;
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = pickedFile;
        _imageBytes = bytes;
        _verificationResult = null;
      });
    }
  }

  Future<void> _verifySlip() async {
    if (_selectedImage == null || _imageBytes == null) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      // Upload slip image to Supabase Storage first (always upload)
      String? slipImageUrl;
      if (_imageBytes != null && _selectedImage != null) {
        try {
          final fileName = 'slip_${DateTime.now().millisecondsSinceEpoch}_${_selectedImage!.name}';
          slipImageUrl = await SupabaseService.uploadSlipImage(_imageBytes!, fileName);
          if (slipImageUrl == null) {
            print('Warning: Failed to upload slip image to storage');
          }
        } catch (e) {
          print('Warning: Error uploading slip image: $e');
        }
      }

      // Create order first (always create order)
      final orderResult = await SupabaseService.createOrder(
        customerName: widget.customerName,
        customerPhone: widget.customerPhone,
        customerAddress: widget.customerAddress,
        totalAmount: widget.totalAmount,
        items: widget.orderItems,
        slipImageUrl: slipImageUrl,
        paymentMethod: 'qr', // QR Code payment (PromptPay)
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

      final orderId = orderResult['orderId']!;
      final orderNumber = orderResult['orderNumber']!;

      // Now verify the slip
      final result = await SlipVerificationService.verifySlip(
        _selectedImage!,
        imageBytes: _imageBytes!,
        checkDuplicate: true,
      );

      if (result != null) {
        // Check if it's a duplicate slip
        if (result['isDuplicate'] == true || result['message'] == 'duplicate_slip') {
          if (mounted) {
            ShadToaster.of(context).show(
              const ShadToast(
                title: Text(
                  'This payment slip has already been used. Order created but payment verification failed.',
                ),
                duration: Duration(seconds: 4),
              ),
            );
          }
          // Order already created, just return
          return;
        }

        if (result['status'] == 200) {
          setState(() {
            _verificationResult = result['data'];
          });
        } else if (result['error'] == true) {
          // Handle other errors
          final errorMessage = result['message']?.toString() ?? 'Failed to verify slip. Please try again.';
          if (mounted) {
            ShadToaster.of(context).show(
              ShadToast(
                title: Text(errorMessage),
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        } else {
          if (mounted) {
            ShadToaster.of(context).show(
              const ShadToast(
                title: Text('Failed to verify slip. Please try again.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }

        // Check if amount matches
        final verifiedAmount = _verificationResult?['amount']?['amount']?.toDouble() ?? 0.0;
        final expectedAmount = widget.totalAmount;

        // Check if receiver account matches our PromptPay ID
        const String ourPromptPayId = '0957728931';
        final receiver = _verificationResult?['receiver'];
        final receiverProxy = receiver?['account']?['proxy'];
        final receiverBank = receiver?['account']?['bank'];
        
        // Check if receiver matches our PromptPay ID
        // It could be in proxy.account (MSISDN) or bank.account
        String? receiverAccount;
        String? receiverAccountType;
        
        if (receiverProxy != null && receiverProxy['account'] != null) {
          receiverAccount = receiverProxy['account'].toString();
          receiverAccountType = receiverProxy['type']?.toString();
        } else if (receiverBank != null && receiverBank['account'] != null) {
          receiverAccount = receiverBank['account'].toString();
          receiverAccountType = receiverBank['type']?.toString();
        }

        // Normalize account numbers (remove dashes, spaces, x, etc.)
        String normalizedReceiver = (receiverAccount ?? '').replaceAll(RegExp(r'[-\sxX]'), '');
        String normalizedPromptPay = ourPromptPayId.replaceAll(RegExp(r'[-\s]'), '');
        
        // Check if account matches
        // For MSISDN (phone number), check if it matches exactly or contains the PromptPay ID
        // For BANKAC (bank account), check last 4 digits if masked
        bool accountMatches = false;
        
        if (receiverAccount != null && normalizedReceiver.isNotEmpty) {
          if (receiverAccountType == 'MSISDN') {
            // For phone number, check if it matches or contains the PromptPay ID
            accountMatches = normalizedReceiver == normalizedPromptPay ||
                normalizedReceiver.contains(normalizedPromptPay) ||
                normalizedPromptPay.contains(normalizedReceiver);
          } else {
            // For bank account, check if last 4 digits match (in case of masking)
            // Or if the account contains the PromptPay ID
            if (normalizedReceiver.length >= 4 && normalizedPromptPay.length >= 4) {
              String receiverLast4 = normalizedReceiver.length >= 4 
                  ? normalizedReceiver.substring(normalizedReceiver.length - 4)
                  : normalizedReceiver;
              String promptPayLast4 = normalizedPromptPay.substring(normalizedPromptPay.length - 4);
              accountMatches = receiverLast4 == promptPayLast4 ||
                  normalizedReceiver == normalizedPromptPay ||
                  normalizedReceiver.contains(normalizedPromptPay);
            } else {
              accountMatches = normalizedReceiver == normalizedPromptPay ||
                  normalizedReceiver.contains(normalizedPromptPay);
            }
          }
        }

        if ((verifiedAmount - expectedAmount).abs() >= 0.01) {
          // Amount doesn't match
          if (mounted) {
            ShadToaster.of(context).show(
              ShadToast(
                title: Text(
                  'Amount mismatch. Expected: ${expectedAmount.toStringAsFixed(2)} Baht, Got: ${verifiedAmount.toStringAsFixed(2)} Baht',
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else if (receiverAccount == null || receiverAccount.isEmpty) {
          // No receiver account found in slip
          if (mounted) {
            ShadToaster.of(context).show(
              ShadToast(
                title: Text(
                  'Cannot verify receiver account. Please ensure the slip shows the correct receiver information.',
                ),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } else if (!accountMatches) {
          // Account doesn't match
          if (mounted) {
            ShadToaster.of(context).show(
              ShadToast(
                title: Text(
                  'Payment account mismatch. Please ensure you transfer to the correct PromptPay ID: $ourPromptPayId',
                ),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } else {
          // Amount and account match, check if transRef already used
          final transRef = _verificationResult?['transRef']?.toString();
          
          if (transRef != null && transRef.isNotEmpty) {
            // Check if this transaction reference has been used before
            final isUsed = await SupabaseService.isTransRefUsed(transRef);
            
            if (isUsed) {
              // This slip has already been used
              if (mounted) {
                ShadToaster.of(context).show(
                  const ShadToast(
                    title: Text(
                      'This payment slip has already been used. Order created but payment verification failed.',
                    ),
                    duration: Duration(seconds: 4),
                  ),
                );
              }
              // Order already created, just return
              return;
            }

            // Update order with transRef
            try {
              await Supabase.instance.client.from('orders').update({'trans_ref': transRef}).eq('id', orderId);
            } catch (e) {
              print('Warning: Failed to update transRef: $e');
            }
          }

          // Slip verification successful - update order status to "completed"
          final updateSuccess = await SupabaseService.updateOrderStatus(orderId, 'completed');
          
          if (updateSuccess && mounted) {
            // Clear cart
            ref.read(cartProvider.notifier).clearCart();

            // Close modal and navigate to success page
            Navigator.of(context, rootNavigator: true).pop();
            await Future.delayed(const Duration(milliseconds: 300));
            if (mounted) {
              Navigator.of(context, rootNavigator: true).pushReplacementNamed(
                '/order-success',
                arguments: {
                  'orderNumber': orderNumber,
                  'totalAmount': widget.totalAmount,
                },
              );
            }
          } else {
            if (mounted) {
              ShadToaster.of(context).show(
                const ShadToast(
                  title: Text('Order created but failed to update status.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        }
      } else {
        if (mounted) {
          ShadToaster.of(context).show(
            const ShadToast(
              title: Text('Failed to verify slip. Please try again.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
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
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
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
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: theme.colorScheme.onSurface,
                ),
                Expanded(
                  child: Text(
                    'Verify Bank Slip',
                    style: GoogleFonts.chakraPetch(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Balance the close button
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upload Slip Image',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please upload an image of your bank slip or QR code to verify your payment.',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 14,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Image picker buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: Icon(
                            Icons.photo_library,
                            color: Colors.red.shade400,
                          ),
                          label: Text(
                            'Gallery',
                            style: GoogleFonts.chakraPetch(
                              color: Colors.red.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: Colors.red.shade400,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _takePhoto,
                          icon: Icon(
                            Icons.camera_alt,
                            color: Colors.red.shade400,
                          ),
                          label: Text(
                            'Camera',
                            style: GoogleFonts.chakraPetch(
                              color: Colors.red.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: Colors.red.shade400,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Selected image preview
                  if (_selectedImage != null && _imageBytes != null)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.memory(
                          _imageBytes!,
                          fit: BoxFit.contain,
                          height: 300,
                        ),
                      ),
                    ),

                  // if (_selectedImage == null)
                  //   Container(
                  //     height: 300,
                  //     decoration: BoxDecoration(
                  //       color: isDark
                  //           ? Colors.grey.shade800
                  //           : Colors.grey.shade100,
                  //       borderRadius: BorderRadius.circular(16),
                  //       border: Border.all(
                  //         color: Colors.grey.shade300,
                  //         width: 1,
                  //       ),
                  //     ),
                  //     child: Center(
                  //       child: Column(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           Icon(
                  //             Icons.image_outlined,
                  //             size: 64,
                  //             color: theme.colorScheme.onSurface.withOpacity(0.4),
                  //           ),
                  //           const SizedBox(height: 16),
                  //           Text(
                  //             'No image selected',
                  //             style: GoogleFonts.chakraPetch(
                  //               fontSize: 16,
                  //               color: theme.colorScheme.onSurface.withOpacity(0.5),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),

                  const SizedBox(height: 24),

                  // Verification result
                  if (_verificationResult != null)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verification Result',
                            style: GoogleFonts.chakraPetch(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            context,
                            'Transaction Ref',
                            _verificationResult!['transRef']?.toString() ?? 'N/A',
                          ),
                          _buildInfoRow(
                            context,
                            'Amount',
                            '${_verificationResult!['amount']?['amount']?.toString() ?? '0'} Baht',
                          ),
                          _buildInfoRow(
                            context,
                            'Date',
                            _verificationResult!['date']?.toString() ?? 'N/A',
                          ),
                          if (_verificationResult!['sender'] != null)
                            _buildInfoRow(
                              context,
                              'Sender Bank',
                              _verificationResult!['sender']?['bank']?['name']?.toString() ?? 'N/A',
                            ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Verify button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: FilledButton(
                      onPressed: _selectedImage != null && !_isVerifying
                          ? _verifySlip
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: _selectedImage != null && !_isVerifying
                            ? Colors.red.shade400
                            : Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isVerifying
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: SpinKitDancingSquare(
                                color: Colors.white,
                                size: 20.0,
                              ),
                            )
                          : Text(
                              'Verify Slip',
                              style: GoogleFonts.chakraPetch(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: _selectedImage != null && !_isVerifying
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.chakraPetch(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.chakraPetch(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

