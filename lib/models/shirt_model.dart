import 'product_variant.dart';

class ShirtModel {
  String id;
  final String name;
  final List<String>? colors;
  final List<String>? sizes;
  final String? thumbnail;
  final String image;
  final double price;
  final String category;
  final bool? networkImage;
  final bool isFavorite;
  final String description;
  final List<ProductVariant> variants;

  ShirtModel({
    this.id = '',
    required this.name,
    this.colors,
    this.thumbnail,
    this.sizes,
    this.networkImage,
    required this.image,
    required this.price,
    required this.category,
    this.isFavorite = false,
    this.description = '',
    this.variants = const [],
  });

  // สร้าง ShirtModel จาก JSON
  factory ShirtModel.fromJson(Map<String, dynamic> json) {
    return ShirtModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      category: json['category'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
      description: json['description'] ?? '',
      variants: _parseVariants(json['variants'] ?? []),
      sizes: _parseSizes(json['sizes'] ?? []),
    );
  }

  // แปลง ShirtModel เป็น JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'category': category,
      'isFavorite': isFavorite,
      'description': description,
      'sizes': sizes,
    };
  }

  // แปลง sizes จาก JSON
  static List<String> _parseSizes(List<dynamic> sizes) {
    return sizes.map((size) => size.toString()).toList();
  }

  // แปลง variants จาก JSON
  static List<ProductVariant> _parseVariants(List<dynamic> variants) {
    return variants.map((variant) {
      return ProductVariant.fromJson(variant);
    }).toList();
  }
}