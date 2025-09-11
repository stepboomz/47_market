import 'package:brand_store_app/models/category_model.dart';
import 'package:brand_store_app/models/shirt_model.dart';
import 'package:brand_store_app/services/data_service.dart';

class AppData {
  const AppData._();

  // ข้อมูลหมวดหมู่ (จะโหลดจาก JSON)
  static List<BrandCategory> categories = [];
  
  // ข้อมูลสินค้า (จะโหลดจาก JSON)
  static List<ShirtModel> products = [];

  // โหลดข้อมูลหมวดหมู่จาก JSON
  static Future<void> loadCategories() async {
    categories = await DataService.getCategories();
  }

  // โหลดข้อมูลสินค้าจาก JSON
  static Future<void> loadProducts() async {
    products = await DataService.getProducts();
  }

  // โหลดข้อมูลทั้งหมด
  static Future<void> loadAllData() async {
    await Future.wait([
      loadCategories(),
      loadProducts(),
    ]);
  }

  // ดึงข้อมูลสินค้าตามหมวดหมู่
  static Future<List<ShirtModel>> getProductsByCategory(String categoryId) async {
    return await DataService.getProductsByCategory(categoryId);
  }
}
