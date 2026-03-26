import 'package:flutter/material.dart';
import 'features/weather/weather_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather Test',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const WeatherPage(),
    );
  }
}