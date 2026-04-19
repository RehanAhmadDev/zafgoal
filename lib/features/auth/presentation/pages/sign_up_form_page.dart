import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zafgoal/core/theme/app_colors.dart';
import 'package:zafgoal/core/constants/app_assets.dart';
import 'package:zafgoal/shared/widgets/custom_text_field.dart';
import 'package:zafgoal/shared/widgets/primary_button.dart';

import 'home_page.dart';
import 'sign_in_page.dart';

class SignUpFormPage extends StatefulWidget {
  // Pichlay page se aane wala Account Type (Admin ya Staff)
  final String accountType;

  const SignUpFormPage({super.key, this.accountType = 'Staff'});

  @override
  State<SignUpFormPage> createState() => _SignUpFormPageState();
}

class _SignUpFormPageState extends State<SignUpFormPage> {
  // 1. Text Controllers data read karne k liye
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // 2. Supabase Signup Logic
  Future<void> _signUpWithSupabase() async {
    // Agar koi field khali hai to error show karo
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      // A. Supabase Authentication may user create karna
      final AuthResponse res = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = res.user;

      if (user != null) {
        // B. Database ki 'profiles' table may extra data save karna
        await supabase.from('profiles').insert({
          'id': user.id, // Auth user ka ID yahan primary key banay ga
          'full_name': _nameController.text.trim(),
          'phone_number': _phoneController.text.trim(),
          'role': widget.accountType,
          // Note: dob column humne DB may nahi banaya tha, agar zaroorat hui toh baad may SQL may add kar lengay.
        });

        // C. Kamyabi k baad Home Page par le jao
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
          );
        }
      }
    } on AuthException catch (e) {
      // Supabase ka apna error (jaise email already exists)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      // Koi aur error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                    CustomTextField(hintText: 'Rehan Ahmad', controller: _nameController),
                    const SizedBox(height: 16),

                    _buildLabel('Email Address'),
                    CustomTextField(hintText: 'example@gmail.com', controller: _emailController),
                    const SizedBox(height: 16),

                    _buildLabel('Date of Birth'),
                    CustomTextField(hintText: 'DD/MM/YYYY', controller: _dobController),
                    const SizedBox(height: 16),

                    _buildLabel('Phone Number'),
                    CustomTextField(hintText: '+92 3XX XXXXXXX', controller: _phoneController),
                    const SizedBox(height: 16),

                    _buildLabel('Password'),
                    CustomTextField(hintText: 'Enter Password', isPassword: true, controller: _passwordController),
                    const SizedBox(height: 30),

                    // 3. Loading state check
                    _isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
                        : PrimaryButton(
                      text: 'Sign Up',
                      onPressed: _signUpWithSupabase,
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