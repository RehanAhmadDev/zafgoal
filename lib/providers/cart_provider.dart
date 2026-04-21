import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- NAYA IMPORT: Supabase k liye
import 'dart:convert';

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
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      image: map['image'],
      quantity: map['quantity'],
    );
  }
}

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;
  int get itemCount => _items.length;

  CartProvider() {
    _loadCartData();
  }

  Future<void> _saveCartData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartStrings = _items.map((item) => json.encode(item.toMap())).toList();
    prefs.setStringList('cart_data', cartStrings);
  }

  Future<void> _loadCartData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? cartStrings = prefs.getStringList('cart_data');
    if (cartStrings != null) {
      _items = cartStrings.map((itemStr) => CartItem.fromMap(json.decode(itemStr))).toList();
      notifyListeners();
    }
  }

  void addToCart(String id, String name, String price, String image, int quantity) {
    int index = _items.indexWhere((item) => item.name == name);

    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(id: id, name: name, price: price, image: image, quantity: quantity));
    }

    _saveCartData();
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveCartData();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _saveCartData();
    notifyListeners();
  }

  void increaseQuantity(String id) {
    int index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index].quantity++;
      _saveCartData();
      notifyListeners();
    }
  }

  void decreaseQuantity(String id) {
    int index = _items.indexWhere((item) => item.id == id);
    if (index >= 0 && _items[index].quantity > 1) {
      _items[index].quantity--;
      _saveCartData();
      notifyListeners();
    } else if (index >= 0 && _items[index].quantity == 1) {
      removeItem(id);
    }
  }

  double get totalAmount {
    double total = 0.0;
    for (var item in _items) {
      String cleanPrice = item.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double priceValue = double.tryParse(cleanPrice) ?? 0.0;
      total += priceValue * item.quantity;
    }
    return total;
  }

  // --- NAYA LOGIC: Checkout & Place Order ---
  Future<bool> placeOrder() async {
    if (_items.isEmpty) return false;

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      // Check karna k user login hai ya nahi
      if (user == null) {
        debugPrint('User not logged in!');
        return false;
      }

      // 1. Cart ka data Supabase k format (JSON) may badalna
      List<Map<String, dynamic>> orderItemsJson = _items.map((item) => {
        'product_name': item.name,
        'price': item.price,
        'quantity': item.quantity,
        'image': item.image
      }).toList();

      // 2. Supabase k 'orders' table may bhejna
      await supabase.from('orders').insert({
        'user_id': user.id,
        'total_amount': totalAmount.toStringAsFixed(2),
        'status': 'Pending', // Shuru may order pending hota hai
        'items': orderItemsJson, // Yeh jsonb wale column may jayega
      });

      // 3. Agar order successful ho jaye toh cart khali kar do
      clearCart();
      return true;

    } catch (e) {
      debugPrint('Error placing order: $e');
      return false;
    }
  }
}