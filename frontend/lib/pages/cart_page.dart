import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cart',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF0796DE),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 20),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: Color(0xFF919191),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Add medicines to get started',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                color: Color(0xFF919191),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
