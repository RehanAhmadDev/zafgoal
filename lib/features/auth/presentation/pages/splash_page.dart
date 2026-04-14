import 'package:flutter/material.dart';
import 'package:zafgoal/features/auth/presentation/pages/sign_in_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Single Background Image (Aapki splash_bg)
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_bg.png', // NOTE: Agar aapki image .png hai, toh isko .png kar lijiye ga
              fit: BoxFit.cover,
            ),
          ),

          // 2. White Gradient Overlay (Taake text clear nazar aaye)
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

                // Next Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const SignInPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B2E28),
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward, color: Colors.white),
                      ],
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