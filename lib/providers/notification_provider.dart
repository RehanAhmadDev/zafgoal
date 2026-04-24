import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;
  RealtimeChannel? _channel; // Naya: Channel ko save karne k liye

  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  NotificationProvider() {
    fetchNotifications();
    subscribeToNotifications();
  }

  // --- 1. Initial Data Fetch ---
  Future<void> fetchNotifications() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    if (_notifications.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final response = await Supabase.instance.client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      _notifications = List<Map<String, dynamic>>.from(response);
      _unreadCount = _notifications.where((n) => n['is_read'] == false).length;
    } catch (e) {
      debugPrint('Fetch Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 2. Real-time Subscription (Optimized) ---
  void subscribeToNotifications() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Pehle purane channel ko band karo agar koi hai
    _channel?.unsubscribe();

    _channel = Supabase.instance.client
        .channel('public:notifications')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert, // Jab naya row add ho
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: user.id,
      ),
      callback: (payload) {
        debugPrint('New Notification Arrived!');
        // Optimization: Poori list fetch karne k bajaye sirf naya record top par dalo
        _notifications.insert(0, payload.newRecord);
        _unreadCount++;
        notifyListeners();
      },
    )
        .subscribe();
  }

  // --- 3. Mark As Read (Smarter Logic) ---
  Future<void> markAsRead() async {
    if (_unreadCount == 0) return;

    // UI Fast Update: Pehle badge zero karo
    _unreadCount = 0;
    notifyListeners();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('notifications')
            .update({'is_read': true})
            .eq('user_id', user.id)
            .eq('is_read', false); // Sirf unhein update karo jo pehle se read nahi hain

        // Local list ko update karo bina fetch kiye (battery saving)
        for (var n in _notifications) {
          n['is_read'] = true;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('MarkAsRead Error: $e');
      fetchNotifications(); // Error ki surat mein wapas fetch kar lo
    }
  }

  // --- 4. Cleanup ---
  @override
  void dispose() {
    _channel?.unsubscribe(); // App band hote waqt listener khatam karo
    super.dispose();
  }
}