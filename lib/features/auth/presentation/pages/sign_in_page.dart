import 'package:flutter/material.dart';
import 'package:zafgoal/core/theme/app_colors.dart';
import 'package:zafgoal/core/constants/app_assets.dart';
import 'package:zafgoal/shared/widgets/custom_text_field.dart';
import 'package:zafgoal/shared/widgets/primary_button.dart';

// 1. Nayi file yahan import kardi
import 'forgot_password_page.dart';
import 'choose_account_page.dart';
import 'home_page.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset(
                AppAssets.logo,
                height: 194,
                width: 259,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    size: 100,
                    color: AppColors.primaryDark
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Sign in now',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 30),
                    const CustomTextField(hintText: 'Email or Username'),
                    const SizedBox(height: 16),
                    const CustomTextField(hintText: 'Password', isPassword: true),
                    const SizedBox(height: 12),

                    // 2. Yahan GestureDetector laga diya gaya hai
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                          );
                        },
                        child: const Text(
                          'Forget Password?',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline, // Clickable feel dene k liye
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    PrimaryButton(
                        text: 'Sign In',
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const HomePage()),
                                (route) => false,
                          );
                        }
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?", style: TextStyle(color: AppColors.textPrimary)),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ChooseAccountPage()),
                            );
                          },
                          child: const Text(
                              'Sign up',
                              style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('Or Continue With', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialIcon(Icons.facebook, Colors.blue),
                        const SizedBox(width: 20),
                        _buildGoogleIcon(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 30),
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      height: 54,
      width: 54,
      decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
      child: const Center(
        child: Text('G', style: TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    );
  }
}