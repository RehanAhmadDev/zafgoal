import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Naya Import
import 'package:zafgoal/core/theme/app_colors.dart';
import 'package:zafgoal/shared/widgets/custom_text_field.dart';
import 'package:zafgoal/shared/widgets/primary_button.dart';

// 1. Isay StatefulWidget may tabdeel kar diya taake Loading aur Data handle ho sakay
class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  bool _isLoading = false;

  // 2. Data uthane k liye Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  // --- 3. Supabase may Address Save karne ka Logic ---
  Future<void> _saveAddress() async {
    // Validation: Check karein k koi zaroori field khali to nahi
    if (_titleController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _streetController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Mukammal pata (Full Address) banane k liye fields ko jor diya
      final fullAddress = "${_nameController.text.trim()} - ${_streetController.text.trim()}, ${_cityController.text.trim()} ${_zipController.text.trim()}";

      // Database may insert karna
      await Supabase.instance.client.from('addresses').insert({
        'user_id': user.id,
        'title': _titleController.text.trim(),
        'full_address': fullAddress,
        'phone': _phoneController.text.trim(),
      });

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address Saved Successfully!'), backgroundColor: Colors.green),
        );
        // Address save hone k baad Checkout page par wapas bhej do
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving address: $e'), backgroundColor: Colors.red),
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
          'Add New Address',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mock Map Area
            Container(
              height: 150,
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: AppColors.primaryDark, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to pin location on Map',
                    style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            // Form Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Har CustomTextField may ab controller pass kiya gaya hai
                  _buildLabel('Location Label (e.g. Home, Office)'),
                  CustomTextField(controller: _titleController, hintText: 'Home'),

                  const SizedBox(height: 16),
                  _buildLabel('Full Name'),
                  CustomTextField(controller: _nameController, hintText: 'Jane Doe'),

                  const SizedBox(height: 16),
                  _buildLabel('Phone Number'),
                  CustomTextField(controller: _phoneController, hintText: '+92 3XX XXXXXXX'),

                  const SizedBox(height: 16),
                  _buildLabel('Street Address'),
                  CustomTextField(controller: _streetController, hintText: 'Street 4, Sector I-8'),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('City'),
                            CustomTextField(controller: _cityController, hintText: 'Islamabad'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Zip Code'),
                            CustomTextField(controller: _zipController, hintText: '44000'),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Save Button with Loading State
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
                      : PrimaryButton(
                    text: 'Save Address',
                    onPressed: _saveAddress,
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