import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zafgoal/core/theme/app_colors.dart';
import 'package:zafgoal/features/auth/presentation/pages/splash_page.dart';
import 'package:zafgoal/providers/cart_provider.dart';
import 'package:zafgoal/providers/favorite_provider.dart';
import 'package:zafgoal/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bprmghdsxocgclgkxmay.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJwcm1naGRzeG9jZ2NsZ2t4bWF5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY1ODgyODYsImV4cCI6MjA5MjE2NDI4Nn0.OPJuSFttS-54RTE8qth9XH-DHcfvlC7IEyvp_USvkMc',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        // NAYA: lazy: false add kar diya hai taake app on hote hi listener start ho jaye
        ChangeNotifierProvider(create: (_) => NotificationProvider(), lazy: false),
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
      home: const SplashPage(),
    );
  }
}