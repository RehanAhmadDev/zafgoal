import 'package:flutter/material.dart';
import 'package:zafgoal/core/theme/app_colors.dart';
import 'package:zafgoal/features/auth/presentation/pages/sign_in_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zaf Goal',
      debugShowCheckedModeBanner: false, // Right side se "Debug" tag hatane ke liye
      theme: ThemeData(
        // Puri app ka default background aur theme yahan set ho rahi hai
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryDark),
        useMaterial3: true,
      ),
      // App start hote hi SignInPage dikhao
      home: const SignInPage(),
    );
  }
}