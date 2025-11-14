import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedPrice extends StatelessWidget {
  final String priceString; // Pass the price as a string

  const AnimatedPrice({super.key, required this.priceString});

  @override
  Widget build(BuildContext context) {
    // Convert the price string to double
    final targetPrice = double.tryParse(priceString) ?? 0.0;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.00, end: targetPrice),
      duration: const Duration(seconds: 1), // Adjust duration as needed
      builder: (context, value, child) {
        return Text(
          '฿${value.toStringAsFixed(0)}',
          // Format the value to 2 decimal places
          style: GoogleFonts.chakraPetch(
              fontSize: MediaQuery.textScalerOf(context).scale(30),
              fontWeight: FontWeight.bold),
        );
      },
    );
  }
}
