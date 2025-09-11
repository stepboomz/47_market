import 'package:brand_store_app/models/shirt_model.dart';
import 'dart:math';

class Shirt {
  static List<ShirtModel> shirts = [
    ShirtModel(
        name: "Premium Tangerine Shirt",
        colors: ["Red", "Blue", "Green"],
        category: "men",
        sizes: ["S", "M", "L", "XL", "XXL"],
        image: "assets/images/shirts/tagerine_shirt.png",
        price: 258.75),
    ShirtModel(
        name: "Navy Tangerine Shirt",
        colors: ["Red", "Blue", "Green"],
        category: "men",
        sizes: ["S", "M", "L", "XL", "XXL"],
        image: "assets/images/shirts/tagerine_shirt2.png",
        price: 307.55),
    ShirtModel(
        name: "Tangerine Coat",
        colors: ["Red", "Blue", "Green"],
        sizes: ["S", "M", "L", "XL", "XXL"],
        category: "men",
        image: "assets/images/shirts/tagerine_coat.png",
        price: 380.55),
    ShirtModel(
        name: "Leather Coat",
        colors: ["Red", "Blue", "Green"],
        category: "men",
        sizes: ["S", "M", "L", "XL", "XXL"],
        image: "assets/images/shirts/leather_coat.png",
        price: 258.75),
  ];
  static List<ShirtModel> beauty = [
    ShirtModel(
      name: "Essence Mascara Lash Princess",
      colors: ["Red", "Blue", "Green"],
      category: "beauty",
      sizes: ["S", "M", "L", "XL", "XXL"],
      image:
          "https://cdn.dummyjson.com/products/images/beauty/Essence%20Mascara%20Lash%20Princess/1.png",
      price: 9.99,
      networkImage: true,
    ),
    ShirtModel(
      name: "Eyeshadow Palette with Mirror",
      colors: ["Red", "Blue", "Green"],
      category: "beauty",
      sizes: ["S", "M", "L", "XL", "XXL"],
      image:
          "https://cdn.dummyjson.com/products/images/beauty/Eyeshadow%20Palette%20with%20Mirror/1.png",
      price: 19.99,
      networkImage: true,
    ),
    ShirtModel(
      name: "Powder Canister",
      colors: ["Red", "Blue", "Green"],
      category: "beauty",
      sizes: ["S", "M", "L", "XL", "XXL"],
      image:
          "https://cdn.dummyjson.com/products/images/beauty/Powder%20Canister/1.png",
      price: 14.99,
      networkImage: true,
    ),
    ShirtModel(
      name: "Red Lipstick",
      colors: ["Red", "Blue", "Green"],
      category: "beauty",
      sizes: ["S", "M", "L", "XL", "XXL"],
      image:
          "https://cdn.dummyjson.com/products/images/beauty/Red%20Lipstick/1.png",
      price: 12.99,
      networkImage: true,
    ),
    ShirtModel(
      name: "Red Nail Polish",
      colors: ["Red", "Blue", "Green"],
      category: "beauty",
      sizes: ["S", "M", "L", "XL", "XXL"],
      image:
          "https://cdn.dummyjson.com/products/images/beauty/Red%20Nail%20Polish/1.png",
      price: 8.99,
      networkImage: true,
    ),
  ];
  static List<ShirtModel> menShirts = [
    ShirtModel(
      name: "Blue & Black Check Shirt",
      colors: ["Red", "Blue", "Green"],
      category: "men",
      sizes: ["S", "M", "L", "XL", "XXL"],
      image:
          "https://cdn.dummyjson.com/products/images/mens-shirts/Blue%20&%20Black%20Check%20Shirt/1.png",
      price: 29.99,
      networkImage: true,
    ),
    ShirtModel(
      name: "Gigabyte Aorus Men Tshirt",
      colors: ["Red", "Blue", "Green"],
      category: "men",
      sizes: ["S", "M", "L", "XL", "XXL"],
      image:
          "https://cdn.dummyjson.com/products/images/mens-shirts/Gigabyte%20Aorus%20Men%20Tshirt/1.png",
      price: 24.99,
      networkImage: true,
    ),
    ShirtModel(
      name: "Man Plaid Shirt",
      colors: ["Red", "Blue", "Green"],
      category: "men",
      sizes: ["S", "M", "L", "XL", "XXL"],
      image:
          "https://cdn.dummyjson.com/products/images/mens-shirts/Man%20Plaid%20Shirt/1.png",
      price: 34.99,
      networkImage: true,
    ),
    ShirtModel(
      name: "Man Short Sleeve Shirt",
      colors: ["Red", "Blue", "Green"],
      category: "men",
      sizes: ["S", "M", "L", "XL", "XXL"],
      image:
          "https://cdn.dummyjson.com/products/images/mens-shirts/Man%20Short%20Sleeve%20Shirt/1.png",
      price: 19.99,
      networkImage: true,
    ),
    ShirtModel(
      name: "Men Check Shirt",
      colors: ["Red", "Blue", "Green"],
      category: "men",
      sizes: ["S", "M", "L", "XL", "XXL"],
      image:
          "https://cdn.dummyjson.com/products/images/mens-shirts/Men%20Check%20Shirt/1.png",
      price: 27.99,
      networkImage: true,
    ),
  ];
  static List<ShirtModel> womenDresses = [
    ShirtModel(
      name: "Black Women's Gown",
      colors: ["Red", "Blue", "Green"],
      category: "women",
      sizes: ["S", "M", "L", "XL", "XXL"],
      thumbnail:
          "https://cdn.dummyjson.com/products/images/womens-dresses/Black%20Women's%20Gown/thumbnail.png",
      image:
          "https://cdn.dummyjson.com/products/images/womens-dresses/Black%20Women's%20Gown/1.png",
      price: 129.99,
      networkImage: true,
    ),
    ShirtModel(
      name: "Corset Leather With Skirt",
      colors: ["Red", "Blue", "Green"],
      category: "women",
      sizes: ["S", "M", "L", "XL", "XXL"],
      thumbnail:
          "https://cdn.dummyjson.com/products/images/womens-dresses/Corset%20Leather%20With%20Skirt/thumbnail.png",
      image:
          "https://cdn.dummyjson.com/products/images/womens-dresses/Corset%20Leather%20With%20Skirt/1.png",
      price: 89.99,
      networkImage: true,
    ),
    ShirtModel(
      name: "Corset With Black Skirt",
      colors: ["Red", "Blue", "Green"],
      category: "women",
      sizes: ["S", "M", "L", "XL", "XXL"],
      thumbnail:
          "https://cdn.dummyjson.com/products/images/womens-dresses/Corset%20With%20Black%20Skirt/thumbnail.png",
      image:
          "https://cdn.dummyjson.com/products/images/womens-dresses/Corset%20With%20Black%20Skirt/1.png",
      price: 79.99,
      networkImage: true,
    ),
    ShirtModel(
      name: "Dress Pea",
      colors: ["Red", "Blue", "Green"],
      category: "women",
      sizes: ["S", "M", "L", "XL", "XXL"],
      image:
          "https://cdn.dummyjson.com/products/images/womens-dresses/Dress%20Pea/1.png",
      price: 49.99,
      networkImage: true,
    ),
    ShirtModel(
      name: "Marni Red & Black Suit",
      colors: ["Red", "Blue", "Green"],
      category: "women",
      sizes: ["S", "M", "L", "XL", "XXL"],
      image:
          "https://cdn.dummyjson.com/products/images/womens-dresses/Marni%20Red%20&%20Black%20Suit/1.png",
      price: 179.99,
      networkImage: true,
    ),
  ];

  static List<ShirtModel> allItems() =>
      [...shirts, ...beauty, ...menShirts, ...womenDresses]..shuffle(Random());
}
