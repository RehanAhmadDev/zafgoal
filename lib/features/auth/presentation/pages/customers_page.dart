import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zafgoal/core/theme/app_colors.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  bool _isLoading = true;
  List<dynamic> _customers = [];

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  // --- Profiles Table se Users fetch karna ---
  Future<void> _fetchCustomers() async {
    setState(() => _isLoading = true);
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .order('full_name', ascending: true);

      setState(() {
        _customers = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Customers Fetch Error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: const Text('Registered Customers', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
          : _customers.isEmpty
          ? const Center(child: Text('Koi customer registered nahi hai.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _customers.length,
        itemBuilder: (context, index) {
          final user = _customers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryDark.withOpacity(0.1),
                child: Text(user['full_name']?[0].toUpperCase() ?? 'U',
                    style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
              ),
              title: Text(user['full_name'] ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(user['phone_number'] ?? 'No phone'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: user['role'] == 'Admin' ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  user['role'] ?? 'User',
                  style: TextStyle(
                    color: user['role'] == 'Admin' ? Colors.red : Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}