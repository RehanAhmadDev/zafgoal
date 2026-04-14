import 'package:flutter/material.dart';
import 'package:zafgoal/core/theme/app_colors.dart';


import 'features/auth/presentation/pages/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zaf Goal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryDark),
        useMaterial3: true,
      ),
      // --- CRITICAL FIX: Ensure this is SplashPage ---
      home: const SplashPage(),
    );
  }
}