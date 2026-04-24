import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zafgoal/core/theme/app_colors.dart';

import 'order_detail_page.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  bool _isLoading = true;
  List<dynamic> _orders = [];

  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _fetchMyOrders();
  }

  Future<void> _fetchMyOrders() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from('orders')
            .select('*')
            .eq('user_id', user.id)
            .order('created_at', ascending: false);

        if (mounted) {
          setState(() {
            _orders = data;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
            'My Orders',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
          : _orders.isEmpty
          ? const Center(child: Text('You have no orders yet.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];

          DateTime date = DateTime.parse(order['created_at']);
          String day = date.day.toString().padLeft(2, '0');
          String month = _months[date.month - 1];
          String year = date.year.toString();
          String formattedDate = '$day $month, $year';

          String status = order['status']?.toString().toLowerCase() ?? 'pending';
          Color statusColor;
          if (status == 'delivered' || status == 'completed') {
            statusColor = Colors.green;
          } else if (status == 'pending' || status == 'processing') {
            statusColor = Colors.orange;
          } else {
            statusColor = Colors.red;
          }

          // --- UPDATE: Order ID ko chota aur khubsoorat banaya ---
          String fullOrderId = order['id'].toString();
          String displayOrderId = fullOrderId.length > 8
              ? fullOrderId.substring(0, 8).toUpperCase()
              : fullOrderId.toUpperCase();

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailPage(
                    orderId: displayOrderId, // Chota ID aagay bheja
                    date: formattedDate,
                    amount: order['total_amount'].toString(),
                    status: status.toUpperCase(),
                    statusColor: statusColor,
                    items: order['items'] ?? [],
                  ),
                ),
              );
            },
            child: _buildOrderCard(
                displayOrderId, // Chota ID card may dikhaya
                formattedDate,
                order['total_amount'].toString(), // Database may pehle se £ mojood hai
                status.toUpperCase(),
                statusColor
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(String orderId, String date, String amount, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order #$orderId', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              // --- UPDATE: Yahan se izafi '£' hata diya hai ---
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}