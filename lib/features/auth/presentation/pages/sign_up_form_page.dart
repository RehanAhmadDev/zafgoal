import 'package:flutter/material.dart';
import 'package:zafgoal/core/theme/app_colors.dart';
import 'package:zafgoal/core/constants/app_assets.dart';
import 'package:zafgoal/shared/widgets/custom_text_field.dart';
import 'package:zafgoal/shared/widgets/primary_button.dart';

import 'home_page.dart';
import 'sign_in_page.dart';

class SignUpFormPage extends StatelessWidget {
  const SignUpFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Image.asset(
                AppAssets.logo,
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 80, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: Text('Signup now', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                    const SizedBox(height: 25),
                    _buildLabel('Full Name'),
                    const CustomTextField(hintText: 'Rehan Ahmad'),
                    const SizedBox(height: 16),
                    _buildLabel('Email Address'),
                    const CustomTextField(hintText: 'example@gmail.com'),
                    const SizedBox(height: 16),
                    _buildLabel('Date of Birth'),
                    const CustomTextField(hintText: 'DD/MM/YYYY'),
                    const SizedBox(height: 16),
                    _buildLabel('Phone Number'),
                    const CustomTextField(hintText: '+92 3XX XXXXXXX'),
                    const SizedBox(height: 16),
                    _buildLabel('Password'),
                    const CustomTextField(hintText: 'Enter Password', isPassword: true),
                    const SizedBox(height: 30),
                    PrimaryButton(
                        text: 'Sign Up',
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const HomePage()),
                                (route) => false,
                          );
                        }
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? ", style: TextStyle(color: AppColors.textPrimary)),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const SignInPage()),
                                  (route) => false,
                            );
                          },
                          child: const Text('Sign in', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    );
  }
}