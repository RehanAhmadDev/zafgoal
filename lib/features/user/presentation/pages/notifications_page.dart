import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Apne provider ka rasta check kar lein agar red line aaye
import 'package:zafgoal/providers/notification_provider.dart';

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
        title: const Text('Notifications',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notiProvider, child) {
          // 1. Agar data load ho raha ho
          if (notiProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF233933)));
          }

          // 2. Agar koi notification na ho
          if (notiProvider.notifications.isEmpty) {
            return _buildEmptyState();
          }

          // 3. Asli data ki list
          return RefreshIndicator(
            onRefresh: () => notiProvider.fetchNotifications(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: notiProvider.notifications.length,
              itemBuilder: (context, index) {
                final note = notiProvider.notifications[index];

                return _buildNotificationItem(
                  icon: Icons.notifications_active_outlined, // Aap db se bhi icon le sakte hain
                  title: note['title'] ?? 'Notification',
                  subtitle: note['subtitle'] ?? '',
                  time: 'Just now', // Isay format kiya ja sakta hai
                  details: note['details'],
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Khali screen ka design
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          const Text('No notifications yet',
              style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Aap ka banaya hua original design (Same to Same)
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
            decoration: const BoxDecoration(color: Color(0xFFF5F5F5), shape: BoxShape.circle),
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