import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase package
import 'package:provider/provider.dart'; // 1. Provider package import kiya
import 'package:zafgoal/core/theme/app_colors.dart';
import 'package:zafgoal/features/auth/presentation/pages/splash_page.dart';
import 'package:zafgoal/providers/cart_provider.dart'; // 2. Apna CartProvider import kiya

void main() async {
  // Flutter Engine ko initialize karna zaroori hai
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase Connection Setup
  await Supabase.initialize(
    url: 'https://bprmghdsxocgclgkxmay.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJwcm1naGRzeG9jZ2NsZ2t4bWF5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY1ODgyODYsImV4cCI6MjA5MjE2NDI4Nn0.OPJuSFttS-54RTE8qth9XH-DHcfvlC7IEyvp_USvkMc',
  );

  // 3. Poori app ko Provider k andar wrap kar diya
  runApp(
    MultiProvider(
      providers: [
        // Yahan hum apna CartProvider app ko de rahe hain
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
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