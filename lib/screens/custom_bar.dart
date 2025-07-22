// File: custom_bar.dart

import 'package:flutter/material.dart';

class CustomBar extends StatelessWidget {
  final Function(String) onSearch;
  final List<String> categories;
  final String? selectedCategory;
  final Function(String?) onCategorySelected;
  final List<String> suggestions;
  final Function(String) onSuggestionTap;
  final TextEditingController searchController;

  const CustomBar({
    super.key,
    required this.onSearch,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.suggestions,
    required this.onSuggestionTap,
    required this.searchController,
  });

  // Di dalam file lib/screens/custom_bar.dart > class CustomBar

  @override
  Widget build(BuildContext context) {
    return Container(
      // PERBAIKAN: Kurangi padding atas dan bawah untuk membuat ukurannya lebih kecil
      padding: EdgeInsets.fromLTRB(
          16, // Padding kiri (tetap)
          MediaQuery.of(context).padding.top + 5, // Padding atas (dikurangi)
          16, // Padding kanan (tetap)
          8 // Padding bawah (dikurangi)
          ),
      color: Colors.transparent, // Pastikan latar belakang transparan
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade400, Colors.teal.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ],
            ),
            child: TextField(
              controller: searchController,
              onChanged: onSearch,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari hewan, fasilitas...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),

          if (suggestions.isNotEmpty) _buildSuggestionsList(),

          // Kurangi jarak antar elemen
          const SizedBox(height: 8),

          _buildCategoryChips(),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        shrinkWrap: true,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(suggestions[index]),
            onTap: () => onSuggestionTap(suggestions[index]),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Tombol "Semua"
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: const Text("Semua"),
                selected: selectedCategory == null,
                onSelected: (_) => onCategorySelected(null),
                selectedColor: Colors.teal,
                labelStyle: TextStyle(
                  color: selectedCategory == null ? Colors.white : Colors.black,
                ),
              ),
            );
          }

          final category = categories[index - 1];
          final isSelected = selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) =>
                  onCategorySelected(isSelected ? null : category),
              selectedColor: Colors.teal,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }
}
