import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  // Image Picker Variables
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // 1. Gallery se tasveer uthane wala function
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // 2. Data aur Tasveer dono Supabase bhejne wala function
  Future<void> _addCategory() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String imageUrl = '';

      // Agar user ne tasveer select ki hai toh pehle usay Bucket mein upload karein
      if (_selectedImage != null) {
        // Tasveer ka unique naam banate hain waqt ke hisab se
        final fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';

        // 'category_images' bucket mein tasveer upload kar rahay hain
        await Supabase.instance.client.storage
            .from('category_images')
            .upload(fileName, _selectedImage!);

        // Upload hone ke baad us tasveer ka Public Link (URL) hasil kar rahay hain
        imageUrl = Supabase.instance.client.storage
            .from('category_images')
            .getPublicUrl(fileName);
      }

      // Ab tasveer ka link aur category ka naam Database table mein save karein
      await Supabase.instance.client.from('categories').insert({
        'name': _nameController.text.trim(),
        'img': imageUrl, // Ab yahan khali string ki jagah asli link jayega!
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category with Image Added! ✅')),
      );

      // Form ko wapas khali kar dein
      setState(() {
        _nameController.clear();
        _selectedImage = null;
      });

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- Image Upload UI ---
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: _selectedImage != null
                    ? ClipOval(
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 30, color: Colors.grey),
                    SizedBox(height: 5),
                    Text('Upload', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- Category Name TextField ---
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name (e.g., Electronics)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 30),

            // --- Save Button ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Button ka color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                    'Save Category',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}