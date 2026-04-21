import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoriteProvider with ChangeNotifier {
  // Pasandeeda products ki list
  List<Map<String, dynamic>> _favorites = [];

  List<Map<String, dynamic>> get favorites => _favorites;

  FavoriteProvider() {
    _loadFavorites();
  }

  // --- Data ko Phone mein Save karna ---
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    // Maps ko text (JSON) mein badal kar save karna
    List<String> favStrings = _favorites.map((item) => json.encode(item)).toList();
    prefs.setStringList('favorites_data', favStrings);
  }

  // --- Data ko Phone se Wapas lana ---
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? favStrings = prefs.getStringList('favorites_data');
    if (favStrings != null) {
      _favorites = favStrings.map((itemStr) => json.decode(itemStr) as Map<String, dynamic>).toList();
      notifyListeners();
    }
  }

  // Check karna ke kya yeh product pehle se pasand hai? (Dil laal karna hai ya nahi)
  bool isFavorite(String productName) {
    return _favorites.any((item) => item['name'] == productName);
  }

  // Dil dabane par add ya remove karna
  void toggleFavorite(Map<String, dynamic> product) {
    String productName = product['name'];
    int index = _favorites.indexWhere((item) => item['name'] == productName);

    if (index >= 0) {
      // Agar pehle se hai, toh nikal do (Dil khali)
      _favorites.removeAt(index);
    } else {
      // Agar nahi hai, toh add kar do (Dil laal)
      _favorites.add(product);
    }

    _saveFavorites(); // Fauran save karo
    notifyListeners(); // UI ko update karo
  }
}