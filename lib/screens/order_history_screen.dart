import 'package:brand_store_app/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  String _searchQuery = '';
  int _currentPage = 1;
  final int _itemsPerPage = 6;

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
        return 'Shipping';
      case 'processing':
        return 'Shipping';
      case 'completed':
        return 'Delivered';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'processing':
        return Colors.orange; // Yellow/Orange for Shipping
      case 'completed':
        return Colors.green; // Green for Delivered
      default:
        return Colors.red; // Red for Canceled or other
    }
  }

  String _formatOrderDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      // Format: M/d/yy (e.g., 1/31/14, 7/18/17)
      return DateFormat('M/d/yy').format(date);
    } catch (e) {
      return '';
    }
  }

  List<Map<String, dynamic>> get _filteredOrders {
    if (_searchQuery.isEmpty) {
      return _orders;
    }
    return _orders.where((order) {
      final orderNumber = (order['order_number'] as String? ?? '').toLowerCase();
      return orderNumber.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Map<String, dynamic>> get _paginatedOrders {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    if (startIndex >= _filteredOrders.length) {
      return [];
    }
    return _filteredOrders.sublist(
      startIndex,
      endIndex > _filteredOrders.length ? _filteredOrders.length : endIndex,
    );
  }

  int get _totalPages {
    return (_filteredOrders.length / _itemsPerPage).ceil();
  }

  Widget _buildOrderRow(BuildContext context, Map<String, dynamic> order, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final status = order['status'] as String? ?? 'pending';
    final orderNumber = order['order_number'] as String? ?? 'N/A';
    final createdAt = order['created_at'] as String?;
    final statusText = _getStatusText(status);
    final statusColor = _getStatusColor(status);
    final orderDate = _formatOrderDate(createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceVariant : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Order number
          Expanded(
            flex: 2,
            child: Text(
              orderNumber,
              style: GoogleFonts.chakraPetch(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          // Order date
          Expanded(
            flex: 2,
            child: Text(
              orderDate,
              style: GoogleFonts.chakraPetch(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          // Status
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: GoogleFonts.chakraPetch(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          // More
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                // Navigate to order details or show bottom sheet
                _showOrderDetails(context, order);
              },
              child: Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
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
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Details',
                    style: GoogleFonts.chakraPetch(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Order details
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Order Number', order['order_number'] as String? ?? 'N/A'),
                    const SizedBox(height: 16),
                    _buildDetailRow('Order Date', _formatOrderDate(order['created_at'] as String?)),
                    const SizedBox(height: 16),
                    _buildDetailRow('Status', _getStatusText(order['status'] as String? ?? 'pending')),
                    const SizedBox(height: 16),
                    // Calculate subtotal (sum of all items)
                    if (order['order_items'] != null) ...[
                      Builder(
                        builder: (context) {
                          final orderItems = order['order_items'] as List;
                          final subtotal = orderItems.fold<double>(
                            0.0,
                            (sum, item) {
                              final itemPrice = (item['price'] as num?)?.toDouble() ?? 0.0;
                              final itemQuantity = (item['quantity'] as num?)?.toInt() ?? 0;
                              return sum + (itemPrice * itemQuantity);
                            },
                          );
                          return _buildDetailRow('Subtotal', '฿${subtotal.toStringAsFixed(2)}');
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Show discount if exists
                    if (((order['discount_amount'] as num?)?.toDouble() ?? 0.0) > 0) ...[
                      _buildDetailRow(
                        'Discount',
                        '-฿${((order['discount_amount'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildDetailRow('Total Amount', '฿${((order['total_amount'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2)}'),
                    const SizedBox(height: 24),
                    // Order items
                    if (order['order_items'] != null) ...[
                      Text(
                        'Order Items',
                        style: GoogleFonts.chakraPetch(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...((order['order_items'] as List).map<Widget>((item) {
                        final itemName = item['name'] as String? ?? 'N/A';
                        final itemPrice = (item['price'] as num?)?.toDouble() ?? 0.0;
                        final itemQuantity = (item['quantity'] as num?)?.toInt() ?? 0;
                        final itemTotal = itemPrice * itemQuantity;
                        final colorScheme = Theme.of(context).colorScheme;
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
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              Text(
                                '฿${itemTotal.toStringAsFixed(2)}',
                                style: GoogleFonts.chakraPetch(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList()),
                    ],
                  ],
                ),
              ),
            ),
            // E-Receipt button (only show when status is completed)
            if ((order['status'] as String? ?? 'pending').toLowerCase() == 'completed')
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
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
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.chakraPetch(
            fontSize: 14,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.chakraPetch(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: colorScheme.onSurface,
          ),
        ),
      ],
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
          style: GoogleFonts.chakraPetch(fontSize: 23),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const ImageIcon(
            size: 25,
            AssetImage("assets/icons/back_arrow.png"),
          ),
        ),
      ),
      backgroundColor: theme.colorScheme.surface,
      body: _isLoading
          ? const Center(
              child: SpinKitDancingSquare(
                color: Colors.red,
                size: 50.0,
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Search bar
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                              _currentPage = 1; // Reset to first page when searching
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: GoogleFonts.chakraPetch(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            filled: true,
                            fillColor: theme.brightness == Brightness.dark
                                ? theme.colorScheme.surfaceVariant
                                : Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Filter button
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement filter functionality
                        },
                        icon: Icon(
                          Icons.tune,
                          size: 20,
                          color: theme.colorScheme.onSurface,
                        ),
                        label: Text(
                          'Filter',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          side: BorderSide(
                            color: theme.dividerColor,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Header row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? theme.colorScheme.surfaceVariant
                        : Colors.grey.shade200,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Order number',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Order date',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Status',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'More',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Order list
                Expanded(
                  child: _filteredOrders.isEmpty
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
                                _searchQuery.isEmpty
                                    ? 'No orders yet'
                                    : 'No orders found',
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
                            itemCount: _paginatedOrders.length,
                            itemBuilder: (context, index) {
                              return _buildOrderRow(
                                context,
                                _paginatedOrders[index],
                                index,
                              );
                            },
                          ),
                        ),
                ),
                // Pagination
                if (_totalPages > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Previous button
                        IconButton(
                          onPressed: _currentPage > 1
                              ? () {
                                  setState(() {
                                    _currentPage--;
                                  });
                                }
                              : null,
                          icon: Icon(
                            Icons.chevron_left,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        // Page numbers
                        ...List.generate(_totalPages, (index) {
                          final page = index + 1;
                          // Show first page, last page, current page, and pages around current
                          if (page == 1 ||
                              page == _totalPages ||
                              (page >= _currentPage - 1 && page <= _currentPage + 1)) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentPage = page;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _currentPage == page
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '$page',
                                  style: GoogleFonts.chakraPetch(
                                    fontSize: 14,
                                    color: _currentPage == page
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurface,
                                    fontWeight: _currentPage == page
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          } else if (page == _currentPage - 2 || page == _currentPage + 2) {
                            // Show ellipsis
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                '...',
                                style: GoogleFonts.chakraPetch(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                        // Next button
                        IconButton(
                          onPressed: _currentPage < _totalPages
                              ? () {
                                  setState(() {
                                    _currentPage++;
                                  });
                                }
                              : null,
                          icon: Icon(
                            Icons.chevron_right,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
