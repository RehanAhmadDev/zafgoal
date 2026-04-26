import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zafgoal/core/theme/app_colors.dart';

// --- IMPORTS ---
import 'package:zafgoal/features/auth/presentation/pages/sign_in_page.dart';
// Yahan aap ki asli User Side ki screen import ho gayi hai
import 'package:zafgoal/features/user/presentation/pages/home_page.dart';

import 'manage_products_page.dart';
import 'manage_banners_page.dart';
import 'manage_orders_page.dart';
import 'customers_page.dart';
import 'send_notification_page.dart';
import 'manage_categories_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  // --- Admin Logout Logic with Confirmation ---
  Future<void> _signOut() async {
    // 1. Pehle Confirmation Dialog dikhayen
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          // No Button
          TextButton(
            onPressed: () => Navigator.pop(context, false), // False return karega
            child: const Text('No', style: TextStyle(color: Colors.grey)),
          ),
          // Yes Button
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // True return karega
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false; // Agar user dialog ke bahar click kare toh false ho jaye

    // 2. Agar user ne 'No' kar diya toh function yahin rok dein
    if (!confirm) return;

    // 3. Agar 'Yes' dabaya hai toh asal logout ka code chalayen
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        title: const Text(
            'Admin Dashboard',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        actions: [
          // --- LIVE PREVIEW BUTTON ---
          IconButton(
            icon: const Icon(Icons.remove_red_eye, color: Colors.white),
            tooltip: 'Live Preview (User Side)',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Yahan aap ki Asli User App (HomePage) chalegi
                  builder: (context) => const HomePage(),
                ),
              );
            },
          ),
          // --- LOGOUT BUTTON ---
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: _signOut, // Yahan ab naya dialog wala function call hoga
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Welcome, Admin!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
            ),
            const SizedBox(height: 8),
            const Text(
                'What would you like to manage today?',
                style: TextStyle(color: Colors.grey, fontSize: 14)
            ),
            const SizedBox(height: 35),

            // --- Admin Controls Grid ---
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildDashboardCard(context, 'Manage Products', Icons.inventory_2_outlined, Colors.blue, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageProductsPage()));
                  }),
                  _buildDashboardCard(context, 'Manage Orders', Icons.shopping_bag_outlined, Colors.orange, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageOrdersPage()));
                  }),
                  _buildDashboardCard(context, 'Manage Banners', Icons.view_carousel_outlined, Colors.purple, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageBannersPage()));
                  }),
                  _buildDashboardCard(context, 'Manage Categories', Icons.category_outlined, Colors.teal, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageCategoriesPage()));
                  }),
                  _buildDashboardCard(context, 'Customers', Icons.people_outline, Colors.green, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomersPage()));
                  }),
                  _buildDashboardCard(context, 'Send Broadcast', Icons.campaign_outlined, Colors.redAccent, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SendNotificationPage()));
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5)
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle
              ),
              child: Icon(icon, color: color, size: 38),
            ),
            const SizedBox(height: 16),
            Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                textAlign: TextAlign.center
            ),
          ],
        ),
      ),
    );
  }
}