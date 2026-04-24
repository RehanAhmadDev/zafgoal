import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zafgoal/core/theme/app_colors.dart';
import 'package:zafgoal/shared/widgets/custom_text_field.dart';
import 'package:zafgoal/shared/widgets/primary_button.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _featuresController = TextEditingController(); // Comma separated features

  String? _selectedCategory;
  File? _imageFile;
  bool _isLoading = false;

  final List<String> _categories = ['Fruits', 'Vegetables', 'Dairy', 'Bakery', 'Meat'];

  // --- 1. Gallery se Image select karna ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // --- 2. Product Save karne ka logic ---
  Future<void> _saveProduct() async {
    // Basic Validation
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _imageFile == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meharbani karke tamam khali jaghen bhar dein aur tasweer lagayen'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // A. Image Upload karna (Storage mein)
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imagePath = 'products/$fileName';

      await supabase.storage.from('product_images').upload(imagePath, _imageFile!);

      // B. Public URL hasil karna
      final String imageUrl = supabase.storage.from('product_images').getPublicUrl(imagePath);

      // C. Features ko list mein tabdeel karna (Comma separated se array mein)
      List<String> featuresList = _featuresController.text.split(',').map((e) => e.trim()).toList();

      // D. Database (Table) mein data dalna
      await supabase.from('products').insert({
        'name': _nameController.text.trim(),
        'price': '£${_priceController.text.trim()}', // Pound symbol k sath
        'img': imageUrl,
        'category': _selectedCategory,
        'description': _descController.text.trim(),
        'features': featuresList,
      });

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product successfully add ho gaya hai!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Wapas jao aur list refresh karo
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: const Text('Add New Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            // Image Picker UI
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(_imageFile!, fit: BoxFit.cover),
                  )
                      : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text('Product ki tasweer select karein', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            _buildLabel('Product Name'),
            CustomTextField(controller: _nameController, hintText: 'e.g. Fresh Apples'),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Price (£)'),
                      CustomTextField(controller: _priceController, hintText: '1.99', keyboardType: TextInputType.number),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Category'),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                        onChanged: (val) => setState(() => _selectedCategory = val),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildLabel('Description'),
            // --- UPDATED: CustomTextField ki jagah standard TextField use kiya hai ---
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Product ki detail likhen...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              ),
            ),

            const SizedBox(height: 16),
            _buildLabel('Key Features (Comma separated)'),
            CustomTextField(controller: _featuresController, hintText: 'Fresh, Organic, Local'),

            const SizedBox(height: 35),

            _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
                : PrimaryButton(text: 'Save Product', onPressed: _saveProduct),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
    );
  }
}