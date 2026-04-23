import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zafgoal/providers/cart_provider.dart';
import 'package:zafgoal/shared/widgets/primary_button.dart';

import 'add_address_page.dart';
import 'add_payment_card_page.dart';
import 'address_book_page.dart';
import 'order_detail_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isLoading = false;

  Map<String, dynamic>? _selectedAddress;
  bool _isLoadingAddress = true;

  Map<String, dynamic>? _selectedCard;
  bool _isLoadingCard = true;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding use karne ki ab zarurat nahi, initState may seedha call karein
    _fetchDefaultAddress();
    _fetchDefaultCard();
  }

  // --- FIX: Sab se naya address fetch karne ka logic (No Red Line) ---
  Future<void> _fetchDefaultAddress() async {
    if (!mounted) return;
    setState(() => _isLoadingAddress = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from('addresses')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false) // Sahi Tareeqa: No curly braces
            .limit(1);

        if (mounted) {
          setState(() {
            _selectedAddress = data.isNotEmpty ? data.first : null;
            _isLoadingAddress = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Address Error: $e');
      if (mounted) setState(() => _isLoadingAddress = false);
    }
  }

  // --- FIX: Sab se naya card fetch karne ka logic (No Red Line) ---
  Future<void> _fetchDefaultCard() async {
    if (!mounted) return;
    setState(() => _isLoadingCard = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from('payment_cards')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false) // Sahi Tareeqa: No curly braces
            .limit(1);

        if (mounted) {
          setState(() {
            _selectedCard = data.isNotEmpty ? data.first : null;
            _isLoadingCard = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Card Error: $e');
      if (mounted) setState(() => _isLoadingCard = false);
    }
  }

  Future<void> _placeOrder(BuildContext context, CartProvider cart) async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a delivery address first'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a payment method first'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Please login to place order');

      final itemsList = cart.items.map((item) => {
        'id': item.id,
        'name': item.name,
        'price': item.price,
        'quantity': item.quantity,
      }).toList();

      final response = await Supabase.instance.client.from('orders').insert({
        'user_id': user.id,
        'total_amount': '£${cart.totalAmount.toStringAsFixed(2)}',
        'items': itemsList,
        'delivery_address': _selectedAddress!['full_address'],
        'status': 'pending'
      }).select().single();

      if (mounted) {
        String newOrderId = response['id'].toString();
        String displayId = newOrderId.length > 8 ? newOrderId.substring(0, 8).toUpperCase() : newOrderId.toUpperCase();

        cart.clearCart();
        setState(() => _isLoading = false);
        _showSuccessDialog(displayId, response['total_amount'].toString(), response['items']);
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

  void _showSuccessDialog(String orderId, String amount, List<dynamic> items) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 15),
            const Text('Order Successful!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Order #$orderId has been placed.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 25),
            const CircularProgressIndicator(color: Color(0xFF233933)),
            const SizedBox(height: 15),
            const Text('Redirecting to receipt...', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(
              orderId: orderId,
              date: "Just Now",
              amount: amount,
              status: "PENDING",
              statusColor: Colors.orange,
              items: items,
            ),
          ),
        );
      }
    });
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('Address'),
                if (_selectedAddress != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: TextButton(
                      onPressed: () async {
                        // Refresh logic after return
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddressBookPage()),
                        );
                        _fetchDefaultAddress();
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

  Widget _buildAddressCard(BuildContext context) {
    if (_isLoadingAddress) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF233933)));
    }

    if (_selectedAddress == null) {
      return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddAddressPage())).then((_) {
            _fetchDefaultAddress();
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
              const Text('Standard Delivery (Free)', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(BuildContext context) {
    if (_isLoadingCard) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF233933)));
    }

    if (_selectedCard == null) {
      return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPaymentCardPage())).then((_) {
            _fetchDefaultCard();
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid)),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_card, color: Colors.grey),
              SizedBox(width: 10),
              Text('Add Payment Method', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    String cardNumber = _selectedCard!['card_number'] ?? '';
    String last4 = cardNumber.length >= 4 ? cardNumber.substring(cardNumber.length - 4) : '****';

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPaymentCardPage())).then((_) {
          _fetchDefaultCard();
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.credit_card, color: Colors.blue),
                const SizedBox(width: 15),
                Text('Visa Card (.... $last4)', style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            const Icon(Icons.keyboard_arrow_right),
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