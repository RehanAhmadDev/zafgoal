import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zafgoal/features/user/presentation/pages/product_detail_page.dart';
import 'package:zafgoal/providers/cart_provider.dart';
import 'package:zafgoal/core/theme/app_colors.dart';

class SearchResultsPage extends StatefulWidget {
  final String searchQuery;

  const SearchResultsPage({super.key, required this.searchQuery});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  bool _isLoading = true;

  // Naye variables: Asli data aur filtered data alag rakhne k liye
  List<dynamic> _allFetchedResults = [];
  List<dynamic> _searchResults = [];
  late TextEditingController _searchController;

  // Filter ke variables
  RangeValues _priceRange = const RangeValues(0, 150); // Default range
  String _sortBy = 'Newest';

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

  // --- Supabase se Data Dhoondhna ---
  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);

    try {
      final data = await Supabase.instance.client
          .from('products')
          .select()
          .ilike('name', '%$query%'); // Case-insensitive search

      if (mounted) {
        _allFetchedResults = data;
        _applyFilters(); // Data aane k baad filter apply karna
      }
    } catch (e) {
      debugPrint('Search Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- NAYA LOGIC: Filters aur Sorting Apply Karna ---
  void _applyFilters() {
    List<dynamic> temp = List.from(_allFetchedResults);

    // 1. Price Range Filter
    temp = temp.where((item) {
      // "£15.99" jesay text se sirf number (15.99) nikalna
      String priceStr = item['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
      double priceVal = double.tryParse(priceStr) ?? 0.0;
      return priceVal >= _priceRange.start && priceVal <= _priceRange.end;
    }).toList();

    // 2. Sorting Logic
    if (_sortBy == 'Lowest Price') {
      temp.sort((a, b) {
        double pA = double.tryParse(a['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        double pB = double.tryParse(b['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        return pA.compareTo(pB); // Choti price pehle
      });
    } else if (_sortBy == 'Highest Price') {
      temp.sort((a, b) {
        double pA = double.tryParse(a['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        double pB = double.tryParse(b['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        return pB.compareTo(pA); // Bari price pehle
      });
    } else if (_sortBy == 'Newest') {
      temp.sort((a, b) {
        DateTime dA = DateTime.tryParse(a['created_at'].toString()) ?? DateTime.now();
        DateTime dB = DateTime.tryParse(b['created_at'].toString()) ?? DateTime.now();
        return dB.compareTo(dA); // Naya pehle
      });
    }

    setState(() {
      _searchResults = temp;
      _isLoading = false;
    });
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
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.primaryDark),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
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

  // --- NAYA LOGIC: Functional Filter Bottom Sheet ---
  void _showFilterBottomSheet(BuildContext context) {
    // Temporary variables taake sirf "Apply" dabane par filter ho
    RangeValues tempRange = _priceRange;
    String tempSort = _sortBy;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        // StatefulBuilder bottom sheet ke andar live tabdeeli dikhane k liye hai
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
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
                    values: tempRange,
                    max: 150, // Aap apni items k hisab se isay barha bhi saktay hain
                    divisions: 15,
                    activeColor: AppColors.primaryDark,
                    labels: RangeLabels('£${tempRange.start.toInt()}', '£${tempRange.end.toInt()}'),
                    onChanged: (values) {
                      setModalState(() => tempRange = values);
                    },
                  ),
                  const SizedBox(height: 20),

                  const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: ['Lowest Price', 'Highest Price', 'Newest'].map((sortOption) {
                      return ChoiceChip(
                        label: Text(sortOption),
                        selected: tempSort == sortOption,
                        selectedColor: AppColors.primaryDark.withOpacity(0.2),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => tempSort = sortOption);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: () {
                      // Apply dabane par asali variables update karke filter lagao
                      setState(() {
                        _priceRange = tempRange;
                        _sortBy = tempSort;
                      });
                      _applyFilters();
                      Navigator.pop(context); // Bottom sheet band kar do
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('Apply Filters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}