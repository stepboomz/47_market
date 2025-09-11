import 'package:brand_store_app/models/shirt_model.dart';
import 'package:brand_store_app/models/product_variant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  final ShirtModel shirt;
  int quantity;
  final ProductVariant? selectedVariant;

  CartItem({required this.shirt, this.quantity = 1, this.selectedVariant});
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

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
  }

  /// Remove an item from the cart
  void removeItem(ShirtModel shirt, {ProductVariant? selectedVariant}) {
    state = state.where((item) => 
      !(item.shirt.name == shirt.name && 
        item.selectedVariant?.id == selectedVariant?.id)
    ).toList();
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
  }
}

/// Provider for CartNotifier
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);
