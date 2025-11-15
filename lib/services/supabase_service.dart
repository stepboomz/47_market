import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/category_model.dart';
import '../models/shirt_model.dart';
import '../models/product_variant.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Categories
  static Future<List<BrandCategory>> getCategories() async {
    try {
      // Only fetch categories that are active (is_active = true)
      final response = await _client
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('order_index', ascending: true)
          .order('id');
      final categories = response.map<BrandCategory>((json) {
        return BrandCategory.fromJson({
          'id': json['id'],
          'name': json['display_name'] ?? json['name'],
          'isSelected': json['is_selected'] ?? false,
        });
      }).toList();

      // Ensure "all" category appears first
      categories.sort((a, b) {
        if (a.type == BrandType.all && b.type != BrandType.all) return -1;
        if (b.type == BrandType.all && a.type != BrandType.all) return 1;
        return 0;
      });

      return categories;
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  // Admin: update category order
  static Future<bool> updateCategoryOrder(
      List<Map<String, dynamic>> idToOrder) async {
    try {
      // Use individual UPDATEs to avoid INSERT path hitting NOT NULL constraints
      await Future.wait(idToOrder.map((e) => _client
          .from('categories')
          .update({'order_index': e['order_index']}).eq('id', e['id'])));
      return true;
    } catch (e) {
      print('Error updating category order: $e');
      return false;
    }
  }

  // Admin: CRUD products
  static Future<String?> createProduct(Map<String, dynamic> data) async {
    try {
      // Ensure an id exists since products.id has no default
      final Map<String, dynamic> payload = Map<String, dynamic>.from(data);
      payload['id'] = (payload['id']?.toString().isNotEmpty ?? false)
          ? payload['id'].toString()
          : DateTime.now().millisecondsSinceEpoch.toString();
      final res =
          await _client.from('products').insert(payload).select('id').single();
      return res['id'].toString();
    } catch (e) {
      print('Error createProduct: $e');
      return null;
    }
  }

  static Future<bool> updateProduct(
      String id, Map<String, dynamic> data) async {
    try {
      await _client.from('products').update(data).eq('id', id);
      return true;
    } catch (e) {
      print('Error updateProduct: $e');
      return false;
    }
  }

  static Future<bool> deleteProduct(String id) async {
    try {
      await _client.from('products').delete().eq('id', id);
      await _client.from('product_variants').delete().eq('product_id', id);
      await _client.from('product_sizes').delete().eq('product_id', id);
      return true;
    } catch (e) {
      print('Error deleteProduct: $e');
      return false;
    }
  }

  // Storage: upload image to bucket 'product-images'
  static Future<String?> uploadImage(
      String pathOnDevice, String fileName) async {
    try {
      final bytes = await File(pathOnDevice).readAsBytes();
      final storage = _client.storage.from('product-images');
      await storage.uploadBinary(fileName, bytes,
          fileOptions: const FileOptions(upsert: true));
      return storage.getPublicUrl(fileName);
    } catch (e) {
      print('Error uploadImage: $e');
      return null;
    }
  }

  // Storage: upload slip image to bucket 'payment-slips'
  static Future<String?> uploadSlipImage(
      Uint8List imageBytes, String fileName) async {
    try {
      final storage = _client.storage.from('payment-slips');
      await storage.uploadBinary(fileName, imageBytes,
          fileOptions: const FileOptions(upsert: true));
      return storage.getPublicUrl(fileName);
    } catch (e) {
      print('Error uploadSlipImage: $e');
      return null;
    }
  }

  // Products
  static Future<List<ShirtModel>> getProducts({String? categoryId}) async {
    try {
      var query = _client.from('products').select('''
            *,
            product_variants(*),
            product_sizes(*)
          ''');

      if (categoryId != null && categoryId != 'all') {
        query = query.eq('category_id', categoryId);
      }

      final response = await query.order('id');

      return response.map<ShirtModel>((json) {
        // แปลง product_variants เป็น ProductVariant objects
        final variants = (json['product_variants'] as List?)
                ?.map((variant) => ProductVariant.fromJson(variant))
                .toList() ??
            [];

        // แปลง product_sizes เป็น List<String>
        final sizes = (json['product_sizes'] as List?)
                ?.map((size) => size['size'] as String)
                .toList() ??
            [];

        return ShirtModel.fromJson({
          'id': json['id'],
          'name': json['name'],
          'image': json['image'],
          'price': json['price'],
          'category': json['category_id'],
          'isFavorite': json['is_favorite'] ?? false,
          'description': json['description'] ?? '',
          'variants': variants.map((v) => v.toJson()).toList(),
          'sizes': sizes,
        });
      }).toList();
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  // Get single product with variants
  static Future<ShirtModel?> getProduct(String productId) async {
    try {
      final response = await _client.from('products').select('''
            *,
            product_variants(*),
            product_sizes(*)
          ''').eq('id', productId).single();

      // response จะเป็น Map หากพบข้อมูล

      // แปลง product_variants เป็น ProductVariant objects
      final variants = (response['product_variants'] as List?)
              ?.map((variant) => ProductVariant.fromJson(variant))
              .toList() ??
          [];

      // แปลง product_sizes เป็น List<String>
      final sizes = (response['product_sizes'] as List?)
              ?.map((size) => size['size'] as String)
              .toList() ??
          [];

      return ShirtModel.fromJson({
        'id': response['id'],
        'name': response['name'],
        'image': response['image'],
        'price': response['price'],
        'category': response['category_id'],
        'isFavorite': response['is_favorite'] ?? false,
        'description': response['description'] ?? '',
        'variants': variants.map((v) => v.toJson()).toList(),
        'sizes': sizes,
      });
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  // Search products
  static Future<List<ShirtModel>> searchProducts(String query) async {
    try {
      final response = await _client.from('products').select('''
            *,
            product_variants(*),
            product_sizes(*)
          ''').or('name.ilike.%$query%,description.ilike.%$query%').order('id');

      return response.map<ShirtModel>((json) {
        final variants = (json['product_variants'] as List?)
                ?.map((variant) => ProductVariant.fromJson(variant))
                .toList() ??
            [];

        final sizes = (json['product_sizes'] as List?)
                ?.map((size) => size['size'] as String)
                .toList() ??
            [];

        return ShirtModel.fromJson({
          'id': json['id'],
          'name': json['name'],
          'image': json['image'],
          'price': json['price'],
          'category': json['category_id'],
          'isFavorite': json['is_favorite'] ?? false,
          'description': json['description'] ?? '',
          'variants': variants.map((v) => v.toJson()).toList(),
          'sizes': sizes,
        });
      }).toList();
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  // Update product favorite status
  static Future<bool> updateProductFavorite(
      String productId, bool isFavorite) async {
    try {
      await _client
          .from('products')
          .update({'is_favorite': isFavorite}).eq('id', productId);
      return true;
    } catch (e) {
      print('Error updating product favorite: $e');
      return false;
    }
  }

  // Check if transaction reference already exists
  static Future<bool> isTransRefUsed(String transRef) async {
    try {
      final response = await _client
          .from('orders')
          .select('id')
          .eq('trans_ref', transRef)
          .limit(1);
      return response.isNotEmpty;
    } catch (e) {
      print('Error checking transRef: $e');
      return false;
    }
  }

  // Promo Codes
  static Future<Map<String, dynamic>?> validatePromoCode(
    String code,
    double totalAmount,
  ) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _client
          .from('promo_codes')
          .select()
          .eq('code', code.toUpperCase())
          .eq('is_active', true)
          .gte('end_date', now)
          .lte('start_date', now)
          .single();

      // Check usage limit
      final usedCount = (response['used_count'] as num?)?.toInt() ?? 0;
      final usageLimit = response['usage_limit'] as num?;
      if (usageLimit != null && usedCount >= usageLimit.toInt()) {
        return {'error': 'Promo code has reached its usage limit'};
      }

      // Check minimum purchase amount
      final minPurchase = (response['min_purchase_amount'] as num?)?.toDouble() ?? 0.0;
      if (totalAmount < minPurchase) {
        return {
          'error':
              'Minimum purchase amount of ฿${minPurchase.toStringAsFixed(0)} required'
        };
      }

      // Calculate discount
      double discountAmount = 0.0;
      final discountType = response['discount_type'] as String;
      final discountValue = (response['discount_value'] as num).toDouble();

      if (discountType == 'percentage') {
        discountAmount = totalAmount * (discountValue / 100);
        final maxDiscount = response['max_discount_amount'] as num?;
        if (maxDiscount != null && discountAmount > maxDiscount.toDouble()) {
          discountAmount = maxDiscount.toDouble();
        }
      } else if (discountType == 'fixed') {
        discountAmount = discountValue;
        if (discountAmount > totalAmount) {
          discountAmount = totalAmount;
        }
      }

      return {
        'id': response['id'],
        'code': response['code'],
        'description': response['description'],
        'discount_type': discountType,
        'discount_value': discountValue,
        'discount_amount': discountAmount,
        'min_purchase_amount': minPurchase,
        'max_discount_amount': response['max_discount_amount'],
      };
    } catch (e) {
      print('Error validating promo code: $e');
      return {'error': 'Invalid promo code'};
    }
  }

  // Orders
  static Future<Map<String, String>?> createOrder({
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
    String? transRef,
    String? slipImageUrl,
    String? paymentMethod, // 'qr' or 'cash'
    String? promoCodeId, // UUID of promo code
    double? discountAmount, // Discount amount applied
  }) async {
    try {
      final String orderId = DateTime.now().millisecondsSinceEpoch.toString();
      final String orderNumber = _generateOrderNumber();

      // Get current user ID
      final userId = _client.auth.currentUser?.id;

      final orderData = {
        'id': orderId,
        'order_number': orderNumber,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'customer_address': customerAddress,
        'total_amount': totalAmount,
        'status': 'pending',
      };

      // Add user_id if user is logged in
      if (userId != null) {
        orderData['user_id'] = userId;
      }

      // Add trans_ref if provided
      if (transRef != null && transRef.isNotEmpty) {
        orderData['trans_ref'] = transRef;
      }

      // Add slip_image_url if provided
      if (slipImageUrl != null && slipImageUrl.isNotEmpty) {
        orderData['slip_image_url'] = slipImageUrl;
      }

      // Add payment_method if provided
      if (paymentMethod != null && paymentMethod.isNotEmpty) {
        orderData['payment_method'] = paymentMethod;
      }

      // Add promo code info if provided
      print('createOrder: promoCodeId=$promoCodeId, discountAmount=$discountAmount');
      if (promoCodeId != null && promoCodeId.isNotEmpty) {
        orderData['promo_code_id'] = promoCodeId;
        print('createOrder: Added promo_code_id to orderData');
      }
      if (discountAmount != null && discountAmount > 0) {
        orderData['discount_amount'] = discountAmount;
        // Subtract discount from total_amount
        orderData['total_amount'] = totalAmount - discountAmount;
        print('createOrder: Added discount_amount=$discountAmount, new total_amount=${orderData['total_amount']}');
      }

      await _client.from('orders').insert(orderData);
      print('createOrder: Order inserted successfully');

      // Update promo code used_count if promo code was used
      if (promoCodeId != null && promoCodeId.isNotEmpty) {
        try {
          print('createOrder: Updating promo code used_count for promoCodeId=$promoCodeId');
          final currentCode = await _client
              .from('promo_codes')
              .select('used_count')
              .eq('id', promoCodeId)
              .single();
          print('createOrder: Current promo code data: $currentCode');
          final currentCount = (currentCode['used_count'] as int? ?? 0);
          print('createOrder: Current used_count=$currentCount, will update to ${currentCount + 1}');
          
          final updateResult = await _client
              .from('promo_codes')
              .update({'used_count': currentCount + 1})
              .eq('id', promoCodeId)
              .select();
          
          print('createOrder: Promo code updated successfully: $updateResult');
        } catch (e) {
          print('Error updating promo code usage: $e');
          print('Error stack trace: ${StackTrace.current}');
        }
      } else {
        print('createOrder: No promo code to update (promoCodeId is null or empty)');
      }

      final orderItems = items
          .map((e) => {
                'order_id': orderId,
                'product_id': e['product_id'],
                'variant_id': e['variant_id'],
                'name': e['name'],
                'price': e['price'],
                'quantity': e['quantity'],
              })
          .toList();

      if (orderItems.isNotEmpty) {
        await _client.from('order_items').insert(orderItems);
      }

      return {
        'orderId': orderId,
        'orderNumber': orderNumber,
      };
    } catch (e) {
      print('Error createOrder: $e');
      return null;
    }
  }

  static String _generateOrderNumber() {
    // e.g., OD-20251002-ABC123
    final date = DateTime.now();
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final rand = DateTime.now()
        .microsecondsSinceEpoch
        .toRadixString(36)
        .substring(5, 10)
        .toUpperCase();
    return 'OD-$y$m$d-$rand';
  }

  static Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final res = await _client
          .from('orders')
          .select('*, order_items(*)')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print('Error getOrders: $e');
      return [];
    }
  }

  // Get orders for current user
  // - Cash payment: show all orders
  // - QR payment: only show orders with trans_ref
  static Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }

      final res = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      // Filter based on payment method
      final filtered = (res as List).where((order) {
        final paymentMethod = order['payment_method'] as String?;
        final transRef = order['trans_ref'];
        
        // Cash payment: show all orders
        if (paymentMethod == 'cash') {
          return true;
        }
        
        // QR payment: only show if trans_ref exists
        if (paymentMethod == 'qr') {
          return transRef != null && transRef.toString().isNotEmpty;
        }
        
        // For backward compatibility: if payment_method is null, check trans_ref
        // (old orders without payment_method)
        return transRef != null && transRef.toString().isNotEmpty;
      }).toList();
      
      return List<Map<String, dynamic>>.from(filtered);
    } catch (e) {
      print('Error getUserOrders: $e');
      return [];
    }
  }

  static Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _client.from('orders').update({'status': status}).eq('id', orderId);
      return true;
    } catch (e) {
      print('Error updateOrderStatus: $e');
      return false;
    }
  }

  // Get order counts by status for current user
  // - Cash payment: count all orders
  // - QR payment: only count orders with trans_ref
  static Future<Map<String, int>> getUserOrderCounts() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return {'pending': 0, 'processing': 0, 'completed': 0};
      }

      final res = await _client
          .from('orders')
          .select('status, payment_method, trans_ref')
          .eq('user_id', userId);
      
      // Filter based on payment method
      final filtered = (res as List).where((order) {
        final paymentMethod = order['payment_method'] as String?;
        final transRef = order['trans_ref'];
        
        // Cash payment: count all orders
        if (paymentMethod == 'cash') {
          return true;
        }
        
        // QR payment: only count if trans_ref exists
        if (paymentMethod == 'qr') {
          return transRef != null && transRef.toString().isNotEmpty;
        }
        
        // For backward compatibility: if payment_method is null, check trans_ref
        // (old orders without payment_method)
        return transRef != null && transRef.toString().isNotEmpty;
      }).toList();

      int pending = 0;
      int processing = 0;
      int completed = 0;

      for (var order in filtered) {
        final status = (order['status'] as String? ?? '').toLowerCase();
        if (status == 'pending') {
          pending++;
        } else if (status == 'processing') {
          processing++;
        } else if (status == 'completed') {
          completed++;
        }
      }

      return {
        'pending': pending,
        'processing': processing,
        'completed': completed,
      };
    } catch (e) {
      print('Error getUserOrderCounts: $e');
      return {'pending': 0, 'processing': 0, 'completed': 0};
    }
  }
}
