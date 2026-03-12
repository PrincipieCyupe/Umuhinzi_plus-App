import 'package:flutter/material.dart';

/// A custom bottom navigation bar for the Umuhinzi+ app.
class UmuhinziBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const UmuhinziBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: const Color(0xFF4CAF50),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.cloud_outlined),
          activeIcon: Icon(Icons.cloud),
          label: 'Weather',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: 'Market',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.lightbulb_outline),
          activeIcon: Icon(Icons.lightbulb),
          label: 'Tips & Updates',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
      ],
    );
  }
}
