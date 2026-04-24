import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // NAYA: Formatting k liye zaroori hai
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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  String _displayCardNumber = '**** **** **** ****';
  String _displayCardHolder = 'JOHN DOE';
  String _displayExpiry = 'MM/YY';

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {
        _displayCardHolder = _nameController.text.isEmpty ? 'JOHN DOE' : _nameController.text.toUpperCase();
      });
    });

    _numberController.addListener(() {
      setState(() {
        _displayCardNumber = _numberController.text.isEmpty ? '**** **** **** ****' : _numberController.text;
      });
    });

    _expiryController.addListener(() {
      setState(() {
        _displayExpiry = _expiryController.text.isEmpty ? 'MM/YY' : _expiryController.text;
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

  Future<void> _saveCard() async {
    // Basic Validation
    if (_numberController.text.length < 19) {
      _showError('Please enter a valid 16-digit card number');
      return;
    }
    if (_expiryController.text.length < 5) {
      _showError('Please enter a valid expiry date (MM/YY)');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await Supabase.instance.client.from('payment_cards').insert({
        'user_id': user.id,
        'card_holder': _nameController.text.trim(),
        'card_number': _numberController.text.trim(),
        'expiry_date': _expiryController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card Saved Successfully! 🎉'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showError('Error saving card: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Add New Card', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Live Virtual Card (Professional Design) ---
            Container(
              height: 200, width: double.infinity,
              margin: const EdgeInsets.all(20), padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Icon(Icons.credit_card, color: Colors.white, size: 30),
                    Text(_getCardType(_displayCardNumber), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                  ]),
                  Text(_displayCardNumber, style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2, fontFamily: 'Courier')),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    _cardInfoLabel('CARD HOLDER', _displayCardHolder),
                    _cardInfoLabel('EXPIRES', _displayExpiry),
                  ]),
                ],
              ),
            ),

            // --- Form Area ---
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Cardholder Name'),
                  CustomTextField(controller: _nameController, hintText: 'e.g. REHAN KHAN'),

                  const SizedBox(height: 16),
                  _buildLabel('Card Number'),
                  // Format: 1234 5678 1234 5678
                  TextField(
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                      CardNumberFormatter(),
                    ],
                    decoration: _inputDecoration('0000 0000 0000 0000'),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Expiry Date'),
                            TextField(
                              controller: _expiryController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                                CardMonthInputFormatter(),
                              ],
                              decoration: _inputDecoration('MM/YY'),
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
                            TextField(
                              controller: _cvvController,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              decoration: _inputDecoration('123'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _isLoading ? const Center(child: CircularProgressIndicator()) : PrimaryButton(text: 'Save Card', onPressed: _saveCard),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Methods ---
  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint, filled: true, fillColor: Colors.grey.shade100,
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  );

  Widget _cardInfoLabel(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
  ]);

  String _getCardType(String number) {
    if (number.startsWith('4')) return 'VISA';
    if (number.startsWith('5')) return 'MASTER';
    return 'CARD';
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8.0, left: 4.0), child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)));
}

// --- Professional Formatters ---

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonSpaceLength = i + 1;
      if (nonSpaceLength % 4 == 0 && nonSpaceLength != text.length) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}

class CardMonthInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var newText = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      var nonSpaceLength = i + 1;
      if (nonSpaceLength % 2 == 0 && nonSpaceLength != newText.length) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}