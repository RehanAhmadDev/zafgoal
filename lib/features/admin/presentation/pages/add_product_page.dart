import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zafgoal/core/theme/app_colors.dart';
import 'package:zafgoal/shared/widgets/custom_text_field.dart';
import 'package:zafgoal/shared/widgets/primary_button.dart';

class AddProductPage extends StatefulWidget {
  final dynamic product;
  const AddProductPage({super.key, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _featuresController = TextEditingController();

  String? _selectedCategory;
  File? _imageFile;
  String? _existingImageUrl;
  bool _isLoading = false;

  // --- UPDATE 1: Categories ki list database k mutabiq kar di ---
  final List<String> _categories = [
    'Fresh Fruits',
    'Daily Dairy',
    'Vegetables',
    'Bakery',
    'Meat'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product['name'] ?? '';
      _priceController.text = widget.product['price']?.toString().replaceAll('£', '') ?? '';
      _descController.text = widget.product['description'] ?? '';
      _existingImageUrl = widget.product['img'];

      // --- UPDATE 2: Dropdown Crash Protection Logic ---
      String dbCategory = widget.product['category']?.toString() ?? '';
      if (dbCategory.isNotEmpty) {
        // Agar DB wali category list mein nahi hai (jaise spelling ka farq), to crash se bachne k liye add kar do
        if (!_categories.contains(dbCategory)) {
          _categories.add(dbCategory);
        }
        _selectedCategory = dbCategory;
      }

      // Safe Features Parsing
      var fetchedFeatures = widget.product['features'];
      if (fetchedFeatures != null) {
        if (fetchedFeatures is List) {
          _featuresController.text = fetchedFeatures.join(', ');
        } else {
          _featuresController.text = fetchedFeatures.toString();
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _saveProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zaroori khali jaghen bhar dein'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      String? imageUrl = _existingImageUrl;

      if (_imageFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final imagePath = 'products/$fileName';
        await supabase.storage.from('product_images').upload(imagePath, _imageFile!);
        imageUrl = supabase.storage.from('product_images').getPublicUrl(imagePath);
      }

      List<String> featuresList = _featuresController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      final productData = {
        'name': _nameController.text.trim(),
        'price': '£${_priceController.text.trim()}',
        'img': imageUrl,
        'category': _selectedCategory,
        'description': _descController.text.trim(),
        'features': featuresList,
        'created_at': widget.product == null ? DateTime.now().toIso8601String() : widget.product['created_at'],
      };

      if (widget.product == null) {
        await supabase.from('products').insert(productData);
      } else {
        await supabase
            .from('products')
            .update(productData)
            .eq('id', widget.product['id'])
            .select();
      }

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null ? 'Product Add ho gayi!' : 'Product Update ho gayi!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Update error: $e');
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
        elevation: 0,
        title: Text(widget.product == null ? 'Add New Product' : 'Edit Product',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180, width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.file(_imageFile!, fit: BoxFit.cover))
                      : (_existingImageUrl != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(_existingImageUrl!, fit: BoxFit.cover))
                      : const Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey)),
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
                          filled: true, fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                        ),
                        // .toList() se pehle unique set bana liya taake duplication na ho
                        items: _categories.toSet().map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                        onChanged: (val) => setState(() => _selectedCategory = val),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildLabel('Description'),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 16),
            _buildLabel('Key Features (Comma separated)'),
            CustomTextField(controller: _featuresController, hintText: 'Fresh, Organic, Local'),

            const SizedBox(height: 35),
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
                : PrimaryButton(text: widget.product == null ? 'Save Product' : 'Update Product', onPressed: _saveProduct),
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