import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'add_payment_card_page.dart';
import 'my_orders_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _fullName = 'Loading...';
  String _email = 'Loading...';
  String? _avatarUrl; // Tasweer k URL k liye naya variable
  bool _isLoading = true;
  bool _isUploading = false; // Uploading k dauran ghoomne wala chakra dikhane k liye

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // --- Supabase se User Data aur Picture Uthana ---
  Future<void> _fetchUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final email = user.email ?? 'No Email';

        final data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        if (mounted) {
          setState(() {
            _email = email;
            _fullName = data['full_name'] ?? 'User';
            _avatarUrl = data['avatar_url']; // Tasweer ka URL database se liya
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      if (mounted) {
        setState(() {
          _fullName = 'Guest User';
          _email = 'Not logged in';
          _isLoading = false;
        });
      }
    }
  }

  // --- NAYA LOGIC: Gallery se image select aur Supabase pe Upload ---
  Future<void> _uploadProfilePicture() async {
    try {
      final picker = ImagePicker();
      final imageFile = await picker.pickImage(source: ImageSource.gallery);

      if (imageFile == null) return; // User ne cancel kar diya

      setState(() => _isUploading = true);

      final file = File(imageFile.path);
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) throw Exception('User not logged in');

      // File ka naam user ki ID k hisab se set karna taake replace karna asan ho
      final fileExtension = imageFile.path.split('.').last;
      final fileName = '${user.id}.$fileExtension';

      // 1. Storage bucket 'avatars' may upload karna
      await Supabase.instance.client.storage
          .from('avatars') // Bucket ka naam 'avatars' hona zaroori hai
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      // 2. Upload hone k baad uska public link hasil karna
      final String publicUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      // 3. Database k 'profiles' table may naya link save karna
      await Supabase.instance.client
          .from('profiles')
          .update({'avatar_url': publicUrl})
          .eq('id', user.id);

      if (mounted) {
        setState(() {
          _avatarUrl = publicUrl; // Screen par nayi tasweer dikhane k liye
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update picture.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- Logout Karna ---
  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

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
        title: const Text('Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF233933)))
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildSettingsSection(context),
            const SizedBox(height: 30),
            _buildLogoutButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        GestureDetector(
          // Tasweer par click hone pe gallery khulegi
          onTap: _isUploading ? null : _uploadProfilePicture,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                child: _avatarUrl == null
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
              // Agar tasweer upload ho rahi hai toh loader dikhao
              if (_isUploading)
                const Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF233933)),
                  ),
                ),
              // Camera wala chota icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF233933),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Text(
          _fullName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          _email,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildSettingsTile(Icons.person_outline, 'My Account'),
          _buildSettingsTile(Icons.notifications_none_outlined, 'Notifications',
              onTap: () {
                // Notification page navigation
              }
          ),
          _buildSettingsTile(
              Icons.shopping_bag_outlined,
              'My Orders',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyOrdersPage()),
                );
              }
          ),
          _buildSettingsTile(Icons.location_on_outlined, 'Address Book'),
          _buildSettingsTile(
              Icons.payment_outlined,
              'Payment Methods',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPaymentCardPage()),
                );
              }
          ),
          _buildSettingsTile(Icons.security_outlined, 'Privacy Policy'),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF233933), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextButton(
        onPressed: _signOut,
        style: TextButton.styleFrom(
          foregroundColor: Colors.red,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout),
            SizedBox(width: 10),
            Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}