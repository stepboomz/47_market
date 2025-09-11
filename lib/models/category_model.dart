enum BrandType { all, readyMeals, ingredients, snacks, beverages, seasonings }

class BrandCategory {
  final BrandType type;
  bool isSelected;
  
  BrandCategory(this.type, this.isSelected);

  String get displayName {
    switch (type) {
      case BrandType.all:
        return 'ทั้งหมด';
      case BrandType.readyMeals:
        return 'อาหารสำเร็จรูป';
      case BrandType.ingredients:
        return 'วัตถุดิบ';
      case BrandType.snacks:
        return 'ขนม';
      case BrandType.beverages:
        return 'เครื่องดื่ม';
      case BrandType.seasonings:
        return 'เครื่องปรุงส่วนผสม';
    }
  }

  // สร้าง BrandCategory จาก JSON
  factory BrandCategory.fromJson(Map<String, dynamic> json) {
    BrandType type;
    switch (json['id']) {
      case 'all':
        type = BrandType.all;
        break;
      case 'readyMeals':
        type = BrandType.readyMeals;
        break;
      case 'ingredients':
        type = BrandType.ingredients;
        break;
      case 'snacks':
        type = BrandType.snacks;
        break;
      case 'beverages':
        type = BrandType.beverages;
        break;
      case 'seasonings':
        type = BrandType.seasonings;
        break;
      default:
        type = BrandType.all;
    }
    
    return BrandCategory(type, json['isSelected'] ?? false);
  }

  // แปลง BrandCategory เป็น JSON
  Map<String, dynamic> toJson() {
    return {
      'id': type.name,
      'name': displayName,
      'isSelected': isSelected,
    };
  }
}
