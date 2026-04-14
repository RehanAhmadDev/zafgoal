import 'package:flutter/material.dart';
import 'package:zafgoal/core/theme/app_colors.dart';
import 'package:zafgoal/core/constants/app_assets.dart';
import 'package:zafgoal/shared/widgets/primary_button.dart';
import 'sign_up_form_page.dart'; // Sign Up Form page ko import kiya

class ChooseAccountPage extends StatefulWidget {
  const ChooseAccountPage({super.key});

  @override
  State<ChooseAccountPage> createState() => _ChooseAccountPageState();
}

class _ChooseAccountPageState extends State<ChooseAccountPage> {
  // User ne kya select kiya? (Default hum 'Staff' rakh rahe hain)
  String selectedType = 'Staff';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Logo (Figma size adjustment)
              Image.asset(
                AppAssets.logo,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 80, color: AppColors.primaryDark),
              ),

              const SizedBox(height: 30),

              const Text(
                'Choose Your Account Type',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select how you want to experience Zaf Goal',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 40),

              // 1. Staff Card
              GestureDetector(
                onTap: () => setState(() => selectedType = 'Staff'),
                child: _buildAccountCard(
                  title: 'Staff',
                  subtitle: 'Explore amazing destinations and book unique experiences',
                  iconPath: Icons.person_search_outlined,
                  isSelected: selectedType == 'Staff',
                ),
              ),

              const SizedBox(height: 20),

              // 2. Admin Card
              GestureDetector(
                onTap: () => setState(() => selectedType = 'Admin'),
                child: _buildAccountCard(
                  title: 'Admin',
                  subtitle: 'Share your expertise, showcase your city, and lead tours',
                  iconPath: Icons.admin_panel_settings_outlined,
                  isSelected: selectedType == 'Admin',
                ),
              ),

              const SizedBox(height: 40),

              // Continue Button
              PrimaryButton(
                text: 'Continue',
                onPressed: () {
                  // Aglay page (Sign Up Form) par jane ke liye
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpFormPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Back to Login
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Already have an account? Sign In',
                  style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Card banane wala helper method
  Widget _buildAccountCard({
    required String title,
    required String subtitle,
    required IconData iconPath,
    required bool isSelected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        // Selection par border color change hoga
        border: Border.all(
          color: isSelected ? AppColors.primaryDark : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isSelected ? 0.08 : 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryDark.withOpacity(0.1) : AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
                iconPath,
                size: 40,
                color: isSelected ? AppColors.primaryDark : Colors.grey
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}