import 'package:flutter/material.dart';
import 'package:zafgoal/core/theme/app_colors.dart';
import 'package:zafgoal/shared/widgets/primary_button.dart';
import 'package:zafgoal/shared/widgets/custom_text_field.dart';
import 'checkout_page.dart'; // Checkout import karein

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Cart', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          _buildNotificationBell(),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar (As per Cart.png)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: CustomTextField(
              hintText: 'Search',
              suffixIcon: Icon(Icons.search, color: Colors.grey),
            ),
          ),

          // 2. Horizontal Stepper
          _buildStepper(),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Clear all', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          // 3. Cart Items List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildCartItem('Mr.Cheezy', '£3.2', '5', 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=200'),
                _buildCartItem('Fries M', '£3.2', '3', 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=200'),
                _buildCartItem('Vanilla Ice', '£3.2', '4', 'https://images.unsplash.com/photo-1501443762994-82bd5dace89a?w=200'),
                _buildCartItem('Americano L', '£3.2', '10', 'https://images.unsplash.com/photo-1541167760496-162955ed8a9f?w=200'),
              ],
            ),
          ),

          // 4. Checkout Summary Container
          _buildSummaryCard(context),
        ],
      ),
    );
  }

  // --- Notification Bell with Dot ---
  Widget _buildNotificationBell() {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.notifications_none_outlined, color: Colors.black),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Container(height: 8, width: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
          )
        ],
      ),
    );
  }

  // --- Stepper Widget ---
  Widget _buildStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepCircle("1", "My Order", true),
          _stepLine(),
          _stepCircle("2", "Details", false),
          _stepLine(),
          _stepCircle("3", "Payment", false),
        ],
      ),
    );
  }

  Widget _stepCircle(String number, String label, bool isActive) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isActive ? Colors.white : Colors.black.withOpacity(0.05),
          child: Text(number, style: TextStyle(color: isActive ? Colors.black : Colors.grey)),
        ),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? Colors.black : Colors.grey)),
      ],
    );
  }

  Widget _stepLine() {
    return Container(width: 50, height: 1, color: Colors.black12, margin: const EdgeInsets.only(bottom: 20));
  }

  // --- Cart Item Card ---
  Widget _buildCartItem(String name, String price, String qty, String imgUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(imgUrl, width: 70, height: 70, fit: BoxFit.cover),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(price, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Row(
            children: [
              _qtyBtn(Icons.remove),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(qty, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              _qtyBtn(Icons.add, isDark: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, {bool isDark = false}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF233933) : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12),
      ),
      child: Icon(icon, size: 18, color: isDark ? Colors.white : Colors.black),
    );
  }

  // --- Summary Card ---
  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          _summaryRow('Sub Total :', '125£'),
          _summaryRow('Delivery Charges :', '0£'),
          _summaryRow('Discount :', '5%'),
          const Divider(),
          _summaryRow('Total :', '105£', isTotal: true),
          const SizedBox(height: 20),
          PrimaryButton(
              text: 'Proceed to Checkout',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CheckoutPage()),
                );
              }
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 14)),
        ],
      ),
    );
  }
}