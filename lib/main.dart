import 'package:flutter/material.dart';

void main() {
  runApp(const Home());
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeContent());
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  static List<TextStyle> appstyle = [
    TextStyle(fontWeight: FontWeight.bold),
    TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
  ];
  List<Widget> laterwidgets = [
    Text("Future home page", style: appstyle[1]),
    Text("Future Weather page", style: appstyle[1]),
    Text("Future Market page", style: appstyle[1]),
    Text("Future Tips and Update page", style: appstyle[1]),
  ];
  List<String> items = ["Home", "Weather", "Market", "Tips & Updates"];

  int _selectedIndex = 0;
  void _onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      body: Center(child: laterwidgets.elementAt(_selectedIndex)),
      appBar: AppBar(title: Text("Umuhinzi+", style: appstyle[0])),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: items[0]),
          BottomNavigationBarItem(icon: Icon(Icons.wb_sunny), label: items[1]),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: items[2],
          ),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: items[3]),
        ],
        currentIndex: _selectedIndex,
        onTap: _onTapped,
        unselectedItemColor: Colors.green,
        selectedItemColor: Colors.orangeAccent,
      ),
    );
  }
}
