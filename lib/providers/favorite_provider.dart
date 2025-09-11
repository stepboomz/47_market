import 'package:brand_store_app/models/shirt_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteNotifier extends StateNotifier<List<ShirtModel>> {
  FavoriteNotifier() : super([]);

  /// Add an item to favorites
  void addToFavorites(ShirtModel shirt) {
    if (!state.any((item) => item.id == shirt.id)) {
      state = [...state, shirt];
    }
  }

  /// Remove an item from favorites
  void removeFromFavorites(ShirtModel shirt) {
    state = state.where((item) => item.id != shirt.id).toList();
  }

  /// Toggle favorite status
  void toggleFavorite(ShirtModel shirt) {
    if (isFavorite(shirt)) {
      removeFromFavorites(shirt);
    } else {
      addToFavorites(shirt);
    }
  }

  /// Check if an item is in favorites
  bool isFavorite(ShirtModel shirt) {
    return state.any((item) => item.id == shirt.id);
  }

  /// Clear all favorites
  void clearFavorites() {
    state = [];
  }
}

/// Provider for FavoriteNotifier
final favoriteProvider = StateNotifierProvider<FavoriteNotifier, List<ShirtModel>>(
  (ref) => FavoriteNotifier(),
);
