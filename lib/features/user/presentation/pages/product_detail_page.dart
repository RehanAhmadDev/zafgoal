import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zafgoal/providers/cart_provider.dart';

class ProductDetailPage extends StatefulWidget {
  final String title;
  final String price;
  final String imageUrl;

  const ProductDetailPage({
    super.key,
    required this.title,
    required this.price,
    this.imageUrl = 'https://images.unsplash.com/photo-1516448620398-c5f44bf9f441?w=600',
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;

  // --- NAYE VARIABLES: Database se data save karne k liye ---
  String _description = '';
  List<String> _features = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  // --- NAYA LOGIC: Supabase se real details fetch karna ---
  Future<void> _fetchProductDetails() async {
    try {
      final data = await Supabase.instance.client
          .from('products')
          .select('description, features')
          .eq('name', widget.title)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _description = data?['description'] ?? 'No description available for this product yet.';

          var fetchedFeatures = data?['features'];
          if (fetchedFeatures is List) {
            _features = List<String>.from(fetchedFeatures.map((e) => e.toString()));
          } else if (fetchedFeatures is String) {
            _features = [fetchedFeatures];
          } else {
            _features = ['Premium Quality Guaranteed.'];
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching product details: $e');
      if (mounted) {
        setState(() {
          _description = 'Details currently unavailable.';
          _features = ['Information unavailable.'];
          _isLoading = false;
        });
      }
    }
  }

  void _increaseQty() {
    setState(() {
      _quantity++;
    });
  }

  void _decreaseQty() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
      }
    });
  }

  // --- NAYA LOGIC: Total Price Calculate Karna ---
  String get _calculatedTotalPrice {
    // Price text ("£15.99") se sirf number ("15.99") nikalna
    String cleanPrice = widget.price.replaceAll(RegExp(r'[^0-9.]'), '');
    double priceVal = double.tryParse(cleanPrice) ?? 0.0;

    // Quantity se multiply karna
    double total = priceVal * _quantity;

    // Wapas symbol lagana (agar mojood ho)
    String symbol = widget.price.startsWith('£') ? '£' : '';
    return '$symbol${total.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Product', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none_outlined, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)), borderSide: BorderSide.none),
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.network(
                      widget.imageUrl,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text('Price: ${widget.price}', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                  const Text('Brand: ZafGOAL Fresh Select', style: TextStyle(color: Colors.grey, fontSize: 12)),

                  const SizedBox(height: 20),
                  const Text('Product Description :', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // --- LIVE DESCRIPTION UI ---
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF233933)))
                      : Text(
                    _description,
                    style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
                  ),

                  const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                                onTap: _decreaseQty,
                                child: _qtyActionBtn(Icons.remove)
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                            GestureDetector(
                                onTap: _increaseQty,
                                child: _qtyActionBtn(Icons.add, isPrimary: true)
                            ),
                          ],
                        ),
                        // --- UPDATED: Ab yahan dynamic total price aayegi ---
                        Text(_calculatedTotalPrice, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            _buildKeyFeatures(),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<CartProvider>().addToCart(
                          widget.title,
                          widget.title,
                          widget.price,
                          widget.imageUrl,
                          _quantity,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${widget.title} added to cart!'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF233933),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        side: const BorderSide(color: Colors.black12),
                      ),
                      child: const Text('Add To Cart', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF233933),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Buy Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _qtyActionBtn(IconData icon, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isPrimary ? Colors.grey.withOpacity(0.5) : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12),
      ),
      child: Icon(icon, size: 20, color: isPrimary ? Colors.black : Colors.black54),
    );
  }

  Widget _buildKeyFeatures() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Key Features', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Color(0xFF233933), strokeWidth: 2))
          else if (_features.isEmpty)
            _featureItem('No features listed.')
          else
            ..._features.map((feature) => _featureItem(feature)),
        ],
      ),
    );
  }

  Widget _featureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13))),
        ],
      ),
    );
  }
}