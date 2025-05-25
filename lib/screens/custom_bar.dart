import 'package:flutter/material.dart';

class CustomBar extends StatelessWidget {
  final Function(String) onSearch;
  final List<String> categories;
  final String? selectedCategory;
  final Function(String?) onCategorySelected;
  final List<String> suggestions;
  final Function(String) onSuggestionTap;

  CustomBar({
    required this.onSearch,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade300, Colors.teal.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4), // Bayangan lebih halus
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: onSearch,
                      decoration: InputDecoration(
                        hintText: 'Cari hewan, makanan, dan lainnya...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.search, color: Colors.white),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Menampilkan daftar saran jika ada
        if (suggestions.isNotEmpty)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(suggestions[index]),
                  onTap: () {
                    onSuggestionTap(suggestions[index]); // Ketika saran dipilih
                  },
                );
              },
            ),
          ),
        Container(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1, // +1 untuk tombol "Semua"
            itemBuilder: (context, index) {
              // Tambahkan tombol "Semua" di awal
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ChoiceChip(
                    label: Text("Semua"),
                    selected: selectedCategory == null,
                    onSelected: (bool selected) {
                      onCategorySelected(null); // Reset kategori
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.teal,
                    labelStyle: TextStyle(
                      color: selectedCategory == null
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                );
              }

              // Tombol kategori lainnya
              final category = categories[index - 1];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ChoiceChip(
                  label: Text(category),
                  selected: selectedCategory == category,
                  onSelected: (bool selected) {
                    if (selected) {
                      if (selectedCategory == category) {
                        onCategorySelected(null); // Reset kategori
                      } else {
                        onCategorySelected(category); // Pilih kategori baru
                      }
                    }
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.teal,
                  labelStyle: TextStyle(
                    color: selectedCategory == category
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
