import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:brand_store_app/models/category_model.dart';
import 'package:brand_store_app/models/shirt_model.dart';

class DataService {
  static const String _categoriesPath = 'assets/data/categories.json';
  static const String _productsPath = 'assets/data/products.json';

  // ดึงข้อมูลหมวดหมู่จาก JSON
  static Future<List<BrandCategory>> getCategories() async {
    try {
      final String jsonString = await rootBundle.loadString(_categoriesPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      
      return jsonList.map((json) {
        return BrandCategory.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error loading categories: $e');
      return _getDefaultCategories();
    }
  }

  // ดึงข้อมูลสินค้าจาก JSON
  static Future<List<ShirtModel>> getProducts() async {
    try {
      final String jsonString = await rootBundle.loadString(_productsPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      
      return jsonList.map((json) {
        return ShirtModel.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error loading products: $e');
      return _getDefaultProducts();
    }
  }

  // ดึงข้อมูลสินค้าตามหมวดหมู่
  static Future<List<ShirtModel>> getProductsByCategory(String categoryId) async {
    final List<ShirtModel> allProducts = await getProducts();
    
    if (categoryId == 'all') {
      return allProducts;
    }
    
    return allProducts.where((product) => product.category == categoryId).toList();
  }

  // ข้อมูลหมวดหมู่เริ่มต้น (fallback)
  static List<BrandCategory> _getDefaultCategories() {
    return [
      BrandCategory(BrandType.all, true),
      BrandCategory(BrandType.readyMeals, false),
      BrandCategory(BrandType.ingredients, false),
      BrandCategory(BrandType.snacks, false),
      BrandCategory(BrandType.beverages, false),
      BrandCategory(BrandType.seasonings, false),
    ];
  }

  // ข้อมูลสินค้าเริ่มต้น (fallback)
  static List<ShirtModel> _getDefaultProducts() {
    return [
      ShirtModel(
        id: '1',
        name: 'สินค้าตัวอย่าง 1',
        image: 'assets/images/shirts/shirt1.png',
        price: 100.00,
        category: 'readyMeals',
        description: 'สินค้าตัวอย่าง 1',
      ),
      ShirtModel(
        id: '2',
        name: 'สินค้าตัวอย่าง 2',
        image: 'assets/images/shirts/shirt2.png',
        price: 200.00,
        category: 'ingredients',
        description: 'สินค้าตัวอย่าง 2',
      ),
    ];
  }
}
