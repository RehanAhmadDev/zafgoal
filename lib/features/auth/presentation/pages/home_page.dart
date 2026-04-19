import 'package:flutter/material.dart';
import 'package:zafgoal/features/auth/presentation/pages/profile_page.dart';
import 'package:zafgoal/features/auth/presentation/pages/search_results_page.dart';
import 'package:zafgoal/shared/widgets/custom_text_field.dart';

import 'cart_page.dart';
import 'notifications_page.dart';
import 'product_detail_page.dart';
import 'category_grid_page.dart';



class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),

              // 2. Yahan active Search Bar laga diya hai
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  textInputAction: TextInputAction.search,
                  onSubmitted: (query) {
                    if (query.trim().isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchResultsPage(searchQuery: query),
                        ),
                      );
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    suffixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // --- FIXED: Ab yahan static image ki jagah real Slider chalega ---
              const HomeBannerSlider(),

              _buildSectionHeader('Categories'),
              _buildCircularCategories(),

              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ActionChip(
                    label: const Text('View All', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.black12),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CategoryGridPage()),
                      );
                    },
                  ),
                ),
              ),

              _buildSectionHeader('Fresh Fruits'),
              _buildHorizontalProductList(context, [
                {'name': 'Red Apple', 'price': '£2.5', 'img': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400'},
                {'name': 'Banana Dozen', 'price': '£1.8', 'img': 'https://images.unsplash.com/photo-1603833665858-e61d17a86224?w=400'},
                {'name': 'Fresh Mango', 'price': '£4.2', 'img': 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=400'},
              ]),

              _buildSectionHeader('Daily Dairy'),
              _buildHorizontalProductList(context, [
                {'name': 'Whole Milk(2L)', 'price': '£3.2', 'img': 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400'},
                {'name': 'Fresh Yogurt', 'price': '£1.5', 'img': 'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=400'},
                {'name': 'Cheese Block', 'price': '£5.0', 'img': 'https://images.unsplash.com/photo-1623428187969-5da2dcea5ebf?w=400'},
              ]),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF233933),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
            },
            child: const CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=rehan'),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Alex Jonathan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('10° Friday 11:59am', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()));
            },
            child: _buildNotificationIcon(),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalProductList(BuildContext context, List<Map<String, String>> products) {
    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: products.length,
        itemBuilder: (context, index) {
          var product = products[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildProductCard(context, product),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, String> product) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailPage(
            title: product['name']!,
            price: product['price']!,
          ))
      ),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  product['img']!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  },
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_basket, size: 40, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product['price']!, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(color: const Color(0xFFF1F1F1), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.add, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularCategories() {
    final List<Map<String, String>> categories = [
      {'name': 'Meat', 'img': 'https://cdn-icons-png.flaticon.com/512/3143/3143643.png'},
      {'name': 'Bakery', 'img': 'https://cdn-icons-png.flaticon.com/512/3014/3014498.png'},
      {'name': 'Frozen', 'img': 'https://cdn-icons-png.flaticon.com/512/2954/2954884.png'},
      {'name': 'Dairy', 'img': 'https://cdn-icons-png.flaticon.com/512/2674/2674486.png'},
      {'name': 'Drinks', 'img': 'https://cdn-icons-png.flaticon.com/512/2405/2405479.png'},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.network(categories[index]['img']!, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 5),
                Text(categories[index]['name']!, style: const TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildNotificationIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: const Icon(Icons.notifications_none_outlined),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomAppBar(
      height: 70,
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: const Icon(Icons.home_filled, color: Color(0xFF233933)), onPressed: () {}),
          IconButton(icon: const Icon(Icons.grid_view_rounded, color: Colors.grey), onPressed: () {}),
          const SizedBox(width: 40),
          IconButton(icon: const Icon(Icons.qr_code_scanner, color: Colors.grey), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.grey),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
            },
          ),
        ],
      ),
    );
  }
}

// --- NAYA WIDGET: Banner Slider ---
class HomeBannerSlider extends StatefulWidget {
  const HomeBannerSlider({super.key});

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  int _currentPage = 0;

  final List<String> _bannerImages = [
    'https://images.pexels.com/photos/1359326/pexels-photo-1359326.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/264636/pexels-photo-264636.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/1132047/pexels-photo-1132047.jpeg?auto=compress&cs=tinysrgb&w=600',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: PageView.builder(
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _bannerImages.length,
              itemBuilder: (context, index) {
                return Image.network(
                  _bannerImages[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              },
            ),
          ),
          Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _bannerImages.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}