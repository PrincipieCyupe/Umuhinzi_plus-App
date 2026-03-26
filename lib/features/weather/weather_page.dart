import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:umuhinzi_plus/core/constants/rwanda_data.dart';
import 'package:umuhinzi_plus/features/home/data/models/weather_model.dart';
import 'package:umuhinzi_plus/features/home/data/services/weather_service.dart';
import 'package:umuhinzi_plus/features/home/screens/Custom/app_drawer.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherService _weatherService = WeatherService();

  bool _isLoading = false;
  String _locationName = "";
  WeatherModel? _currentWeather;

  List<WeatherModel> hourlyWeather = [];
  List<WeatherModel> dailyWeather = [];

  final TextEditingController _searchController = TextEditingController();

  static const String _baseUrl =
      'https://open-weather13.p.rapidapi.com/fivedaysforcast';
  static const String _apiKey =
      'a8c3cf7301mshbc7038fce89b4a8p1fc78fjsndb42a59b59f1';
  static const String _apiHost = 'open-weather13.p.rapidapi.com';

  int _selectedIndex = 1;

  Future<void> _fetchWeather(String district) async {
    setState(() => _isLoading = true);

    try {
      final coords = RwandaDistricts.getCoordinates(district);
      if (coords == null) throw Exception("Invalid district");

      final current = await _weatherService.getWeatherByCoordinates(
        lat: coords['lat']!,
        lon: coords['lon']!,
        districtName: district,
      );

      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'latitude': coords['lat']!.toString(),
        'longitude': coords['lon']!.toString(),
        'lang': 'EN',
      });

      final response = await http.get(uri, headers: {
        'x-rapidapi-key': _apiKey,
        'x-rapidapi-host': _apiHost,
      });

      final json = jsonDecode(response.body);
      final list = json['list'] as List;

      hourlyWeather = list.take(4).map((item) {
        return WeatherModel.fromJson({
          'list': [item],
          'city': json['city'],
        }, district);
      }).toList();

      final Map<String, WeatherModel> dailyMap = {};
      for (var item in list) {
        final dt = DateTime.parse(item['dt_txt']);
        final key = "${dt.year}-${dt.month}-${dt.day}";
        if (!dailyMap.containsKey(key)) {
          dailyMap[key] = WeatherModel.fromJson({
            'list': [item],
            'city': json['city'],
          }, district);
        }
      }

      dailyWeather = dailyMap.values.take(5).toList();
      _currentWeather = current;
      _locationName = district;

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _onSearch() {
    final input = _searchController.text.trim().toLowerCase();
    if (input.isEmpty) return;

    final district = RwandaDistricts.allDistricts.firstWhere(
      (d) => d.toLowerCase() == input,
      orElse: () => '',
    );

    if (district.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("District not found in Rwanda")),
      );
      return;
    }

    _fetchWeather(district);
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    if (_selectedIndex == 1) {
      bodyContent = _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F4EB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (_) => _onSearch(),
                      decoration: InputDecoration(
                        hintText: "Search for a District",
                        border: InputBorder.none,
                        icon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: _onSearch,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Welcome",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text(
                    "Check today's updates for your farm and how weather can affect it",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text("Today's Weather",
                            style: TextStyle(color: Colors.white70, fontSize: 14)),
                        Text(
                          _locationName.isEmpty ? "No district selected" : _locationName,
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          _currentWeather == null ? "--" : _currentWeather!.temperatureString,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 60,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _currentWeather == null ? "--" : _currentWeather!.weatherMain,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: hourlyWeather.isEmpty ? 4 : hourlyWeather.length,
                            itemBuilder: (context, index) {
                              if (hourlyWeather.isEmpty) {
                                return Container(
                                  width: 60,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: Column(
                                    children: const [
                                      Text("--", style: TextStyle(color: Colors.white)),
                                      SizedBox(height: 10),
                                      Text("--", style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                );
                              }
                              final w = hourlyWeather[index];
                              final dt = w.dateTime;
                              final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
                              final period = dt.hour < 12 ? "AM" : "PM";
                              final hour = index == 0 ? "Now" : "$hour12$period";

                              return Container(
                                width: 60,
                                margin: const EdgeInsets.only(right: 12),
                                child: Column(
                                  children: [
                                    Text(hour, style: const TextStyle(color: Colors.white)),
                                    Image.network(w.iconUrl, width: 30),
                                    Text("${w.temperature.round()}°",
                                        style: const TextStyle(color: Colors.white)),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Humidity",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            LinearProgressIndicator(
                              value: (_currentWeather?.humidity ?? 0) / 100,
                              color: Colors.blue,
                              backgroundColor: Colors.grey[300],
                              minHeight: 14,
                            ),
                            const SizedBox(height: 4),
                            Text("${_currentWeather?.humidity ?? 0}%",
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.air, color: Colors.orange, size: 28),
                            const SizedBox(width: 8),
                            Text("${(_currentWeather?.windSpeed ?? 0).toStringAsFixed(1)} km/h",
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: List.generate(4, (index) {
                      if (hourlyWeather.isEmpty) {
                        return _buildTempRow(index == 0 ? "Now" : "--", "--");
                      }
                      final w = hourlyWeather[index];
                      final dt = w.dateTime;
                      final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
                      final period = dt.hour < 12 ? "AM" : "PM";
                      final timeLabel = index == 0 ? "Now" : "$hour12$period";
                      return _buildTempRow(timeLabel, "${w.temperature.round()}°");
                    }),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      5,
                      (index) {
                        if (dailyWeather.isEmpty) {
                          return _buildForecastCard("--", "--", "--");
                        }
                        final day = dailyWeather[index];
                        const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        return _buildForecastCard(
                          weekdays[day.dateTime.weekday - 1],
                          day.iconUrl,
                          "${day.temperature.round()}°",
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
    } else {
      String label = "";
      if (_selectedIndex == 0) label = "Future Home Page";
      if (_selectedIndex == 2) label = "Future Market Page";
      if (_selectedIndex == 3) label = "Future Tips Page";
      bodyContent = Center(child: Text(label, style: const TextStyle(fontSize: 24)));
    }

    return Scaffold(
      drawer: AppDrawer(
        userEmail: "farmer@umuhinzi.rw", 
        userName: "Umuhinzi User",
        onLogout: () {},
        onUpdateProfile: () {},
      ),
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
            children: [
              TextSpan(text: "UMUHIN", style: TextStyle(color: Colors.green.shade700)),
              TextSpan(text: "ZI+", style: TextStyle(color: Colors.yellow.shade700)),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.wb_sunny, color: Colors.orange.shade400),
          )
        ],
      ),
      body: bodyContent,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.green.shade700,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.wb_sunny), label: "Weather"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Market"),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline), label: "Tips"),
        ],
      ),
    );
  }

  Widget _buildTempRow(String timeLabel, String temp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(timeLabel, style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFD2B48C), borderRadius: BorderRadius.circular(8)),
            child: Text(temp, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastCard(String day, String iconUrl, String temp) {
    return Container(
      width: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(day),
          iconUrl == "--" ? const SizedBox(height: 30, width: 30) : Image.network(iconUrl, width: 30),
          Text(temp),
        ],
      ),
    );
  }
}
