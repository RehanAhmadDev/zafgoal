import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // NAYA IMPORT: Input formatters k liye
import 'package:supabase_flutter/supabase_flutter.dart';

class MyAccountPage extends StatefulWidget {
  final String currentName;
  const MyAccountPage({super.key, required this.currentName});

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();

  String? _selectedGender;
  bool _isLoading = true; // Data fetch hotay waqt loading dikhane k liye
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentName;
    _fetchCompleteProfile();
  }

  // --- PROFESSIONAL LOGIC: Database se current data mangwana ---
  Future<void> _fetchCompleteProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        _emailController.text = user.email ?? '';

        final data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        if (mounted) {
          setState(() {
            _nameController.text = data['full_name'] ?? widget.currentName;
            _phoneController.text = data['phone_number'] ?? '';
            _dobController.text = data['dob'] ?? '';
            _selectedGender = data['gender'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile details: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- PROFESSIONAL LOGIC: Date Picker ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF233933),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // --- PROFESSIONAL LOGIC: Data Save Karna ---
  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }

    // Phone number length validation
    if (_phoneController.text.isNotEmpty && _phoneController.text.length < 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 11-digit phone number')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('profiles').update({
          'full_name': _nameController.text.trim(),
          'phone_number': _phoneController.text.trim(),
          'dob': _dobController.text.isEmpty ? null : _dobController.text,
          'gender': _selectedGender,
        }).eq('id', user.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully! 🎉'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // True bhej rahay hain taake pichli screen refresh ho
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('My Account', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF233933)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Full Name'),
            _buildTextField(_nameController, 'Enter your name'),
            const SizedBox(height: 16),

            // Email is Read-Only
            _buildLabel('Email Address (Read-only)'),
            TextField(
              controller: _emailController,
              enabled: false,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade300,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              ),
            ),
            const SizedBox(height: 16),

            // Phone Number field with formatters
            _buildLabel('Phone Number'),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                hintText: '03XX XXXXXXX',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                counterText: "",
              ),
            ),
            const SizedBox(height: 16),

            // Gender Dropdown
            _buildLabel('Gender'),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              ),
              hint: const Text('Select Gender', style: TextStyle(color: Colors.grey, fontSize: 14)),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: ['Male', 'Female', 'Other'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
            ),
            const SizedBox(height: 16),

            // Date of Birth Field (Taps to open DatePicker)
            _buildLabel('Date of Birth'),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: _buildTextField(_dobController, 'YYYY-MM-DD'),
              ),
            ),
            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF233933),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper function UI clean rakhne k liye
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }
}