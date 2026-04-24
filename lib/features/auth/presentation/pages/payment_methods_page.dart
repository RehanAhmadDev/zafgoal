import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zafgoal/core/theme/app_colors.dart';
import 'add_payment_card_page.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _cards = [];

  @override
  void initState() {
    super.initState();
    _fetchCards();
  }

  // --- Supabase se Saved Cards mangwane ka logic ---
  Future<void> _fetchCards() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final data = await Supabase.instance.client
          .from('payment_cards')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _cards = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('My Cards',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF233933)))
          : _cards.isEmpty
          ? _buildEmptyState()
          : _buildCardsList(),

      // --- Naya Card add karne ka button ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPaymentCardPage())
        ).then((_) => _fetchCards()), // Wapas aane par list refresh ho jaye
        backgroundColor: const Color(0xFF233933),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add New Card', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCardsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _cards.length,
      itemBuilder: (context, index) {
        final card = _cards[index];

        // Card Number ko format karna (Sirf last 4 digits)
        String rawNumber = card['card_number'].toString().replaceAll(' ', '');
        String last4 = rawNumber.length >= 4
            ? rawNumber.substring(rawNumber.length - 4)
            : '****';

        return Container(
          // Ghalat: margin: const EdgeInsets.bottom(15),
// Sahi:
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            onTap: () {
              // Selection logic: Checkout page par wapas le jayega
              Navigator.pop(context, card);
            },
            leading: _getCardIcon(rawNumber),
            title: Text('**** **** **** $last4',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)),
            subtitle: Text(card['card_holder']?.toUpperCase() ?? 'NAME NOT FOUND',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _getCardIcon(String number) {
    IconData iconData = Icons.credit_card;
    Color iconColor = Colors.blue;

    if (number.startsWith('4')) {
      iconData = Icons.payment; // Visa style
      iconColor = Colors.indigo;
    } else if (number.startsWith('5')) {
      iconData = Icons.credit_card_rounded; // Master style
      iconColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_card_off_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          const Text('No cards saved yet',
              style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Add a card to make payment faster.',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}