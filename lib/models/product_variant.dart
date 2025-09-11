class ProductVariant {
  String id;
  String name;
  String image;
  double price;
  String description;

  ProductVariant({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.description,
  });

  // สร้าง ProductVariant จาก JSON
  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
    );
  }

  // แปลง ProductVariant เป็น JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'description': description,
    };
  }
}
