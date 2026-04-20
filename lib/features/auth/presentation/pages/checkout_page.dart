import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zafgoal/providers/cart_provider.dart';
import 'package:zafgoal/shared/widgets/primary_button.dart';

import 'add_address_page.dart';
import 'add_payment_card_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isLoading = false;

  // --- NAYA LOGIC: Supabase mein Order Save karna ---
  Future<void> _placeOrder(BuildContext context, CartProvider cart) async {
    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception('Please login to place order');
      }

      // Cart items ko aisi shakal mein lana jo Database mein save ho sakay (JSON)
      final itemsList = cart.items.map((item) => {
        'id': item.id,
        'name': item.name,
        'price': item.price,
        'quantity': item.quantity,
      }).toList();

      // Database mein order ki entry daalna
      await Supabase.instance.client.from('orders').insert({
        'user_id': user.id,
        'total_amount': '£${cart.totalAmount.toStringAsFixed(2)}',
        'items': itemsList,
        'status': 'pending'
      });

      // Agar order successfully lag gaya, toh:
      if (mounted) {
        // 1. Cart Khali karo
        cart.clearCart();

        // 2. Loading hatao
        setState(() => _isLoading = false);

        // 3. User ko Success ka Dialog dikhao
        _showSuccessDialog();
      }

    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User bahar click kar ke band nahi kar sakta
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Order Successful!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Your order has been placed successfully and is being processed.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Dialog band karein aur wapas Home par le jayen (2 dafa pop)
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF233933)),
              child: const Text('Back to Home', style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Provider se cart ka data mangwana
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Checkout', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepper(),
            _buildSectionHeader('Address'),
            _buildAddressCard(context),
            _buildSectionHeader('Delivery Method'),
            _buildDeliveryMethod(),
            _buildSectionHeader('Payment Method'),
            _buildPaymentMethod(context),
            const SizedBox(height: 30),
            _buildBottomSummary(context, cart), // Cart pass kar diya
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepCircle("1", "My Order", true, isCompleted: true),
          _stepLine(true),
          _stepCircle("2", "Details", true),
          _stepLine(false),
          _stepCircle("3", "Payment", false),
        ],
      ),
    );
  }

  Widget _stepCircle(String number, String label, bool isActive, {bool isCompleted = false}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isActive ? const Color(0xFF233933) : Colors.black.withOpacity(0.05),
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : Text(number, style: TextStyle(color: isActive ? Colors.white : Colors.grey)),
        ),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? Colors.black : Colors.grey)),
      ],
    );
  }

  Widget _stepLine(bool isFinished) {
    return Container(width: 50, height: 2, color: isFinished ? const Color(0xFF233933) : Colors.black12, margin: const EdgeInsets.only(bottom: 20));
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: Colors.green),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Home Address', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Main Street, I-8 Islamabad', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddAddressPage()));
              }
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryMethod() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping_outlined, color: Colors.orange),
              SizedBox(width: 15),
              Text('Standard Delivery (Free)', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPaymentCardPage()));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.credit_card, color: Colors.blue),
                SizedBox(width: 15),
                Text('Visa Card (.... 4242)', style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            Icon(Icons.keyboard_arrow_right),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummary(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Live Provider Total
          _summaryRow('Order Total :', '£${cart.totalAmount.toStringAsFixed(2)}'),
          _summaryRow('Delivery :', '£0.00'),
          const Divider(),
          _summaryRow('Grand Total :', '£${cart.totalAmount.toStringAsFixed(2)}', isTotal: true),
          const SizedBox(height: 20),

          // Agar order lag raha hai toh loading dikhao
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF233933)))
              : PrimaryButton(
            text: 'Confirm Order',
            onPressed: () => _placeOrder(context, cart),
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