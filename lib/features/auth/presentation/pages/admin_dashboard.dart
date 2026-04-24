import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zafgoal/core/theme/app_colors.dart';

// Import for SignInPage to handle logout routing
import 'package:zafgoal/features/auth/presentation/pages/sign_in_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  // --- NAYA LOGIC: Admin Logout ---
  Future<void> _signOut() async {
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
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: _signOut,
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
                  _buildDashboardCard(
                    context,
                    'Manage Products',
                    Icons.inventory_2_outlined,
                    Colors.blue,
                  ),
                  _buildDashboardCard(
                    context,
                    'Manage Orders',
                    Icons.shopping_bag_outlined,
                    Colors.orange,
                  ),
                  _buildDashboardCard(
                    context,
                    'Manage Banners',
                    Icons.view_carousel_outlined,
                    Colors.purple,
                  ),
                  _buildDashboardCard(
                    context,
                    'Customers',
                    Icons.people_outline,
                    Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Widget: Dashboard Card ---
  Widget _buildDashboardCard(BuildContext context, String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        // Abhi sirf Snackbar dikhayega, baad may yahan se navigation hogi
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title section coming soon!'),
              backgroundColor: AppColors.primaryDark,
              duration: const Duration(seconds: 1),
            )
        );
      },
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