import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zafgoal/providers/cart_provider.dart';
import 'package:zafgoal/shared/widgets/primary_button.dart';

import 'add_address_page.dart';
import 'add_payment_card_page.dart';
// Note: Humay yahan address_book_page.dart import karni hogi jab hum wo banayenge
// import 'address_book_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isLoading = false;

  // --- NAYA LOGIC: Address store karne k liye variables ---
  Map<String, dynamic>? _selectedAddress;
  bool _isLoadingAddress = true;

  @override
  void initState() {
    super.initState();
    _fetchDefaultAddress();
  }

  // --- NAYA LOGIC: Supabase se Address mangwana ---
  Future<void> _fetchDefaultAddress() async {
    setState(() => _isLoadingAddress = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // User ka pehla address utha kar lao
        final data = await Supabase.instance.client
            .from('addresses')
            .select()
            .eq('user_id', user.id)
            .limit(1);

        if (mounted) {
          setState(() {
            if (data.isNotEmpty) {
              _selectedAddress = data.first;
            }
            _isLoadingAddress = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching address: $e');
      if (mounted) setState(() => _isLoadingAddress = false);
    }
  }

  // --- UPDATE: Order Save karne k logic may Address shamil kiya ---
  Future<void> _placeOrder(BuildContext context, CartProvider cart) async {
    // Validation: Agar address nahi hai to order mat lagao
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a delivery address first'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception('Please login to place order');
      }

      final itemsList = cart.items.map((item) => {
        'id': item.id,
        'name': item.name,
        'price': item.price,
        'quantity': item.quantity,
      }).toList();

      // Database mein order ki entry daalna (Sath may address bhi)
      await Supabase.instance.client.from('orders').insert({
        'user_id': user.id,
        'total_amount': '£${cart.totalAmount.toStringAsFixed(2)}',
        'items': itemsList,
        'delivery_address': _selectedAddress!['full_address'], // NAYA: Address order k sath save hoga
        'status': 'pending'
      });

      if (mounted) {
        cart.clearCart();
        setState(() => _isLoading = false);
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
      barrierDismissible: false,
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

            // --- UPDATE: Yahan Address section ko zinda (dynamic) kiya hai ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('Address'),
                if (_selectedAddress != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: TextButton(
                      onPressed: () {
                        // TODO: Yahan Address Book page khulega
                      },
                      child: const Text('Change', style: TextStyle(color: Color(0xFF233933))),
                    ),
                  )
              ],
            ),
            _buildAddressCard(context),

            _buildSectionHeader('Delivery Method'),
            _buildDeliveryMethod(),
            _buildSectionHeader('Payment Method'),
            _buildPaymentMethod(context),
            const SizedBox(height: 30),
            _buildBottomSummary(context, cart),
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

  // --- UPDATE: UI ko live data se jor diya ---
  Widget _buildAddressCard(BuildContext context) {
    if (_isLoadingAddress) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF233933)));
    }

    if (_selectedAddress == null) {
      return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddAddressPage())).then((_) {
            _fetchDefaultAddress(); // Wapas ane par naya address fetch karega
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid)),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_location_alt_outlined, color: Colors.grey),
              SizedBox(width: 10),
              Text('Add Delivery Address', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: Colors.green),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_selectedAddress!['title'] ?? 'Address', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(_selectedAddress!['full_address'] ?? 'No detail provided', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
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
          _summaryRow('Order Total :', '£${cart.totalAmount.toStringAsFixed(2)}'),
          _summaryRow('Delivery :', '£0.00'),
          const Divider(),
          _summaryRow('Grand Total :', '£${cart.totalAmount.toStringAsFixed(2)}', isTotal: true),
          const SizedBox(height: 20),

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