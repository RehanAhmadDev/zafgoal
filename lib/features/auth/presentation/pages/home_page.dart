import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:zafgoal/features/auth/presentation/pages/profile_page.dart';
import 'package:zafgoal/features/auth/presentation/pages/search_results_page.dart';
import 'package:zafgoal/providers/cart_provider.dart';
import 'package:zafgoal/providers/favorite_provider.dart';
import 'package:zafgoal/providers/notification_provider.dart';

import 'cart_page.dart';
import 'notifications_page.dart';
import 'product_detail_page.dart';
import 'category_grid_page.dart';
import 'favorites_page.dart';
import 'category_products_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = 'Loading...';
  String? _avatarUrl;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _allProducts = []; // NAYA: Saare products k liye
  List<Map<String, dynamic>> _freshFruits = [];
  List<Map<String, dynamic>> _dailyDairy = [];

  bool _isLoadingCategories = true;
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchHomeData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        if (mounted) {
          setState(() {
            _userName = data['full_name']?.toString() ?? 'User';
            _avatarUrl = data['avatar_url']?.toString();
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _userName = 'User');
    }
  }

  // --- BUG FIX: Added Order and All Products List ---
  Future<void> _fetchHomeData() async {
    try {
      final supabase = Supabase.instance.client;

      // 1. Categories fetch karein
      final categoriesData = await supabase.from('categories').select();

      // 2. Products fetch karein (Naya order lagaya hai taake latest pehle aayen)
      final productsData = await supabase
          .from('products')
          .select()
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(categoriesData);
          _allProducts = List<Map<String, dynamic>>.from(productsData);

          // Specific categories filtering
          _freshFruits = _allProducts.where((p) => p['category'] == 'Fresh Fruits').toList();
          _dailyDairy = _allProducts.where((p) => p['category'] == 'Daily Dairy').toList();

          _isLoadingCategories = false;
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
          _isLoadingProducts = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchHomeData, // Pull to refresh add kiya hai
          color: const Color(0xFF233933),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildSearchBar(context),
                const HomeBannerSlider(),

                _buildSectionHeader('Categories'),
                _buildCircularCategories(),

                _buildViewAllButton(),

                // --- NAYA SECTION: Recently Added (Taake har naya product yahan show ho) ---
                if (_allProducts.isNotEmpty) ...[
                  _buildSectionHeader('Recently Added'),
                  _buildHorizontalProductList(context, _allProducts, _isLoadingProducts),
                ],

                _buildSectionHeader('Fresh Fruits'),
                _buildHorizontalProductList(context, _freshFruits, _isLoadingProducts),

                _buildSectionHeader('Daily Dairy'),
                _buildHorizontalProductList(context, _dailyDairy, _isLoadingProducts),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // --- Helper Widgets to keep code clean ---

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        textInputAction: TextInputAction.search,
        onSubmitted: (query) {
          if (query.trim().isNotEmpty) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SearchResultsPage(searchQuery: query)));
          }
        },
        decoration: InputDecoration(
          hintText: 'Search products...',
          suffixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true, fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildViewAllButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: ActionChip(
          label: const Text('View All Categories', style: TextStyle(fontSize: 12, color: Colors.grey)),
          backgroundColor: Colors.white,
          side: const BorderSide(color: Colors.black12),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryGridPage())),
        ),
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () => sendTestNotification(),
      backgroundColor: const Color(0xFF233933),
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white, size: 30),
    );
  }

  // --- Existing UI Methods (Keeping them same but optimized) ---

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())).then((_) => _fetchUserData()),
            child: CircleAvatar(
              radius: 25, backgroundColor: Colors.grey.shade300,
              backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
              child: _avatarUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Text('Welcome Back!', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              await context.read<NotificationProvider>().markAsRead();
              if (mounted) Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()));
            },
            child: _buildNotificationIcon(),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalProductList(BuildContext context, List<Map<String, dynamic>> products, bool isLoading) {
    if (isLoading) return const SizedBox(height: 230, child: Center(child: CircularProgressIndicator(color: Color(0xFF233933))));
    if (products.isEmpty) return const SizedBox.shrink(); // Empty filter hide kar dega

    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: products.length,
        itemBuilder: (context, index) => Container(width: 160, margin: const EdgeInsets.symmetric(horizontal: 8), child: _buildProductCard(context, products[index])),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    final String pName = product['name']?.toString() ?? 'Product';
    final String pPrice = product['price']?.toString() ?? '£0.0';
    final String pImg = product['img']?.toString() ?? 'https://via.placeholder.com/150';

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(title: pName, price: pPrice, imageUrl: pImg))),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: pImg, fit: BoxFit.cover, width: double.infinity,
                      placeholder: (context, url) => Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) => const Icon(Icons.shopping_basket, color: Colors.grey),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(pPrice, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          GestureDetector(
                            onTap: () {
                              context.read<CartProvider>().addToCart(pName, pName, pPrice, pImg, 1);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart!'), duration: Duration(seconds: 1)));
                            },
                            child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFFF1F1F1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add, size: 20)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(top: 8, right: 8, child: _buildFavoriteIcon(pName, pPrice, pImg)),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteIcon(String name, String price, String img) {
    return Consumer<FavoriteProvider>(
      builder: (context, favProvider, child) {
        bool isFav = favProvider.isFavorite(name);
        return GestureDetector(
          onTap: () => favProvider.toggleFavorite({'name': name, 'price': price, 'img': img}),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
            child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : Colors.grey, size: 18),
          ),
        );
      },
    );
  }

  Widget _buildCircularCategories() {
    if (_isLoadingCategories) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator(color: Color(0xFF233933))));
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          var cat = _categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryProductsPage(categoryName: cat['name'] ?? ''))),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30, backgroundColor: Colors.white,
                    child: Padding(padding: const EdgeInsets.all(12.0), child: CachedNetworkImage(imageUrl: cat['img'] ?? '', fit: BoxFit.contain, errorWidget: (context, url, error) => const Icon(Icons.category))),
                  ),
                  const SizedBox(height: 5),
                  Text(cat['name'] ?? '', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));

  Widget _buildNotificationIcon() {
    return Consumer<NotificationProvider>(
      builder: (context, notiProvider, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.notifications_none_outlined, color: Colors.black)),
            if (notiProvider.unreadCount > 0)
              Positioned(right: -2, top: -2, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: Text('${notiProvider.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
          ],
        );
      },
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomAppBar(
      height: 70, color: Colors.white, shape: const CircularNotchedRectangle(), notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: const Icon(Icons.home_filled, color: Color(0xFF233933)), onPressed: () {}),
          IconButton(icon: const Icon(Icons.grid_view_rounded, color: Colors.grey), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryGridPage()))),
          const SizedBox(width: 40),
          IconButton(icon: const Icon(Icons.favorite_border, color: Colors.grey), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesPage()))),
          IconButton(icon: const Icon(Icons.shopping_bag_outlined, color: Colors.grey), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()))),
        ],
      ),
    );
  }

  // --- Test Notification Logic ---
  Future<void> sendTestNotification() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      await Supabase.instance.client.from('notifications').insert({
        'user_id': user.id, 'title': 'Order Placed! 🛍️', 'subtitle': 'Aap ka naya order confirm ho gaya hai.', 'is_read': false,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification Sent! 🎉'), backgroundColor: Color(0xFF233933)));
    } catch (e) { debugPrint('Error: $e'); }
  }
}

