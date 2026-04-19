import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase package
import 'package:zafgoal/core/theme/app_colors.dart';
import 'package:zafgoal/features/auth/presentation/pages/splash_page.dart';

void main() async {
  // 1. Flutter Engine ko initialize karna zaroori hai
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Supabase Connection Setup
  await Supabase.initialize(
    // Aapke dashboard se nikala gaya URL
    url: 'https://bprmghdsxocgclgkxmay.supabase.co',

    // Aapne jo lambi key di hai (Anon Key)
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJwcm1naGRzeG9jZ2NsZ2t4bWF5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY1ODgyODYsImV4cCI6MjA5MjE2NDI4Nn0.OPJuSFttS-54RTE8qth9XH-DHcfvlC7IEyvp_USvkMc',
  );

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
        fontFamily: 'Poppins',
      ),
      // App hamesha SplashPage se shuru hogi
      home: const SplashPage(),
    );
  }
}