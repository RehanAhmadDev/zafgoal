import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Agar in imports par red line aaye, toh unhein apne naye folder path k mutabiq update kar lijiye ga
import 'package:zafgoal/core/theme/app_colors.dart';
import 'package:zafgoal/shared/widgets/custom_text_field.dart';
import 'package:zafgoal/shared/widgets/primary_button.dart';

class SendNotificationPage extends StatefulWidget {
  const SendNotificationPage({super.key});

  @override
  State<SendNotificationPage> createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // --- Sab Users Ko Notification Bhejne Ka Logic ---
  Future<void> _sendNotificationToAll() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title aur Message dono likhna zaroori hain!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // 1. Tamam users ko profiles table se mangwayein
      final users = await supabase.from('profiles').select('id');

      if (users.isEmpty) {
        throw Exception('Koi user nahi mila.');
      }

      // 2. Har user k liye notification data tayar karein
      List<Map<String, dynamic>> notificationsToInsert = [];
      for (var user in users) {
        notificationsToInsert.add({
          'user_id': user['id'],
          'title': title,
          'subtitle': message,
          'details': 'Sent by Admin Promo',
          'icon_name': 'campaign', // Megaphone jaisa icon batane k liye
        });
      }

      // 3. Aik hi dafa mein sab insert kar dein (Batch Insert)
      await supabase.from('notifications').insert(notificationsToInsert);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sab users ko notification bhej di gayi hai! 🚀'), backgroundColor: Colors.green),
        );

        // Form clear kar dein
        _titleController.clear();
        _messageController.clear();
      }
    } catch (e) {
      debugPrint('Notification Send Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        title: const Text('Send Broadcast', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryDark.withOpacity(0.3)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.campaign_outlined, size: 50, color: AppColors.primaryDark),
                  SizedBox(height: 10),
                  Text(
                    'Announce Offers & Updates',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Yeh message application k tamam registered users ko foran pohanch jayega.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Form Area
            _buildLabel('Notification Title'),
            CustomTextField(
              controller: _titleController,
              hintText: 'e.g., Weekend Sale Alert!',
            ),

            const SizedBox(height: 20),

            _buildLabel('Message Details'),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'e.g., Get flat 20% off on all fresh fruits this weekend...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5)),
              ),
            ),

            const SizedBox(height: 40),

            // Send Button
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
                : PrimaryButton(
              text: 'Broadcast Message Now',
              onPressed: _sendNotificationToAll,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ),
    );
  }
}