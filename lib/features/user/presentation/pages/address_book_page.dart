import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zafgoal/core/theme/app_colors.dart';
import '../../../auth/presentation/pages/add_address_page.dart';

class AddressBookPage extends StatefulWidget {
  const AddressBookPage({super.key});

  @override
  State<AddressBookPage> createState() => _AddressBookPageState();
}

class _AddressBookPageState extends State<AddressBookPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _addresses = [];

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  // --- Supabase se saray Addresses mangwane ka logic ---
  Future<void> _fetchAddresses() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from('addresses')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false);

        if (mounted) {
          setState(() {
            _addresses = List<Map<String, dynamic>>.from(data);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- NAYA LOGIC: Address Delete Karna ---
  Future<void> _deleteAddress(String id) async {
    // Pehle user se confirmation lein
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Address', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    setState(() => _isLoading = true);

    try {
      // Supabase se delete karein
      await Supabase.instance.client.from('addresses').delete().eq('id', id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address deleted successfully!'), backgroundColor: Colors.red),
        );
        _fetchAddresses(); // List ko dubara refresh karein
      }
    } catch (e) {
      debugPrint('Error deleting address: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
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
        title: const Text('My Addresses', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
          : _addresses.isEmpty
          ? _buildEmptyState()
          : _buildAddressList(),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryDark,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAddressPage()),
          ).then((_) => _fetchAddresses());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('No addresses saved yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Click the + button below to add one.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAddressList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _addresses.length,
      itemBuilder: (context, index) {
        final address = _addresses[index];
        return GestureDetector(
          onTap: () {
            // Tap karne par Checkout Page ko wapas bhej dega
            Navigator.pop(context, address);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(15), // Padding thori adjust ki
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Color(0xFFF5F5F5), shape: BoxShape.circle),
                  child: const Icon(Icons.location_on, color: AppColors.primaryDark),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(address['title'] ?? 'Address', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(address['full_address'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(address['phone'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),

                // --- NAYA LOGIC: Delete Button ---
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteAddress(address['id'].toString()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}