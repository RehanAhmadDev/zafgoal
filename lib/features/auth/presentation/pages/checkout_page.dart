import 'package:flutter/material.dart';
import 'package:zafgoal/shared/widgets/primary_button.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

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
        title: const Text('Checkout', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Stepper (Active Step: 2) ---
            _buildStepper(),

            // --- Address Section ---
            _buildSectionHeader('Address'),
            _buildAddressCard(),

            // --- Delivery Method ---
            _buildSectionHeader('Delivery Method'),
            _buildDeliveryMethod(),

            // --- Payment Method ---
            _buildSectionHeader('Payment Method'),
            _buildPaymentMethod(),

            const SizedBox(height: 30),

            // --- Order Summary & Confirm Button ---
            _buildBottomSummary(context),
          ],
        ),
      ),
    );
  }

  // --- Horizontal Stepper (Active Step 2: Details) ---
  Widget _buildStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepCircle("1", "My Order", true, isCompleted: true),
          _stepLine(true),
          _stepCircle("2", "Details", true),
          _stepLine(false),
          _stepCircle("3", "Payment", false),
        ],
      ),
    );
  }

  Widget _stepCircle(String number, String label, bool isActive, {bool isCompleted = false}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isActive ? const Color(0xFF233933) : Colors.black.withOpacity(0.05),
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : Text(number, style: TextStyle(color: isActive ? Colors.white : Colors.grey)),
        ),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? Colors.black : Colors.grey)),
      ],
    );
  }

  Widget _stepLine(bool isFinished) {
    return Container(width: 50, height: 2, color: isFinished ? const Color(0xFF233933) : Colors.black12, margin: const EdgeInsets.only(bottom: 20));
  }

  // --- Section Header ---
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  // --- Address Card ---
  Widget _buildAddressCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: Colors.green),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Home Address', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Main Street, I-8 Islamabad', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () {}),
        ],
      ),
    );
  }

  // --- Delivery Method ---
  Widget _buildDeliveryMethod() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping_outlined, color: Colors.orange),
              SizedBox(width: 15),
              Text('Standard Delivery (Free)', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }

  // --- Payment Method ---
  Widget _buildPaymentMethod() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.credit_card, color: Colors.blue),
              SizedBox(width: 15),
              Text('Visa Card (.... 4242)', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          Icon(Icons.keyboard_arrow_right),
        ],
      ),
    );
  }

  // --- Bottom Summary ---
  Widget _buildBottomSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          _summaryRow('Order Total :', '105£'),
          _summaryRow('Delivery :', 'Free'),
          const Divider(),
          _summaryRow('Grand Total :', '105£', isTotal: true),
          const SizedBox(height: 20),
          PrimaryButton(
              text: 'Confirm Order',
              onPressed: () {
                // Yahan Success Page dikhayenge
              }
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 14)),
        ],
      ),
    );
  }
}