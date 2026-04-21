import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zafgoal/features/auth/presentation/pages/product_detail_page.dart';
import 'package:zafgoal/providers/cart_provider.dart';
import 'package:zafgoal/core/theme/app_colors.dart';
import 'package:zafgoal/shared/widgets/custom_text_field.dart';


class SearchResultsPage extends StatefulWidget {
  final String searchQuery;

  const SearchResultsPage({super.key, required this.searchQuery});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  bool _isLoading = true;
  List<dynamic> _searchResults = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _performSearch(widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- NAYA LOGIC: Supabase se Data Dhoondhna ---
  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);

    try {
      final data = await Supabase.instance.client
          .from('products')
          .select()
          .ilike('name', '%$query%'); // Case-insensitive search

      if (mounted) {
        setState(() {
          _searchResults = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Search Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
        title: const Text('Search Results', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // Filter Button
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.primaryDark),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Active Search Bar ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (newQuery) {
                if (newQuery.trim().isNotEmpty) {
                  _performSearch(newQuery.trim());
                }
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                suffixIcon: const Icon(Icons.search, color: AppColors.primaryDark),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // --- Live Results Count ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  _isLoading ? 'Searching...' : 'Found ${_searchResults.length} Results',
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)
              ),
            ),
          ),

          const SizedBox(height: 15),

          // --- Grid of Products (Live Data) ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
                : _searchResults.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 0.75,
              ),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return _buildResultCard(context, _searchResults[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          const Text('No products found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text('Try searching for something else.', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  // --- Aap ka UI, lekin Database Data ke sath ---
  Widget _buildResultCard(BuildContext context, dynamic product) {
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
        child: Column(
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
                  Text(
                      product['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          product['price'] ?? '',
                          style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)
                      ),

                      // --- NAYA LOGIC: Direct Add to Cart ---
                      GestureDetector(
                        onTap: () {
                          context.read<CartProvider>().addToCart(
                            product['name'],
                            product['name'],
                            product['price'],
                            product['img'] ?? 'https://via.placeholder.com/150',
                            1,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product['name']} added to cart!'),
                              backgroundColor: AppColors.primaryDark,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8)
                          ),
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
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter By', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text('Price Range', style: TextStyle(fontWeight: FontWeight.bold)),
              RangeSlider(
                values: const RangeValues(10, 80),
                max: 100,
                divisions: 10,
                activeColor: AppColors.primaryDark,
                labels: const RangeLabels('£10', '£80'),
                onChanged: (values) {},
              ),
              const SizedBox(height: 20),
              const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  ChoiceChip(label: const Text('Lowest Price'), selected: true, selectedColor: AppColors.primaryDark.withOpacity(0.2)),
                  ChoiceChip(label: const Text('Highest Price'), selected: false),
                  ChoiceChip(label: const Text('Newest'), selected: false),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Apply Filters', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
}