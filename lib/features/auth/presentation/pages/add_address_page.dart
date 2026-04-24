import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Naya Import Formatter k liye
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zafgoal/core/theme/app_colors.dart';
import 'package:zafgoal/shared/widgets/custom_text_field.dart';
import 'package:zafgoal/shared/widgets/primary_button.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  bool _isLoading = false;

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

  // --- Supabase may Address Save karne ka Logic ---
  Future<void> _saveAddress() async {
    // 1. Validation: Check karein k koi bhi field khali to nahi
    if (_titleController.text.trim().isEmpty ||
        _nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _streetController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _zipController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meharbani karke tamam khali jaghen bhar dein'), backgroundColor: Colors.red),
      );
      return;
    }

    // 2. Validation: Phone number 11 digits ka hona chahiye
    if (_phoneController.text.trim().length < 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number 11 digits ka hona chahiye'), backgroundColor: Colors.red),
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

                  _buildLabel('Location Label (e.g. Home, Office)'),
                  CustomTextField(controller: _titleController, hintText: 'Home'),

                  const SizedBox(height: 16),
                  _buildLabel('Full Name'),
                  CustomTextField(controller: _nameController, hintText: 'Jane Doe'),

                  const SizedBox(height: 16),
                  _buildLabel('Phone Number'),
                  // --- Phone Number Field Update ---
                  CustomTextField(
                    controller: _phoneController,
                    hintText: '03XXXXXXXXX',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                  ),

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