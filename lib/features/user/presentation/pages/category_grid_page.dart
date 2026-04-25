import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryGridPage extends StatelessWidget {
  const CategoryGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Category', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Yahan se Static List hata kar StreamBuilder laga diya hai
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client.from('categories').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          // Error handling
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final categories = snapshot.data;

          // Agar database mein koi category nahi hai
          if (categories == null || categories.isEmpty) {
            return const Center(child: Text('No categories found.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 20,
              crossAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: categories.length, // Ab yeh database ki ginti ke hisab se chalega
            itemBuilder: (context, index) {
              final cat = categories[index];
              final String name = cat['name'] ?? 'Unknown';
              final String imgStr = cat['img'] ?? '';

              // Agar tasveer ka link khali hai (jaise nayi category mein tha), toh yeh default icon dikhaye ga
              final String displayImg = imgStr.isEmpty
                  ? 'https://cdn-icons-png.flaticon.com/512/1044/1044627.png'
                  : imgStr;

              return Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(displayImg),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}