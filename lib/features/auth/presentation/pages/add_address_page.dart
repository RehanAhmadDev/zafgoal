import 'package:flutter/material.dart';
import 'package:zafgoal/core/theme/app_colors.dart';
import 'package:zafgoal/shared/widgets/custom_text_field.dart';
import 'package:zafgoal/shared/widgets/primary_button.dart';

class AddAddressPage extends StatelessWidget {
  const AddAddressPage({super.key});

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
            // Mock Map Area (Premium Touch)
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
                  const CustomTextField(hintText: 'Home'),

                  const SizedBox(height: 16),
                  _buildLabel('Full Name'),
                  const CustomTextField(hintText: 'Jane Doe'),

                  const SizedBox(height: 16),
                  _buildLabel('Phone Number'),
                  const CustomTextField(hintText: '+92 3XX XXXXXXX'),

                  const SizedBox(height: 16),
                  _buildLabel('Street Address'),
                  const CustomTextField(hintText: 'Street 4, Sector I-8'),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('City'),
                            const CustomTextField(hintText: 'Islamabad'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Zip Code'),
                            const CustomTextField(hintText: '44000'),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  PrimaryButton(
                    text: 'Save Address',
                    onPressed: () {
                      // Yahan address save hone ka logic aayega
                      Navigator.pop(context);
                    },
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