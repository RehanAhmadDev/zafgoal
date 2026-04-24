import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zafgoal/core/theme/app_colors.dart';
import 'package:zafgoal/core/constants/app_assets.dart';
import 'package:zafgoal/shared/widgets/custom_text_field.dart';
import 'package:zafgoal/shared/widgets/primary_button.dart';

import '../../../admin/presentation/pages/admin_dashboard.dart';
import 'forgot_password_page.dart';
import 'choose_account_page.dart';
import '../../../user/presentation/pages/home_page.dart';
// --- NAYA IMPORT: Admin Dashboard ke liye ---


class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // 1. Text Controllers data read karne k liye
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // 2. Supabase Sign In Logic with Role Checking
  Future<void> _signInWithSupabase() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      // Supabase se verify karwa rahe hain
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = res.user;

      if (user != null) {
        // --- NAYA LOGIC: Database se role check karo ---
        final data = await supabase
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .maybeSingle();

        if (mounted) {
          final role = data?['role'] ?? 'Staff';

          if (role == 'Admin') {
            // Agar Admin hai toh Admin Dashboard par le jao
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboard()),
                  (route) => false,
            );
          } else {
            // Warna aam Customer wale Home Page par le jao
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
            );
          }
        }
      }
    } on AuthException catch (e) {
      // Supabase ka error (jaise galat password)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login Failed: ${e.message}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

                    // Controllers attach kar diye hain
                    CustomTextField(hintText: 'Email or Username', controller: _emailController),
                    const SizedBox(height: 16),
                    CustomTextField(hintText: 'Password', isPassword: true, controller: _passwordController),
                    const SizedBox(height: 12),

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
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 3. Loading aur Sign In Button
                    _isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
                        : PrimaryButton(
                      text: 'Sign In',
                      onPressed: _signInWithSupabase,
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