import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Privacy Policy', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 25),
            _buildPolicySection(
              '1. Information We Collect',
              'Hum aap ka naam, email, phone number, aur delivery address collect karte hain taake aap ke orders sahi jagah pohanch sakein. Is k ilawa app k behtar experience k liye hum device information bhi collect karte hain.',
            ),
            _buildPolicySection(
              '2. How We Use Information',
              'Aap ka data orders process karne, payments handle karne, aur aap ko latest offers aur updates bhenjne k liye istemal kiya jata hai.',
            ),
            _buildPolicySection(
              '3. Data Security',
              'Hum aap k data ki hifazat k liye encryption aur secure servers (Supabase) istemal karte hain. Aap ka password hamesha encrypted form mein save hota hai.',
            ),
            _buildPolicySection(
              '4. Third-Party Services',
              'Hum payments k liye secure gateways aur delivery k liye trusted partners istemal karte hain. Un k sath sirf zaroori data share kiya jata hai.',
            ),
            _buildPolicySection(
              '5. Your Rights',
              'Aap kisi bhi waqt apni profile update kar sakte hain ya apna account delete karne ki request kar sakte hain.',
            ),
            const SizedBox(height: 30),
            _buildContactFooter(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF233933).withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        children: [
          Icon(Icons.security, color: Color(0xFF233933), size: 40),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Privacy Matters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF233933))),
                Text('Last updated: April 2026', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildContactFooter() {
    return Center(
      child: Column(
        children: [
          const Text('Need help regarding your data?', style: TextStyle(color: Colors.grey, fontSize: 13)),
          TextButton(
            onPressed: () {}, // Future: Open email client
            child: const Text('support@zafgoal.com', style: TextStyle(color: Color(0xFF233933), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}