import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  // Supabase mein data bhejne wala function
  Future<void> _addCategory() async {
    if (_nameController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.from('categories').insert({
        'name': _nameController.text.trim(),
        'img': '', // YAHAN CHANGE KIYA HAI: 'image_url' ki jagah 'img' kar diya hai
      });

      // Agar context mounted nahi hai toh SnackBar dikhane se pehle check karna zaroori hai
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category Add Ho Gayi! ✅')),
      );
      _nameController.clear();
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Ka Naam (e.g., Electronics)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addCategory,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Add Category'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}