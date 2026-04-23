import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;

  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  NotificationProvider() {
    fetchNotifications();
    subscribeToNotifications();
  }

  Future<void> fetchNotifications() async {
    // Sirf pehli baar loading state dikhayenge
    if (_notifications.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('notifications')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false);

        _notifications = List<Map<String, dynamic>>.from(response);

        // Sirf wo ginte hain jo parhay nahi gaye (is_read == false)
        // Null values se bachne k liye check lagaya hai
        _unreadCount = _notifications.where((n) => n['is_read'] == false).length;
      }
    } catch (e) {
      debugPrint('Fetch Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- FINAL & STRONGER MARK AS READ ---
  Future<void> markAsRead() async {
    // 1. UI ko foran zero karo taake bell ka badge gayab ho jaye
    _unreadCount = 0;
    notifyListeners();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // 2. Database mein is user ki TAMAM notifications ko TRUE kar do
        // Hum ne filter hata diya hai taake har row update ho jaye
        final response = await Supabase.instance.client
            .from('notifications')
            .update({'is_read': true})
            .eq('user_id', user.id)
            .select(); // .select() lagane se confirmation milti hai

        debugPrint('Database: ${response.length} rows marked as read.');

        // 3. THORA SA INTEZAR (500ms): Database processing k liye gap
        await Future.delayed(const Duration(milliseconds: 500));

        // 4. Fresh data mangwayein taake local list bhi update ho jaye
        await fetchNotifications();
      }
    } catch (e) {
      debugPrint('MarkAsRead Error: $e');
      // Error ki surat mein wapas data mangwa lo
      fetchNotifications();
    }
  }

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
        debugPrint('Real-time notification received!');
        fetchNotifications();
      },
    )
        .subscribe();
  }
}