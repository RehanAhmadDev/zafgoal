import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Data ko text may badalne k liye

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
    this.quantity = 1,
  });

  // Data save karne k liye Map may badalna
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'quantity': quantity,
    };
  }

  // Save kiye hue data ko wapas lene k liye
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

// 2. Cart Provider
class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;
  int get itemCount => _items.length;

  // App khulte hi save kiya hua data load karna
  CartProvider() {
    _loadCartData();
  }

  // --- NAYA LOGIC: Data ko phone may pakka save karna ---
  Future<void> _saveCartData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartStrings = _items.map((item) => json.encode(item.toMap())).toList();
    prefs.setStringList('cart_data', cartStrings);
  }

  // --- NAYA LOGIC: Phone se data wapas lana ---
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

    _saveCartData(); // Add karne k bade save karo
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveCartData(); // Remove karne k bade save karo
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _saveCartData(); // Clear karne k bade save karo
    notifyListeners();
  }

  // --- Plus aur Minus k liye pakkay functions ---
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
}