import 'package:brand_store_app/providers/favorite_provider.dart';
import 'package:brand_store_app/widgets/items_gridview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.inverseSurface,
        elevation: 0,
        forceMaterialTransparency: true,
        toolbarHeight: 100,
        leadingWidth: 100,
        primary: true,
        centerTitle: true,
        title: Text(
          "Favorite ",
          style: GoogleFonts.imprima(fontSize: 25),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const ImageIcon(
            size: 30,
            AssetImage("assets/icons/back_arrow.png"),
          ),
        ),
      ),
      body: favorites.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon(
                    //   Icons.favorite_border,
                    //   size: 80,
                    //   color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.3),
                    // ),
                    // const SizedBox(height: 20),
                    // Text(
                    //   "ยังไม่มีรายการโปรด",
                    //   style: GoogleFonts.imprima(
                    //     fontSize: 20,
                    //     color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.7),
                    //   ),
                    // ),
                    // const SizedBox(height: 10),
                    // Text(
                    //   "กดปุ่ม ❤️ ในหน้าสินค้าเพื่อเพิ่มรายการโปรด",
                    //   style: GoogleFonts.imprima(
                    //     fontSize: 14,
                    //     color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.5),
                    //   ),
                    //   textAlign: TextAlign.center,
                    // ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: false,
                ),
                child: ItemsGridview(
                  selectedItems: favorites,
                  tagPrefix: "favorites",
                ),
              ),
            ),
    );
  }
}
