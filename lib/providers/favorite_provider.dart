import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get favorites => _favorites;
  bool get isLoading => _isLoading;

  FavoriteProvider() {
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('favorites')
            .select()
            .eq('user_id', user.id);

        _favorites = List<Map<String, dynamic>>.from(response.map((item) => {
          'db_id': item['id'],
          'name': item['product_name'],
          'price': item['price'],
          'img': item['image_url'],
        }));
      }
    } catch (e) {
      debugPrint('Error fetching favorites: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(Map<String, dynamic> product) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final existingIndex = _favorites.indexWhere((item) => item['name'] == product['name']);

    if (existingIndex >= 0) {
      final dbId = _favorites[existingIndex]['db_id'];
      _favorites.removeAt(existingIndex);
      notifyListeners();

      try {
        await Supabase.instance.client.from('favorites').delete().eq('id', dbId);
      } catch (e) {
        debugPrint('Error removing favorite: $e');
        fetchFavorites();
      }
    } else {
      _favorites.add(product);
      notifyListeners();

      try {
        await Supabase.instance.client.from('favorites').insert({
          'user_id': user.id,
          'product_name': product['name'],
          'price': product['price'],
          'image_url': product['img'],
        });
        await fetchFavorites();
      } catch (e) {
        debugPrint('Error adding favorite: $e');
        _favorites.removeLast();
        notifyListeners();
      }
    }
  }

  bool isFavorite(String productName) {
    return _favorites.any((item) => item['name'] == productName);
  }
}