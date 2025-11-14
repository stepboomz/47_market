import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderNumber;
  final double totalAmount;
  const OrderSuccessScreen({super.key, required this.orderNumber, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Placed')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 96),
              const SizedBox(height: 16),
              Text('ขอบคุณสำหรับการสั่งซื้อ', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Order: $orderNumber', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('ยอดสุทธิ: ฿${totalAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                child: const Text('กลับหน้าหลัก'),
              )
            ],
          ),
        ),
      ),
    );
  }
}


