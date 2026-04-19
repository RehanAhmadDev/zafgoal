import 'package:flutter/material.dart';
import 'package:zafgoal/core/theme/app_colors.dart';
import 'package:zafgoal/shared/widgets/custom_text_field.dart';

class SearchResultsPage extends StatelessWidget {
  final String searchQuery;
  const SearchResultsPage({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Search Results', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // Filter Button
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.primaryDark),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Active Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: CustomTextField(
              hintText: searchQuery,
              suffixIcon: const Icon(Icons.search, color: AppColors.primaryDark),
            ),
          ),

          const SizedBox(height: 10),

          // Results Count
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Found 12 Results', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
            ),
          ),

          const SizedBox(height: 15),

          // Grid of Products
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 0.75,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return _buildResultCard();
              },
            ),
          ),
        ],
      ),
    );
  }

  // Filter Popup dikhane wala method
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter By', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text('Price Range', style: TextStyle(fontWeight: FontWeight.bold)),
              RangeSlider(
                values: const RangeValues(10, 80),
                max: 100,
                divisions: 10,
                activeColor: AppColors.primaryDark,
                labels: const RangeLabels('£10', '£80'),
                onChanged: (values) {},
              ),
              const SizedBox(height: 20),
              const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  ChoiceChip(label: const Text('Lowest Price'), selected: true, selectedColor: AppColors.primaryDark.withOpacity(0.2)),
                  ChoiceChip(label: const Text('Highest Price'), selected: false),
                  ChoiceChip(label: const Text('Newest'), selected: false),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Apply Filters', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network('https://picsum.photos/200', fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fresh Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 4),
                Text('£4.50', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}