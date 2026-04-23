import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;

  NotificationProvider() {
    // App chaltay hi notifications mangwa lega
    fetchNotifications();
  }

  // --- 1. Supabase se Notifications mangwana ---
  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('notifications')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false); // Nayi notifications upar aayengi

        _notifications = List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- 2. Real-time Listen karne k liye helper (Optional but good) ---
  void subscribeToNotifications() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    Supabase.instance.client
        .channel('public:notifications')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: user.id,
      ),
      callback: (payload) {
        fetchNotifications(); // Jab bhi koi change ho, dobara data le aao
      },
    )
        .subscribe();
  }
}