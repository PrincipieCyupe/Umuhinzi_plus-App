import 'package:flutter/material.dart';

class CategoryTabBar extends StatefulWidget {
  final String activeCategory;
  final Function(String) onCategorySelected;

  const CategoryTabBar({
    super.key,
    required this.activeCategory,
    required this.onCategorySelected,
  });

  @override
  State<CategoryTabBar> createState() => _CategoryTabBarState();
}

class _CategoryTabBarState extends State<CategoryTabBar>
    with SingleTickerProviderStateMixin {
  static const _categories = ['All', 'Vegetables', 'Fruits', 'Grains'];
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    final initialIndex = _categories.indexOf(widget.activeCategory);
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
      initialIndex: initialIndex < 0 ? 0 : initialIndex,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        widget.onCategorySelected(_categories[_tabController.index]);
      }
    });
  }

  @override
  void didUpdateWidget(CategoryTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIndex = _categories.indexOf(widget.activeCategory);
    if (newIndex >= 0 && newIndex != _tabController.index) {
      _tabController.animateTo(newIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: _tabController,
      tabs: _categories.map((c) => Tab(text: c)).toList(),
      labelColor: const Color(0xFF3FAE4A),
      unselectedLabelColor: Colors.black54,
      indicatorColor: const Color(0xFF3FAE4A),
      indicatorWeight: 3,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
    );
  }
}
