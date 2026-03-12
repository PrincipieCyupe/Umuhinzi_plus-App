import 'package:flutter/material.dart';

/// A custom tab bar for selecting produce categories.
class CategoryTabBar extends StatelessWidget {
  final String activeCategory;
  final Function(String) onCategorySelected;

  const CategoryTabBar({
    super.key,
    required this.activeCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ['Vegetables', 'Fruits', 'Grains'];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isActive = activeCategory == category;

          return GestureDetector(
            onTap: () => onCategorySelected(category),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isActive
                        ? const Color(0xFF4CAF50)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isActive ? const Color(0xFF4CAF50) : Colors.grey[600],
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
