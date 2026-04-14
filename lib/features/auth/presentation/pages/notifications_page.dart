import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Today', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _buildNotificationItem(
            icon: Icons.check_circle_outline,
            title: 'New Order Received!',
            subtitle: 'Order #ZA-9042 — £84.50',
            time: '9:24pm',
            details: 'Items: 12 (Groceries & Electronics) Delivery: Priority (1-Hour Slot) [View Order]',
          ),
          _buildNotificationItem(
            icon: Icons.refresh,
            title: 'POS / In-Store Purchase',
            subtitle: 'POS Transaction #9942 • £12.50',
            time: '12 mins',
            details: 'Station: Register 02 • Cashier: David',
          ),
          _buildNotificationItem(
            icon: Icons.local_shipping_outlined,
            title: 'High-Value Order',
            subtitle: '#12045 • £285.00',
            time: '5 mins',
            details: 'Customer: Emma Watson • 12 items Status: Payment Verified',
          ),
          _buildNotificationItem(
            icon: Icons.payment,
            title: 'Payment Successful',
            subtitle: 'Your payment was successful. Check your email for digital receipt.',
            time: '9:24pm',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    String? details,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 5),
                Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                if (details != null) ...[
                  const SizedBox(height: 5),
                  Text(details, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}