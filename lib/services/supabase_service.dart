import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
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

  // Orders
  static Future<String?> createOrder({
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final String orderId = DateTime.now().millisecondsSinceEpoch.toString();
      final String orderNumber = _generateOrderNumber();

      await _client.from('orders').insert({
        'id': orderId,
        'order_number': orderNumber,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'customer_address': customerAddress,
        'total_amount': totalAmount,
        'status': 'pending',
      });

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

      return orderNumber;
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

  static Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _client.from('orders').update({'status': status}).eq('id', orderId);
      return true;
    } catch (e) {
      print('Error updateOrderStatus: $e');
      return false;
    }
  }
}
