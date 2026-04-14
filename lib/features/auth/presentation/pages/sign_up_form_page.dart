import 'package:flutter/material.dart';
import 'package:zafgoal/core/theme/app_colors.dart';
import 'package:zafgoal/core/constants/app_assets.dart';
import 'package:zafgoal/shared/widgets/custom_text_field.dart';
import 'package:zafgoal/shared/widgets/primary_button.dart';
import 'sign_in_page.dart'; // Sign In page import taake wapas ja saken

class SignUpFormPage extends StatelessWidget {
  const SignUpFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        // Screen scrollable banane ke liye singleChildScrollView zaroori hai
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Figma dimensions k mutabiq bara Logo (194x259)
              Image.asset(
                AppAssets.logo,
                height: 150, // Form fit karne k liye height adjust ki hai
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 80, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 20),

              // White Card Container (Main Form)
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Labels left par karne k liye
                  children: [
                    const Center(
                      child: Text(
                        'Signup now',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // --- Full Name ---
                    _buildLabel('Full Name'),
                    const CustomTextField(hintText: 'Rehan Ahmad'), // Reusable Widget
                    const SizedBox(height: 16),

                    // --- Email Address ---
                    _buildLabel('Email Address'),
                    const CustomTextField(hintText: 'example@gmail.com'),
                    const SizedBox(height: 16),

                    // --- Date of Birth ---
                    _buildLabel('Date of Birth'),
                    const CustomTextField(hintText: 'DD/MM/YYYY'),
                    const SizedBox(height: 16),

                    // --- Phone Number ---
                    _buildLabel('Phone Number'),
                    const CustomTextField(hintText: '+92 3XX XXXXXXX'),
                    const SizedBox(height: 16),

                    // --- Password ---
                    _buildLabel('Password'),
                    const CustomTextField(
                      hintText: 'Enter Password',
                      isPassword: true, // Clickable eye feature on ho jayega
                    ),

                    const SizedBox(height: 30),

                    // --- Sign Up Button ---
                    PrimaryButton(
                        text: 'Sign Up',
                        onPressed: () {
                          // User creation logic will come here
                        }
                    ),

                    const SizedBox(height: 15),

                    // --- Back to Login Text ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? ", style: TextStyle(color: AppColors.textPrimary)),
                        GestureDetector(
                          onTap: () {
                            // Wapas Sign In Page par jane k liye
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const SignInPage()),
                                  (route) => false, // Purani saari screens remove kar do
                            );
                          },
                          child: const Text(
                              'Sign in',
                              style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)
                          ),
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

  // Label banane wala chota sa helper method (taake code clean rahay)
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