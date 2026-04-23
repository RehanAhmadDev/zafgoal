import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zafgoal/core/theme/app_colors.dart';
import 'package:zafgoal/shared/widgets/custom_text_field.dart';
import 'package:zafgoal/shared/widgets/primary_button.dart';

class AddPaymentCardPage extends StatefulWidget {
  const AddPaymentCardPage({super.key});

  @override
  State<AddPaymentCardPage> createState() => _AddPaymentCardPageState();
}

class _AddPaymentCardPageState extends State<AddPaymentCardPage> {
  bool _isLoading = false;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  // Live Card par dikhane k liye variables
  String _displayCardNumber = '**** **** **** 1234';
  String _displayCardHolder = 'JOHN DOE';
  String _displayExpiry = '12/28';

  @override
  void initState() {
    super.initState();
    // Live UI update karne k liye Listeners lagaye hain
    _nameController.addListener(() {
      setState(() {
        _displayCardHolder = _nameController.text.isEmpty ? 'JOHN DOE' : _nameController.text.toUpperCase();
      });
    });

    _numberController.addListener(() {
      setState(() {
        _displayCardNumber = _numberController.text.isEmpty ? '**** **** **** 1234' : _numberController.text;
      });
    });

    _expiryController.addListener(() {
      setState(() {
        _displayExpiry = _expiryController.text.isEmpty ? '12/28' : _expiryController.text;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  // --- Supabase may Card Save karne ka Logic ---
  Future<void> _saveCard() async {
    if (_nameController.text.trim().isEmpty ||
        _numberController.text.trim().isEmpty ||
        _expiryController.text.trim().isEmpty ||
        _cvvController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all card details'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Database may insert karna
      await Supabase.instance.client.from('payment_cards').insert({
        'user_id': user.id,
        'card_holder': _nameController.text.trim(),
        'card_number': _numberController.text.trim(),
        'expiry_date': _expiryController.text.trim(),
        // Note: Real world may CVV save nahi karte
      });

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card Saved Successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Wapas bhej do
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving card: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add New Card',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Live Virtual Card ---
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.contactless, color: Colors.white, size: 30),
                      Text('VISA', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                    ],
                  ),
                  Text(
                    _displayCardNumber, // Live Variable
                    style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Card Holder', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          Text(_displayCardHolder, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)), // Live Variable
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Expires', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          Text(_displayExpiry, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)), // Live Variable
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- Form Area ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Cardholder Name'),
                  CustomTextField(
                    controller: _nameController,
                    hintText: 'John Doe',
                  ),

                  const SizedBox(height: 16),
                  _buildLabel('Card Number'),
                  CustomTextField(
                    controller: _numberController,
                    hintText: '0000 0000 0000 0000',
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Expiry Date'),
                            CustomTextField(
                              controller: _expiryController,
                              hintText: 'MM/YY',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('CVV'),
                            CustomTextField(
                              controller: _cvvController,
                              hintText: '123',
                              isPassword: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
                      : PrimaryButton(
                    text: 'Save Card',
                    onPressed: _saveCard,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}