import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zafgoal/features/auth/presentation/pages/sign_in_page.dart';

// Import for HomePage
import 'admin_dashboard.dart';
import 'home_page.dart';
// --- NAYA IMPORT: Admin Dashboard ke liye ---
// Agar path thora mukhtalif ho toh isay adjust kar lijiye ga


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    _checkAuthSession();
  }

  // --- UPDATED LOGIC: Role based routing ---
  Future<void> _checkAuthSession() async {
    // 2.5 seconds ka delay taake user ko splash design nazar aaye
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // Supabase se current user session mangwana
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      try {
        // Database se check karein ke is user ka role kya hai
        final data = await Supabase.instance.client
            .from('profiles')
            .select('role')
            .eq('id', session.user.id)
            .maybeSingle();

        if (!mounted) return;

        // Agar role null hai toh default 'Staff' (Customer) samjhein
        final role = data?['role'] ?? 'Staff';

        if (role == 'Admin') {
          // Agar Admin hai toh Admin Dashboard par le jao
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboard()),
          );
        } else {
          // Warna aam Customer wale Home Page par le jao
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } catch (e) {
        debugPrint('Error checking role: $e');
        // Agar koi error aaye toh safe side par aam Home Page dikha do
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      }
    } else {
      // Agar login nahi hai -> Sign In Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Single Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. White Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.8),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // 3. Main Content Layer
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),

                // Logo Section
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 160,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported,
                        size: 160,
                        color: Colors.grey
                    ),
                  ),
                ),

                const Spacer(),

                // Text Section
                const Text(
                  'Welcome To',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF233933),
                  ),
                ),
                const Text(
                  'ZAFGOAL',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF233933),
                  ),
                ),

                const SizedBox(height: 15),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'The grocery store that thinks before you shop.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Auto-loading Indicator
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: SizedBox(
                    height: 60,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1B2E28),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}