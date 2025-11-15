import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const EReceiptScreen({
    super.key,
    required this.order,
  });

  // Convert UTC to Thailand time (UTC+7)
  DateTime _toThailandTime(DateTime utcDate) {
    return utcDate.add(const Duration(hours: 7));
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final utcDate = DateTime.parse(dateString).toUtc();
      final thaiDate = _toThailandTime(utcDate);
      return DateFormat('dd.MM.yyyy HH:mm', 'en').format(thaiDate);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderItems = order['order_items'] as List? ?? [];
    final totalAmount = (order['total_amount'] as num?)?.toDouble() ?? 0.0;
    final orderNumber = order['order_number'] as String? ?? 'N/A';
    final createdAt = order['created_at'] as String?;
    final transRef = order['trans_ref'] as String? ?? '';
    
    // Calculate tax (assuming 7% VAT)
    final taxRate = 0.07;
    final taxAmount = totalAmount * taxRate / (1 + taxRate);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.inverseSurface,
        elevation: 0,
        forceMaterialTransparency: true,
        title: Text(
          "E-Receipt",
          style: GoogleFonts.chakraPetch(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              // TODO: Implement print functionality
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Perforated top edge effect
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: CustomPaint(
                    painter: _PerforatedEdgePainter(),
                  ),
                ),
                
                // Receipt content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      // Header Section
                      Text(
                        '47MARKET',
                        style: GoogleFonts.chakraPetch(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ADDRESS: 95/147 Siri Place 52, Soi 4 Khlong Thanon, Sai Mai, Bangkok 10220',
                        style: GoogleFonts.chakraPetch(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'PHONE: 0957728931',
                        style: GoogleFonts.chakraPetch(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        transRef.isNotEmpty ? 'No.$transRef' : 'No.$orderNumber',
                        style: GoogleFonts.chakraPetch(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      // Dashed line
                      _buildDashedLine(),
                      
                      // Transaction Details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'No. $orderNumber',
                            style: GoogleFonts.chakraPetch(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Cashier: System',
                            style: GoogleFonts.chakraPetch(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(createdAt),
                        style: GoogleFonts.chakraPetch(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      
                      // Dashed line
                      _buildDashedLine(),
                      
                      // Itemized List
                      ...orderItems.map<Widget>((item) {
                        final itemName = item['name'] as String? ?? 'N/A';
                        final itemPrice = (item['price'] as num?)?.toDouble() ?? 0.0;
                        final itemQuantity = (item['quantity'] as num?)?.toInt() ?? 0;
                        final itemTotal = itemPrice * itemQuantity;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  itemName,
                                  style: GoogleFonts.chakraPetch(
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatPrice(itemTotal),
                                style: GoogleFonts.chakraPetch(
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      
                      // Dashed line
                      _buildDashedLine(),
                      
                      // Summary Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: GoogleFonts.chakraPetch(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatPrice(totalAmount),
                            style: GoogleFonts.chakraPetch(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cash',
                            style: GoogleFonts.chakraPetch(
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatPrice(totalAmount),
                            style: GoogleFonts.chakraPetch(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Change',
                            style: GoogleFonts.chakraPetch(
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatPrice(0.0),
                            style: GoogleFonts.chakraPetch(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      
                      // Dashed line
                      _buildDashedLine(),
                      
                      // Tax Information
                      Text(
                        'TAX/VAT INCLUDED IN ABOVE TOTAL',
                        style: GoogleFonts.chakraPetch(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tax',
                            style: GoogleFonts.chakraPetch(
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatPrice(taxAmount),
                            style: GoogleFonts.chakraPetch(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Perforated bottom edge effect
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: CustomPaint(
                    painter: _PerforatedEdgePainter(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashedLine() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CustomPaint(
        size: const Size(double.infinity, 1),
        painter: _DashedLinePainter(),
      ),
    );
  }

  String _formatPrice(double price) {
    // Format with comma as decimal separator (like in the image)
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(price);
  }
}

// Custom painter for dashed line
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) => false;
}

// Custom painter for perforated edge
class _PerforatedEdgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    const circleRadius = 3.0;
    const spacing = 8.0;
    double startX = spacing;

    while (startX < size.width) {
      canvas.drawCircle(
        Offset(startX, size.height / 2),
        circleRadius,
        paint,
      );
      startX += spacing * 2;
    }
  }

  @override
  bool shouldRepaint(_PerforatedEdgePainter oldDelegate) => false;
}

