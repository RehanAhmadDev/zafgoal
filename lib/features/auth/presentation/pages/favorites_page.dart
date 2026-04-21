import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zafgoal/providers/favorite_provider.dart';
import 'package:zafgoal/providers/cart_provider.dart';
import 'package:zafgoal/core/theme/app_colors.dart';
import 'product_detail_page.dart'; // Apna sahi path check kar lein

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Favorites', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      // --- Consumer lagaya taake jaise hi koi cheez pasand/napasand ho, page update ho jaye ---
      body: Consumer<FavoriteProvider>(
        builder: (context, favProvider, child) {
          if (favProvider.favorites.isEmpty) {
            return _buildEmptyState();
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 0.75,
            ),
            itemCount: favProvider.favorites.length,
            itemBuilder: (context, index) {
              final product = favProvider.favorites[index];
              return _buildFavCard(context, product, favProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          const Text('No favorites yet!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text('Tap the heart icon on products you love.', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildFavCard(BuildContext context, Map<String, dynamic> product, FavoriteProvider favProvider) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              title: product['name'] ?? 'Product',
              price: product['price'] ?? '£0.0',
              imageUrl: product['img'] ?? 'https://via.placeholder.com/150',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      product['img'] ?? 'https://via.placeholder.com/150',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(product['price'] ?? '', style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),

                          // --- Direct Add to Cart ---
                          GestureDetector(
                            onTap: () {
                              context.read<CartProvider>().addToCart(
                                product['name'], product['name'], product['price'], product['img'] ?? '', 1,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${product['name']} added to cart!'), backgroundColor: AppColors.primaryDark, duration: const Duration(seconds: 1)),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.add, size: 20, color: AppColors.primaryDark),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // --- Remove from Favorites Button ---
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  favProvider.toggleFavorite(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Removed from favorites'), duration: Duration(milliseconds: 500)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                  child: const Icon(Icons.favorite, color: Colors.red, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}