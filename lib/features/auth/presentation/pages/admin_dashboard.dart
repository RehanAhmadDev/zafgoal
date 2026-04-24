import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zafgoal/core/theme/app_colors.dart';

// --- IMPORTS ---
import 'package:zafgoal/features/auth/presentation/pages/sign_in_page.dart';
import 'manage_products_page.dart';
import 'manage_banners_page.dart'; // NAYA IMPORT: Banners page k liye

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  // --- Admin Logout Logic ---
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
                  // 1. Manage Products Card
                  _buildDashboardCard(
                      context,
                      'Manage Products',
                      Icons.inventory_2_outlined,
                      Colors.blue,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ManageProductsPage()),
                        );
                      }
                  ),

                  // 2. Manage Orders Card
                  _buildDashboardCard(
                      context,
                      'Manage Orders',
                      Icons.shopping_bag_outlined,
                      Colors.orange,
                          () {
                        _showComingSoonMessage('Manage Orders');
                      }
                  ),

                  // 3. Manage Banners Card (AB ACTIVE HAI)
                  _buildDashboardCard(
                      context,
                      'Manage Banners',
                      Icons.view_carousel_outlined,
                      Colors.purple,
                          () {
                        // NAYA LOGIC: Navigation to Manage Banners Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ManageBannersPage()),
                        );
                      }
                  ),

                  // 4. Customers Card
                  _buildDashboardCard(
                      context,
                      'Customers',
                      Icons.people_outline,
                      Colors.green,
                          () {
                        _showComingSoonMessage('Customers');
                      }
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonMessage(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$title section coming soon!'),
          backgroundColor: AppColors.primaryDark,
          duration: const Duration(seconds: 1),
        )
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