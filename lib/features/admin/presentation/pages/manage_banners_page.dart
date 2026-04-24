import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zafgoal/core/theme/app_colors.dart';

class ManageBannersPage extends StatefulWidget {
  const ManageBannersPage({super.key});

  @override
  State<ManageBannersPage> createState() => _ManageBannersPageState();
}

class _ManageBannersPageState extends State<ManageBannersPage> {
  bool _isLoading = true;
  bool _isUploading = false;
  List<dynamic> _banners = [];

  @override
  void initState() {
    super.initState();
    _fetchBanners();
  }

  // --- 1. Saare Banners mangwana ---
  Future<void> _fetchBanners() async {
    setState(() => _isLoading = true);
    try {
      final data = await Supabase.instance.client
          .from('banners')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _banners = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  // --- 2. Naya Banner Upload karna ---
  Future<void> _uploadBanner() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final file = File(image.path);
      final fileName = 'banner_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // A. Image ko Storage mein upload karna (Make sure 'product_images' bucket exists or use 'banners')
      await Supabase.instance.client.storage
          .from('product_images') // Aap product_images bucket hi use kar sakte hain ya naya bana lein
          .upload('banners/$fileName', file);

      final imageUrl = Supabase.instance.client.storage
          .from('product_images')
          .getPublicUrl('banners/$fileName');

      // B. Database mein entry karna
      await Supabase.instance.client.from('banners').insert({
        'image_url': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banner upload ho gaya!'), backgroundColor: Colors.green),
      );
      _fetchBanners(); // List refresh karein
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // --- 3. Banner Delete karna ---
  Future<void> _deleteBanner(int id) async {
    try {
      await Supabase.instance.client.from('banners').delete().eq('id', id);
      _fetchBanners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banner delete kar diya gaya'), backgroundColor: Colors.orange),
      );
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: const Text('Manage Banners', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _uploadBanner,
        backgroundColor: AppColors.primaryDark,
        icon: _isUploading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.add_photo_alternate, color: Colors.white),
        label: Text(_isUploading ? 'Uploading...' : 'Add Banner', style: const TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
          : _banners.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1, // Full width banners
          childAspectRatio: 2.5,
          mainAxisSpacing: 16,
        ),
        itemCount: _banners.length,
        itemBuilder: (context, index) {
          final banner = _banners[index];
          return _buildBannerCard(banner);
        },
      ),
    );
  }

  Widget _buildBannerCard(dynamic banner) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
            image: DecorationImage(
              image: NetworkImage(banner['image_url']),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            backgroundColor: Colors.red.withOpacity(0.8),
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.white, size: 20),
              onPressed: () => _deleteBanner(banner['id']),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('Koi banner mojood nahi hai. Naya banner add karein!'),
    );
  }
}