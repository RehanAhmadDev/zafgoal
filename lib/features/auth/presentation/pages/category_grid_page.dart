import 'package:flutter/material.dart';

class CategoryGridPage extends StatelessWidget {
  const CategoryGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> allCategories = [
      {'name': 'Toys', 'img': 'https://cdn-icons-png.flaticon.com/512/3082/3082060.png'},
      {'name': 'Bakery', 'img': 'https://cdn-icons-png.flaticon.com/512/3014/3014498.png'},
      {'name': 'Vegetable', 'img': 'https://cdn-icons-png.flaticon.com/512/2329/2329865.png'},
      {'name': 'Dairy', 'img': 'https://cdn-icons-png.flaticon.com/512/2674/2674486.png'},
      {'name': 'Drinks', 'img': 'https://cdn-icons-png.flaticon.com/512/2405/2405479.png'},
      {'name': 'Meat', 'img': 'https://cdn-icons-png.flaticon.com/512/3143/3143643.png'},
      // Aap is list ko mazeed bara kar sakte hain
    ];

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
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 20,
          crossAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: 15, // Dummy repetition
        itemBuilder: (context, index) {
          var cat = allCategories[index % allCategories.length];
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
                  backgroundImage: NetworkImage(cat['img']!),
                ),
              ),
              const SizedBox(height: 8),
              Text(cat['name']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          );
        },
      ),
    );
  }
}