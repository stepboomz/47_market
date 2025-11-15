import 'package:brand_store_app/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  Set<int> _expandedOrders = {};

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orders = await SupabaseService.getUserOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading orders: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'In Progress';
      case 'processing':
        return 'In Progress';
      case 'completed':
        return 'Delivered';
      default:
        return status;
    }
  }

  // Convert UTC to Thailand time (UTC+7)
  DateTime _toThailandTime(DateTime utcDate) {
    return utcDate.add(const Duration(hours: 7));
  }

  List<Map<String, dynamic>> _getTimelineStages(
    String status,
    String? createdAt,
    String? updatedAt,
  ) {
    DateTime? placedDate;
    DateTime? progressDate;
    DateTime? deliveredDate;

    // Parse dates and convert to Thailand time
    if (createdAt != null) {
      try {
        final utcDate = DateTime.parse(createdAt).toUtc();
        placedDate = _toThailandTime(utcDate);
        // In Progress uses the same date as Order Placed if status is pending
        if (status == 'pending') {
          progressDate = placedDate;
        }
      } catch (e) {
        print('Error parsing createdAt: $e');
      }
    }

    if (updatedAt != null) {
      try {
        final utcDate = DateTime.parse(updatedAt).toUtc();
        final thaiDate = _toThailandTime(utcDate);
        // If status is completed, use updatedAt for delivered date
        if (status == 'completed') {
          deliveredDate = thaiDate;
          // In Progress date is between placed and delivered
          if (placedDate != null) {
            final diff = deliveredDate.difference(placedDate);
            progressDate = placedDate.add(Duration(seconds: diff.inSeconds ~/ 2));
          }
        } else if (status == 'pending') {
          // If still pending, progress date is same as placed
          progressDate = placedDate;
        }
      } catch (e) {
        print('Error parsing updatedAt: $e');
      }
    }

    final stages = [
      {
        'key': 'placed',
        'title': 'Order Placed',
        'icon': Icons.shopping_bag,
        'completed': true,
        'date': placedDate,
      },
      {
        'key': 'progress',
        'title': 'In Progress',
        'icon': Icons.percent,
        'completed': status == 'pending' || status == 'completed',
        'date': progressDate,
      },
      {
        'key': 'delivered',
        'title': 'Delivered',
        'icon': Icons.home,
        'completed': status == 'completed',
        'date': deliveredDate,
      },
    ];

    return stages;
  }

  String _formatTimelineDate(DateTime? date, bool isCompleted) {
    if (date == null) return '';
    if (isCompleted) {
      // Format: "Fri, 23 Feb 22, 4:23 PM" in Thai time
      return DateFormat('EEE, dd MMM yy, h:mm a', 'en').format(date);
    } else {
      // For pending stages, show expected date
      return 'Expected ${DateFormat('dd MMM', 'en').format(date)}';
    }
  }


  Widget _buildTimelineStage(
    BuildContext context,
    Map<String, dynamic> stage,
    bool isLast,
    ThemeData theme,
  ) {
    final isCompleted = stage['completed'] as bool;
    final date = stage['date'] as DateTime?;
    final icon = stage['icon'] as IconData;
    final title = stage['title'] as String;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green : Colors.grey.shade300,
                border: Border.all(
                  color: isCompleted ? Colors.green : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check,
                size: 18,
                color: isCompleted ? Colors.white : Colors.grey.shade600,
              ),
            ),
            if (!isLast)
              CustomPaint(
                size: const Size(2, 60),
                painter: _DashedLinePainter(
                  color: isCompleted ? Colors.green : Colors.grey.shade300,
                  isDashed: !isCompleted,
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.chakraPetch(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTimelineDate(date, isCompleted),
                style: GoogleFonts.chakraPetch(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        // Right icon
        Icon(
          icon,
          size: 24,
          color: isCompleted ? Colors.green : Colors.grey.shade400,
        ),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order, int index) {
    final theme = Theme.of(context);
    final orderItems = order['order_items'] as List? ?? [];
    final status = order['status'] as String? ?? 'pending';
    final totalAmount = (order['total_amount'] as num?)?.toDouble() ?? 0.0;
    final orderNumber = order['order_number'] as String? ?? 'N/A';
    final createdAt = order['created_at'] as String?;
    final updatedAt = order['updated_at'] as String?;
    final isExpanded = _expandedOrders.contains(index);

    // Get first product for header
    final firstItem = orderItems.isNotEmpty ? orderItems[0] : null;
    final productName = firstItem?['name'] as String? ?? 'Order #$orderNumber';

    final timelineStages = _getTimelineStages(status, createdAt, updatedAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header section
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedOrders.remove(index);
                } else {
                  _expandedOrders.add(index);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Product image placeholder
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.shopping_bag,
                      color: Colors.grey.shade400,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Product name and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          style: GoogleFonts.chakraPetch(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${_getStatusText(status)}',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Expand icon
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ],
              ),
            ),
          ),
          // Timeline section (when expanded)
          if (isExpanded) ...[
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...timelineStages.asMap().entries.map((entry) {
                    final isLast = entry.key == timelineStages.length - 1;
                    return _buildTimelineStage(
                      context,
                      entry.value,
                      isLast,
                      theme,
                    );
                  }).toList(),
                ],
              ),
            ),
            // Order details
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Details',
                    style: GoogleFonts.chakraPetch(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Order items
                  if (orderItems.isNotEmpty) ...[
                    ...orderItems.map<Widget>((item) {
                      final itemName = item['name'] as String? ?? 'N/A';
                      final itemPrice = (item['price'] as num?)?.toDouble() ?? 0.0;
                      final itemQuantity = (item['quantity'] as num?)?.toInt() ?? 0;
                      final itemTotal = itemPrice * itemQuantity;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '$itemName x $itemQuantity',
                                style: GoogleFonts.chakraPetch(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              '฿${itemTotal.toStringAsFixed(2)}',
                              style: GoogleFonts.chakraPetch(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const Divider(),
                  ],
                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.chakraPetch(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '฿${totalAmount.toStringAsFixed(2)}',
                        style: GoogleFonts.chakraPetch(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  // E-Receipt button
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/e-receipt',
                          arguments: order,
                        );
                      },
                      icon: const Icon(Icons.receipt_long),
                      label: Text(
                        'E-Receipt',
                        style: GoogleFonts.chakraPetch(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.inverseSurface,
        elevation: 0,
        forceMaterialTransparency: true,
        toolbarHeight: 100,
        leadingWidth: 100,
        primary: true,
        centerTitle: true,
        title: Text(
          "Order History",
          style: GoogleFonts.chakraPetch(fontSize: 25),
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
      backgroundColor: theme.colorScheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No orders yet',
                        style: GoogleFonts.chakraPetch(
                          fontSize: 18,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(context, _orders[index], index);
                    },
                  ),
                ),
    );
  }
}

// Custom painter for dashed line
class _DashedLinePainter extends CustomPainter {
  final Color color;
  final bool isDashed;

  _DashedLinePainter({required this.color, required this.isDashed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;

    if (isDashed) {
      // Draw dashed line
      const dashWidth = 4.0;
      const dashSpace = 4.0;
      double startY = 0;

      while (startY < size.height) {
        canvas.drawLine(
          Offset(0, startY),
          Offset(0, startY + dashWidth),
          paint,
        );
        startY += dashWidth + dashSpace;
      }
    } else {
      // Draw solid line
      canvas.drawLine(
        Offset(0, 0),
        Offset(0, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isDashed != isDashed;
  }
}
