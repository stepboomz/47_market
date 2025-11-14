import 'package:brand_store_app/models/category_model.dart';
import 'package:brand_store_app/models/shirt_model.dart';
import 'package:brand_store_app/services/supabase_service.dart';

class DataService {
  // ดึงข้อมูลหมวดหมู่จาก Supabase
  static Future<List<BrandCategory>> getCategories() async {
    final categories = await SupabaseService.getCategories();
    if (categories.isEmpty) {
      return _getDefaultCategories();
    }
    return categories;
  }

  // ดึงข้อมูลสินค้าจาก Supabase
  static Future<List<ShirtModel>> getProducts() async {
    final products = await SupabaseService.getProducts();
    if (products.isEmpty) {
      return _getDefaultProducts();
    }
    return products;
  }

  // ดึงข้อมูลสินค้าตามหมวดหมู่จาก Supabase โดยตรง
  static Future<List<ShirtModel>> getProductsByCategory(String categoryId) async {
    if (categoryId == 'all') {
      return getProducts();
    }
    return SupabaseService.getProducts(categoryId: categoryId);
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
