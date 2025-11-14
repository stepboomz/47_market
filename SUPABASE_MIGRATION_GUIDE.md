# คู่มือการย้ายข้อมูลไป Supabase

## ขั้นตอนการตั้งค่า

### 1. สร้าง Supabase Project

1. ไปที่ [supabase.com](https://supabase.com) และสมัครสมาชิก
2. สร้าง New Project
3. เลือก Organization และตั้งชื่อ project (เช่น "47market")
4. เลือก Region (แนะนำ Singapore สำหรับประเทศไทย)
5. ตั้งรหัสผ่านสำหรับ database

### 2. ตั้งค่า Database

1. ไปที่ Supabase Dashboard > SQL Editor
2. รันไฟล์ `supabase_schema.sql` เพื่อสร้าง tables
3. รันไฟล์ `migrate_data.sql` เพื่อย้ายข้อมูล

### 3. ตั้งค่า Flutter App

1. ไปที่ Supabase Dashboard > Settings > API
2. คัดลอก Project URL และ anon public key
3. เปิดไฟล์ `lib/config/supabase_config.dart`
4. แทนที่ `YOUR_SUPABASE_URL` และ `YOUR_SUPABASE_ANON_KEY` ด้วยค่าจริง

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project-id.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
}
```

### 4. ติดตั้ง Dependencies

รันคำสั่ง:
```bash
flutter pub get
```

### 5. Database Schema

#### Tables ที่สร้าง:

1. **categories** - หมวดหมู่สินค้า
   - id (TEXT PRIMARY KEY)
   - name (TEXT)
   - display_name (TEXT)
   - is_selected (BOOLEAN)

2. **products** - สินค้า
   - id (TEXT PRIMARY KEY)
   - name (TEXT)
   - image (TEXT)
   - price (DECIMAL)
   - category_id (TEXT, FOREIGN KEY)
   - description (TEXT)
   - is_favorite (BOOLEAN)

3. **product_variants** - รูปแบบสินค้า
   - id (TEXT PRIMARY KEY)
   - product_id (TEXT, FOREIGN KEY)
   - name (TEXT)
   - image (TEXT)
   - price (DECIMAL)
   - description (TEXT)

4. **product_sizes** - ขนาดสินค้า
   - id (SERIAL PRIMARY KEY)
   - product_id (TEXT, FOREIGN KEY)
   - size (TEXT)

### 6. การใช้งานใน Flutter

#### ตัวอย่างการเรียกใช้:

```dart
import 'package:brand_store_app/services/supabase_service.dart';

// ดึงหมวดหมู่ทั้งหมด
final categories = await SupabaseService.getCategories();

// ดึงสินค้าทั้งหมด
final products = await SupabaseService.getProducts();

// ดึงสินค้าตามหมวดหมู่
final readyMeals = await SupabaseService.getProducts(categoryId: 'readyMeals');

// ค้นหาสินค้า
final searchResults = await SupabaseService.searchProducts('มาม่า');

// อัปเดตสถานะ favorite
await SupabaseService.updateProductFavorite('1', true);
```

### 7. Row Level Security (RLS)

- เปิดใช้งาน RLS สำหรับทุก tables
- สร้าง policies ให้ทุกคนอ่านข้อมูลได้
- ป้องกันการเขียนข้อมูลโดยไม่ได้รับอนุญาต

### 8. การ Debug

หากมีปัญหา:
1. ตรวจสอบ Supabase URL และ API Key
2. ตรวจสอบ Network connection
3. ดู logs ใน Supabase Dashboard > Logs
4. ตรวจสอบ RLS policies

### 9. การ Backup

- Supabase มี automatic backup
- สามารถ export ข้อมูลได้จาก Dashboard > Database > Backups

### 10. Performance Tips

- ใช้ indexes ที่สร้างไว้แล้ว
- ใช้ pagination สำหรับข้อมูลจำนวนมาก
- Cache ข้อมูลใน Flutter app
- ใช้ real-time subscriptions สำหรับข้อมูลที่เปลี่ยนแปลงบ่อย

## ไฟล์ที่เกี่ยวข้อง

- `supabase_schema.sql` - สร้าง database schema
- `migrate_data.sql` - ย้ายข้อมูลจาก JSON
- `lib/services/supabase_service.dart` - Flutter service
- `lib/config/supabase_config.dart` - Configuration
- `lib/main.dart` - Initialize Supabase
