import 'package:brand_store_app/models/shirt_model.dart';
import 'package:brand_store_app/models/product_variant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brand_store_app/services/storage_service.dart';

class CartItem {
  final ShirtModel shirt;
  int quantity;
  final ProductVariant? selectedVariant;

  CartItem({required this.shirt, this.quantity = 1, this.selectedVariant});
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final list = await StorageService.loadCartJsonList();
    final restored = list.map((e) => _cartItemFromJson(e)).toList();
    state = restored.cast<CartItem>();
  }

  Future<void> _persist() async {
    final list = state.map((e) => _cartItemToJson(e)).toList();
    await StorageService.saveCartJsonList(list);
  }

  /// Add an item to the cart
  void addItem(ShirtModel shirt, {ProductVariant? selectedVariant}) {
    final existingItemIndex = state.indexWhere(
      (item) => item.shirt.name == shirt.name && 
                item.selectedVariant?.id == selectedVariant?.id,
    );

    if (existingItemIndex != -1) {
      // Update quantity if item exists
      state[existingItemIndex].quantity += 1;
      state = [...state]; // Trigger state update
    } else {
      // Add new item if it doesn't exist
      state = [...state, CartItem(shirt: shirt, selectedVariant: selectedVariant)];
    }
    _persist();
  }

  /// Remove an item from the cart
  void removeItem(ShirtModel shirt, {ProductVariant? selectedVariant}) {
    state = state.where((item) => 
      !(item.shirt.name == shirt.name && 
        item.selectedVariant?.id == selectedVariant?.id)
    ).toList();
    _persist();
  }

  /// Decrement the quantity of an item, or remove if quantity reaches zero
  void decrementItem(ShirtModel shirt, {ProductVariant? selectedVariant}) {
    final existingItemIndex = state.indexWhere(
      (item) => item.shirt.name == shirt.name && 
                item.selectedVariant?.id == selectedVariant?.id,
    );

    if (existingItemIndex == -1) {
      // Item not found, do nothing
      return;
    }

    final existingItem = state[existingItemIndex];

    if (existingItem.quantity > 1) {
      existingItem.quantity -= 1;
      state = [...state]; // Trigger state update
    } else {
      removeItem(shirt, selectedVariant: selectedVariant);
    }
    _persist();
  }

  /// Get the total cost of items in the cart
  double get totalCost {
    return state.fold(
      0.0,
      (sum, item) => sum + ((item.selectedVariant?.price ?? item.shirt.price) * item.quantity),
    );
  }

  /// Get the total quantity of items in the cart
  int get totalQuantity {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Get the total quantity of a specific item
  int getItemQuantity(ShirtModel shirt) {
    final existingItemIndex = state.indexWhere(
      (item) => item.shirt.name == shirt.name,
    );
    
    if (existingItemIndex == -1) {
      return 0;
    }
    
    return state[existingItemIndex].quantity;
  }

  /// Clear all items in the cart
  void clearCart() {
    state = [];
    _persist();
  }

  // Serialization helpers
  Map<String, dynamic> _cartItemToJson(CartItem item) {
    return {
      'shirt': item.shirt.toJson(),
      'quantity': item.quantity,
      'variant': item.selectedVariant == null
          ? null
          : {
              'id': item.selectedVariant!.id,
              'name': item.selectedVariant!.name,
              'image': item.selectedVariant!.image,
              'price': item.selectedVariant!.price,
              'description': item.selectedVariant!.description,
            },
    };
  }

  CartItem _cartItemFromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    final shirt = ShirtModel.fromJson(map['shirt'] as Map<String, dynamic>);
    final variantMap = map['variant'] as Map<String, dynamic>?;
    final variant = variantMap == null
        ? null
        : ProductVariant(
            id: variantMap['id'] ?? '',
            name: variantMap['name'] ?? '',
            image: variantMap['image'] ?? '',
            price: (variantMap['price'] ?? 0).toDouble(),
            description: variantMap['description'] ?? '',
          );
    return CartItem(
      shirt: shirt,
      quantity: (map['quantity'] ?? 1) as int,
      selectedVariant: variant,
    );
  }
}

/// Provider for CartNotifier
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);
