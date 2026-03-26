import 'package:flutter/material.dart';

// TipsSearchBar - real-time search for crop topics or news
class TipsSearchBar extends StatelessWidget {
  final Function(String) onSearch;

  const TipsSearchBar({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4EB), // Light greyish-yellow matching Home
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: onSearch,
        decoration: const InputDecoration(
          hintText: "Search Crop Topics Or News",
          hintStyle: TextStyle(color: Colors.black54),
          prefixIcon: Icon(Icons.search, color: Colors.black54),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
