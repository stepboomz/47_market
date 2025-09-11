import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageKeys {
  static const String themeMode = 'themeMode'; // 'light' | 'dark'
  static const String cartItems = 'cartItems'; // json list
  static const String favorites = 'favorites'; // json list
  static const String checkoutName = 'checkout_name';
  static const String checkoutPhone = 'checkout_phone';
  static const String checkoutAddress = 'checkout_address';
}

class StorageService {
  StorageService._();

  static Future<SharedPreferences> _prefs() async =>
      await SharedPreferences.getInstance();

  // Theme
  static Future<void> saveThemeMode(String mode) async {
    final prefs = await _prefs();
    await prefs.setString(StorageKeys.themeMode, mode);
  }

  static Future<String?> loadThemeMode() async {
    final prefs = await _prefs();
    return prefs.getString(StorageKeys.themeMode);
  }

  // Cart
  static Future<void> saveCartJsonList(List<Map<String, dynamic>> items) async {
    final prefs = await _prefs();
    final jsonString = jsonEncode(items);
    await prefs.setString(StorageKeys.cartItems, jsonString);
  }

  static Future<List<dynamic>> loadCartJsonList() async {
    final prefs = await _prefs();
    final jsonString = prefs.getString(StorageKeys.cartItems);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) return decoded;
      return [];
    } catch (_) {
      return [];
    }
  }

  // Favorites
  static Future<void> saveFavoritesJsonList(List<Map<String, dynamic>> items) async {
    final prefs = await _prefs();
    final jsonString = jsonEncode(items);
    await prefs.setString(StorageKeys.favorites, jsonString);
  }

  static Future<List<dynamic>> loadFavoritesJsonList() async {
    final prefs = await _prefs();
    final jsonString = prefs.getString(StorageKeys.favorites);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) return decoded;
      return [];
    } catch (_) {
      return [];
    }
  }

  // Checkout info
  static Future<void> saveCheckoutInfo({
    required String name,
    required String phone,
    required String address,
  }) async {
    final prefs = await _prefs();
    await prefs.setString(StorageKeys.checkoutName, name);
    await prefs.setString(StorageKeys.checkoutPhone, phone);
    await prefs.setString(StorageKeys.checkoutAddress, address);
  }

  static Future<Map<String, String?>> loadCheckoutInfo() async {
    final prefs = await _prefs();
    return {
      'name': prefs.getString(StorageKeys.checkoutName),
      'phone': prefs.getString(StorageKeys.checkoutPhone),
      'address': prefs.getString(StorageKeys.checkoutAddress),
    };
  }
}


