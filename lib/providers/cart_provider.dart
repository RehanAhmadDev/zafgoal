import 'package:flutter/material.dart';

// 1. Cart Item ka Model
class CartItem {
  final String id;
  final String name;
  final String price;
  final String image;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 1, // Default quantity 1
  });
}

// 2. Cart Provider (App ka Cart Manager)
class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  // Cart k saray items dekhne k liye
  List<CartItem> get items => _items;

  // Cart may kitni items hain (Icon badge k liye)
  int get itemCount => _items.length;

  // --- MISSING 1: Quantity k sath item add karna ---
  void addToCart(String id, String name, String price, String image, int quantity) {
    int index = _items.indexWhere((item) => item.name == name);

    if (index >= 0) {
      // Agar item pehlay se hai, to nayi quantity us may jama (add) kar do
      _items[index].quantity += quantity;
    } else {
      // Agar nahi hai, to nayi item list may daal do
      _items.add(CartItem(
          id: id,
          name: name,
          price: price,
          image: image,
          quantity: quantity
      ));
    }
    notifyListeners();
  }

  // --- MISSING 2: Item ko cart se nikalna (Delete karna) ---
  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // --- MISSING 3: Cart ko bilkul khali karna (Order place hone k baad) ---
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // --- MISSING 4: Total Bill (Amount) calculate karna ---
  double get totalAmount {
    double total = 0.0;
    for (var item in _items) {
      // '£2.5' jaise text may se sirf '2.5' nikalna taake math ho sakay
      String cleanPrice = item.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double priceValue = double.tryParse(cleanPrice) ?? 0.0;

      // Price ko quantity se multiply kar k total may jama karna
      total += priceValue * item.quantity;
    }
    return total;
  }
}