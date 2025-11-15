import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class iPadFrame extends StatelessWidget {
  final Widget child;

  const iPadFrame({
    super.key,
    required this.child,
  });

  static bool isDesktop() {
    if (!kIsWeb) return false;
    // Check if screen width is larger than tablet size (typically > 768px)
    return true; // We'll check in build method with MediaQuery
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      // Not web, return child directly
      return child;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    
    // Check if it's desktop (wider than 1024px)
    final isDesktop = screenWidth > 1024;

    if (!isDesktop) {
      // Mobile/tablet view, return child directly
      return child;
    }

    // Desktop view - show iPad frame
    // iPad dimensions: 768x1024 (portrait) or 1024x768 (landscape)
    // We'll use portrait orientation
    const double iPadWidth = 568;
    const double iPadHeight = 1024;
    const double bezelWidth = 22;
    const double cornerRadius = 50;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF5F5F7), // Light grey background (iPad-like)
      child: Center(
        child: Container(
          width: iPadWidth + (bezelWidth * 2),
          height: iPadHeight + (bezelWidth * 2),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(cornerRadius + bezelWidth),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 40,
                spreadRadius: 5,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Bezel
              Padding(
                padding: EdgeInsets.all(bezelWidth),
                child: Container(
                  width: iPadWidth,
                  height: iPadHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(cornerRadius),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: child,
                ),
              ),
              // Home indicator (at bottom)
              Positioned(
                bottom: bezelWidth + 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 134,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

