import 'package:flutter/material.dart';
import 'package:zafgoal/core/theme/app_colors.dart';
import 'package:zafgoal/core/constants/app_assets.dart';
import 'package:zafgoal/shared/widgets/custom_text_field.dart';
import 'package:zafgoal/shared/widgets/primary_button.dart';
import 'choose_account_page.dart'; // Aglay page ka import

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          // Screen choti ho to design scrollable rahay ga
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Figma dimensions k mutabiq bara Logo
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

              // White Card Container
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
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Email Field
                    const CustomTextField(hintText: 'Email or Username'),
                    const SizedBox(height: 16),

                    // Password Field (Ab ye clickable Eye icon k sath hai)
                    const CustomTextField(
                      hintText: 'Password',
                      isPassword: true,
                    ),
                    const SizedBox(height: 12),

                    // Forget Password
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Forget Password?',
                        style: TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign In Button
                    PrimaryButton(
                        text: 'Sign In',
                        onPressed: () {
                          // Login logic yahan ayegi
                        }
                    ),

                    const SizedBox(height: 20),

                    // Sign Up Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                            "Don't have an account?",
                            style: TextStyle(color: AppColors.textPrimary)
                        ),
                        TextButton(
                          onPressed: () {
                            // Choose Account Type screen par jane k liye
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ChooseAccountPage()
                              ),
                            );
                          },
                          child: const Text(
                              'Sign up',
                              style: TextStyle(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.bold
                              )
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    const Text(
                        'Or Continue With',
                        style: TextStyle(color: Colors.grey, fontSize: 12)
                    ),
                    const SizedBox(height: 15),

                    // Social Icons Row
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

  // Social Icon Helper
  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }

  // Google Icon Helper (Custom Text)
  Widget _buildGoogleIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      height: 54,
      width: 54,
      decoration: const BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Colors.red,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}