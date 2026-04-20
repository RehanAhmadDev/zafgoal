import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Provider import kiya
import 'package:zafgoal/providers/cart_provider.dart'; // 2. Apna CartProvider import kiya

// Isay StatefulWidget bana diya taake Quantity change ho sakay
class ProductDetailPage extends StatefulWidget {
  // Database se Product ka ID aur Image bhi mangwana chahiye, abhi k liye mai String lay raha hu
  final String title;
  final String price;
  final String imageUrl;

  const ProductDetailPage({
    super.key,
    required this.title,
    required this.price,
    this.imageUrl = 'https://images.unsplash.com/photo-1516448620398-c5f44bf9f441?w=600', // Default image agar pichlay page se na aye
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  // Default quantity 1 hogi
  int _quantity = 1;

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
            // 1. Search Bar
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

            // 2. Main Product Card
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
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

                  // Title & Price Info
                  Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text('Price: ${widget.price}', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                  const Text('Brand: ZafGOAL Fresh Select', style: TextStyle(color: Colors.grey, fontSize: 12)),

                  const SizedBox(height: 20),
                  const Text('Product Description :', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'Our Class A Large Free Range eggs are sourced directly from trusted British farms where hens are free to roam from dawn until dusk...',
                    style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
                  ),

                  const SizedBox(height: 25),

                  // Quantity & Price Row
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
                        Text(widget.price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. Key Features Section
            _buildKeyFeatures(),

            const SizedBox(height: 20),

            // 4. Bottom Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      // --- NAYA LOGIC: ADD TO CART ---
                      onPressed: () {
                        // CartProvider ka function call kar rahay hain
                        context.read<CartProvider>().addToCart(
                          widget.title, // abhi id nahi hai to name ko hi id maan rahay hain
                          widget.title,
                          widget.price,
                          widget.imageUrl,
                          _quantity, // Selected quantity bhej rahay hain
                        );

                        // User ko asaan sa message dikhana
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
          _featureItem('British Lion Quality: Guaranteed quality and vaccinated against Salmonella.'),
        ],
      ),
    );
  }

  Widget _featureItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13))),
      ],
    );
  }
}