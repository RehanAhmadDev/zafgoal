import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // NAYA IMPORT: Input Formatters k liye
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zafgoal/core/theme/app_colors.dart';
import 'package:zafgoal/core/constants/app_assets.dart';
import 'package:zafgoal/shared/widgets/custom_text_field.dart';
import 'package:zafgoal/shared/widgets/primary_button.dart';

import 'home_page.dart';
import 'sign_in_page.dart';

class SignUpFormPage extends StatefulWidget {
  final String accountType;

  const SignUpFormPage({super.key, this.accountType = 'Staff'});

  @override
  State<SignUpFormPage> createState() => _SignUpFormPageState();
}

class _SignUpFormPageState extends State<SignUpFormPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedGender;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryDark,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _signUpWithSupabase() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    // Phone number ki choti si validation (optional magar achi hoti hai)
    if (_phoneController.text.isNotEmpty && _phoneController.text.length < 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 11-digit phone number')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      final AuthResponse res = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = res.user;

      if (user != null) {
        await supabase.from('profiles').insert({
          'id': user.id,
          'full_name': _nameController.text.trim(),
          'phone_number': _phoneController.text.trim(),
          'role': widget.accountType,
          'dob': _dobController.text.isEmpty ? null : _dobController.text,
          'gender': _selectedGender,
        });

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
          );
        }
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
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

                    _buildLabel('Full Name *'),
                    CustomTextField(hintText: 'Rehan Ahmad', controller: _nameController),
                    const SizedBox(height: 16),

                    _buildLabel('Email Address *'),
                    CustomTextField(hintText: 'example@gmail.com', controller: _emailController),
                    const SizedBox(height: 16),

                    // --- UPDATE: Phone Number Restrictions ---
                    _buildLabel('Phone Number'),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone, // Keyboard main sirf numbers ayenge
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // ABC likhna block ho jayega
                        LengthLimitingTextInputFormatter(11), // Sirf 11 numbers allow honge
                      ],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                        hintText: '03XX XXXXXXX',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        counterText: "", // Niche length counter (0/11) ko hide karne k liye
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Gender'),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      ),
                      hint: const Text('Select Gender', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      items: ['Male', 'Female', 'Other'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Date of Birth'),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: CustomTextField(
                          hintText: 'YYYY-MM-DD',
                          controller: _dobController,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Password *'),
                    CustomTextField(hintText: 'Enter Password', isPassword: true, controller: _passwordController),
                    const SizedBox(height: 30),

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