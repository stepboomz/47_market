import 'package:brand_store_app/models/shirt_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brand_store_app/services/storage_service.dart';

class FavoriteNotifier extends StateNotifier<List<ShirtModel>> {
  FavoriteNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final list = await StorageService.loadFavoritesJsonList();
    final restored = list
        .whereType<Map<String, dynamic>>()
        .map((e) => ShirtModel.fromJson(e))
        .toList();
    state = restored;
  }

  Future<void> _persist() async {
    final list = state.map((e) => e.toJson()).toList();
    await StorageService.saveFavoritesJsonList(list);
  }

  /// Add an item to favorites
  void addToFavorites(ShirtModel shirt) {
    if (!state.any((item) => item.id == shirt.id)) {
      state = [...state, shirt];
      _persist();
    }
  }

  /// Remove an item from favorites
  void removeFromFavorites(ShirtModel shirt) {
    state = state.where((item) => item.id != shirt.id).toList();
    _persist();
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
    _persist();
  }
}

/// Provider for FavoriteNotifier
final favoriteProvider = StateNotifierProvider<FavoriteNotifier, List<ShirtModel>>(
  (ref) => FavoriteNotifier(),
);
