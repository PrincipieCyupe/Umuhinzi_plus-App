import 'package:flutter/material.dart';

/// A search bar for filtering market produce.
class MarketSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String initialValue;

  const MarketSearchBar({
    super.key,
    required this.onSearch,
    this.initialValue = '',
  });

  @override
  State<MarketSearchBar> createState() => _MarketSearchBarState();
}

class _MarketSearchBarState extends State<MarketSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF7F0), // Off-white cream color from design
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onSearch,
        decoration: InputDecoration(
          hintText: 'Search for a plants market trends',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _controller.clear();
                    widget.onSearch('');
                  },
                )
              : null,
        ),
      ),
    );
  }
}
