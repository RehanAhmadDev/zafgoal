import 'package:flutter/material.dart';
import 'package:zafgoal/shared/widgets/primary_button.dart';
import 'package:zafgoal/shared/widgets/custom_text_field.dart';
import 'checkout_page.dart';

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
      ),
      body: Column(
        children: [
          // Search Bar
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: CustomTextField(
              hintText: 'Search',
              suffixIcon: Icon(Icons.search, color: Colors.grey),
            ),
          ),

          // --- FIX 1: Bulletproof Stepper ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Row(
              children: [
                _stepCircle("1", "My Order", true),
                Expanded(child: Container(height: 2, color: Colors.black12)), // Expanded se line kabhi bahar nahi jayegi
                _stepCircle("2", "Details", false),
                Expanded(child: Container(height: 2, color: Colors.black12)),
                _stepCircle("3", "Payment", false),
              ],
            ),
          ),

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

          // --- FIX 2: List View with Reliable Images ---
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildCartItem('Mr.Cheezy', '£3.2', '5', 'https://picsum.photos/100?random=1'),
                _buildCartItem('Fries M', '£3.2', '3', 'https://picsum.photos/100?random=2'),
                _buildCartItem('Vanilla Ice', '£3.2', '4', 'https://picsum.photos/100?random=3'),
                _buildCartItem('Americano L', '£3.2', '10', 'https://picsum.photos/100?random=4'),
              ],
            ),
          ),

          // Checkout Summary
          _buildSummaryCard(context),
        ],
      ),
    );
  }

  // --- Helper for Stepper ---
  Widget _stepCircle(String number, String label, bool isActive) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isActive ? const Color(0xFF233933) : Colors.black.withOpacity(0.05),
          child: Text(number, style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? Colors.black : Colors.grey)),
      ],
    );
  }

  // --- Helper for Cart Item with Fallback Icon ---
  Widget _buildCartItem(String name, String price, String qty, String imgUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              imgUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              // Agar net band ho to yeh chalega, error crash nahi hogi
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60, height: 60, color: Colors.grey.shade200,
                child: const Icon(Icons.fastfood, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                Text(price, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          // FIX: mainAxisSize min kiya taake buttons bahar na niklein
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _qtyBtn(Icons.remove),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
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
      child: Icon(icon, size: 16, color: isDark ? Colors.white : Colors.black),
    );
  }

  // --- Summary Card ---
  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _summaryRow('Sub Total :', '125£'),
          _summaryRow('Delivery Charges :', '0£'),
          _summaryRow('Discount :', '5%'),
          const Divider(),
          _summaryRow('Total :', '105£', isTotal: true),
          const SizedBox(height: 15),
          PrimaryButton(
            text: 'Proceed to Checkout',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutPage()));
            },
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
          Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}