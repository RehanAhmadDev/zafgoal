import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zafgoal/shared/widgets/primary_button.dart';
import 'package:zafgoal/shared/widgets/custom_text_field.dart';
import 'package:zafgoal/providers/cart_provider.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

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
        title: const Text('Cart', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: CustomTextField(
              hintText: 'Search in cart',
              suffixIcon: Icon(Icons.search, color: Colors.grey),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Row(
              children: [
                _stepCircle("1", "My Order", true),
                Expanded(child: Container(height: 2, color: Colors.black12)),
                _stepCircle("2", "Details", false),
                Expanded(child: Container(height: 2, color: Colors.black12)),
                _stepCircle("3", "Payment", false),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {
                    context.read<CartProvider>().clearCart();
                  },
                  child: const Text('Clear all', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),

          // --- LIVE CART LIST ---
          Expanded(
            child: Consumer<CartProvider>(
              builder: (context, cart, child) {
                if (cart.items.isEmpty) {
                  return const Center(
                    child: Text('Your cart is empty!', style: TextStyle(color: Colors.grey)),
                  );
                }
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _buildCartItem(context, item);
                  },
                );
              },
            ),
          ),

          _buildSummaryCard(context),
        ],
      ),
    );
  }

  Widget _stepCircle(String number, String label, bool isActive) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isActive ? const Color(0xFF233933) : Colors.black.withOpacity(0.05),
          child: Text(number, style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? Colors.black : Colors.grey)),
      ],
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              item.image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60, height: 60, color: Colors.grey.shade200,
                child: const Icon(Icons.shopping_basket, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                Text(item.price, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- TABADELI: Provider ka asli function call kiya ---
              GestureDetector(
                onTap: () {
                  context.read<CartProvider>().decreaseQuantity(item.id);
                },
                child: _qtyBtn(item.quantity > 1 ? Icons.remove : Icons.delete_outline, isDelete: item.quantity == 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(item.quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              GestureDetector(
                onTap: () {
                  context.read<CartProvider>().increaseQuantity(item.id);
                },
                child: _qtyBtn(Icons.add, isDark: true),
              ),
              // ----------------------------------------------------
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, {bool isDark = false, bool isDelete = false}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF233933) : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: isDelete ? Colors.red.withOpacity(0.3) : Colors.black12),
      ),
      child: Icon(icon, size: 16, color: isDark ? Colors.white : (isDelete ? Colors.red : Colors.black)),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _summaryRow('Sub Total :', '£${cart.totalAmount.toStringAsFixed(2)}'),
              _summaryRow('Delivery Charges :', '£0.00'),
              const Divider(),
              _summaryRow('Total :', '£${cart.totalAmount.toStringAsFixed(2)}', isTotal: true),
              const SizedBox(height: 15),
              PrimaryButton(
                text: 'Proceed to Checkout',
                onPressed: () {
                  if (cart.items.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Your cart is empty!')),
                    );
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutPage()));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 14)),
          Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 14)),
        ],
      ),
    );
  }
}