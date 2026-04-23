import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_address_page.dart';

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
            .order('created_at', ascending: false); // Naye address upar aayenge

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context), // Agar bina select kiye wapas jana ho
        ),
        title: const Text('My Addresses', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF233933)))
          : _addresses.isEmpty
          ? _buildEmptyState()
          : _buildAddressList(),

      // --- Naya address add karne ka floating button ---
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF233933),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAddressPage()),
          ).then((_) => _fetchAddresses()); // Add karne k baad wapas aaye toh refresh kare
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Agar koi address save nahi hai
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

  // Save kiye gaye addresses ki list
  Widget _buildAddressList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _addresses.length,
      itemBuilder: (context, index) {
        final address = _addresses[index];
        return GestureDetector(
          onTap: () {
            // Jadoo: Tap karne par selected address data Checkout Page ko wapas bhej dega
            Navigator.pop(context, address);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(20),
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
                  child: const Icon(Icons.location_on, color: Color(0xFF233933)),
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
                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}