// --- HomeBannerSlider class remains same as your provided code ---
class HomeBannerSlider extends StatefulWidget {
  const HomeBannerSlider({super.key});
  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}
class _HomeBannerSliderState extends State<HomeBannerSlider> {
  int _currentPage = 0;
  List<String> _bannerImages = [];
  bool _isLoading = true;
  @override
  void initState() { super.initState(); _fetchBanners(); }
  Future<void> _fetchBanners() async {
    try {
      final response = await Supabase.instance.client.from('banners').select('image_url').order('created_at', ascending: false);
      if (mounted) { setState(() { _bannerImages = List<String>.from(response.map((item) => item['image_url'])); _isLoading = false; }); }
    } catch (e) { setState(() => _isLoading = false); }
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator(color: Color(0xFF233933))));
    if (_bannerImages.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 180, width: double.infinity, margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Stack(children: [
        ClipRRect(borderRadius: BorderRadius.circular(25), child: PageView.builder(onPageChanged: (index) => setState(() => _currentPage = index), itemCount: _bannerImages.length, itemBuilder: (context, index) => CachedNetworkImage(imageUrl: _bannerImages[index], fit: BoxFit.cover, width: double.infinity))),
        Positioned(bottom: 15, left: 0, right: 0, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_bannerImages.length, (index) => AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 4), height: 8, width: _currentPage == index ? 24 : 8, decoration: BoxDecoration(color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(8)))))),
      ]),
    );
  }
}