import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zafgoal/core/theme/app_colors.dart';

class ManageOrdersPage extends StatefulWidget {
  const ManageOrdersPage({super.key});

  @override
  State<ManageOrdersPage> createState() => _ManageOrdersPageState();
}

class _ManageOrdersPageState extends State<ManageOrdersPage> {
  bool _isLoading = true;
  List<dynamic> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // --- 1. Orders Fetch karna ---
  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final data = await Supabase.instance.client
          .from('orders')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _orders = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Orders Fetch Error: $e');
      setState(() => _isLoading = false);
    }
  }

  // --- 2. Order Status Update karna ---
  Future<void> _updateStatus(int orderId, String newStatus) async {
    try {
      await Supabase.instance.client
          .from('orders')
          .update({'status': newStatus})
          .eq('id', orderId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $newStatus'), backgroundColor: Colors.green),
      );
      _fetchOrders(); // List refresh karein
    } catch (e) {
      debugPrint('Status Update Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: const Text('Manage Orders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _fetchOrders)
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
          : _orders.isEmpty
          ? const Center(child: Text('Abhi tak koi order nahi aaya.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        title: Text('Order #${order['id']} - ${order['customer_name']}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Total: ${order['total_amount']} | Status: ${order['status']}'),
        leading: Icon(Icons.shopping_cart, color: _getStatusColor(order['status'])),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Text('Address: ${order['address']}', style: const TextStyle(fontSize: 14)),
                Text('Phone: ${order['phone']}', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 15),
                const Text('Update Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statusButton(order['id'], 'Pending', Colors.orange),
                    _statusButton(order['id'], 'Shipped', Colors.blue),
                    _statusButton(order['id'], 'Delivered', Colors.green),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _statusButton(int id, String status, Color color) {
    return ElevatedButton(
      onPressed: () => _updateStatus(id, status),
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
      child: Text(status),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'Shipped': return Colors.blue;
      case 'Delivered': return Colors.green;
      default: return Colors.grey;
    }
  }
}