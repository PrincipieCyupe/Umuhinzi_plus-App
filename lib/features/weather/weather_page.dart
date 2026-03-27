import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:umuhinzi_plus/core/constants/rwanda_data.dart';
import 'package:umuhinzi_plus/features/home/presentation/bloc/weather/weather_bloc.dart';
import 'package:umuhinzi_plus/features/home/presentation/bloc/weather/weather_state.dart';
import 'package:umuhinzi_plus/features/home/presentation/bloc/weather/weather_event.dart';
import 'package:umuhinzi_plus/features/home/domain/entities/weather_entity.dart';
import '../home/screens/Custom/app_drawer.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 1;

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

    context.read<WeatherBloc>().add(FetchWeatherByDistrict(districtName: district));
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        userEmail: "farmer@umuhinzi.rw",
        userName: "Umuhinzi User",
        onLogout: () {},
        onUpdateProfile: () {},
      ),
      appBar: _buildAppBar(),
      body: _selectedIndex == 1 ? _buildWeatherBody() : _buildPlaceholderBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildWeatherBody() {
    return BlocConsumer<WeatherBloc, WeatherState>(
      listener: (context, state) {
        if (state is WeatherError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is WeatherLoading) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchField(),
              const SizedBox(height: 20),
              const Text("Welcome", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Text("Check today's updates for your farm and how weather can affect it",
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              
              if (state is WeatherLoaded) 
                _buildWeatherDisplay(state.weather)
              else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text("Search for a Rwanda district (e.g., Musanze)"),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeatherDisplay(WeatherEntity weather) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. Main Green Card (Updated Layout) ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Weather Details (Top Left)
              const Text("Today's Weather", style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text(weather.districtName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("${weather.temperature.round()}°",
                  style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
              Text(weather.weatherMain, style: const TextStyle(color: Colors.white70, fontSize: 16)),
              
              const SizedBox(height: 30),

              // Hourly Forecast Spread out (Bottom Center)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    weather.hourlyForecast.isEmpty ? 4 : (weather.hourlyForecast.length > 4 ? 4 : weather.hourlyForecast.length),
                    (index) {
                      if (weather.hourlyForecast.isEmpty) return _buildEmptyHourly();
                      final w = weather.hourlyForecast[index];
                      final hourLabel = index == 0 ? "Now" : DateFormat('ha').format(w.dateTime);
                      
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(hourLabel, style: const TextStyle(color: Colors.white, fontSize: 12)),
                          const SizedBox(height: 4),
                          Image.network(w.iconUrl, width: 28),
                          const SizedBox(height: 4),
                          Text("${w.temperature.round()}°", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),

        // --- 2. Summary Box (Green Text) ---
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Today's Weather", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                    Text(weather.districtName, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    Text(
                      "${weather.temperature.round()}° ${weather.weatherDescription}",
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => context.read<WeatherBloc>().add(FetchWeatherByDistrict(districtName: weather.districtName)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                    child: const Text("Refresh", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // --- 3. Humidity & Wind (Icon Instead of Bar) ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildIndicator("Humidity", weather.humidity / 100, "${weather.humidity}%", Colors.blue),
            const SizedBox(width: 15),
            _buildWindIndicator("Wind Speed", weather.windSpeedString, Colors.orange),
          ],
        ),
        const SizedBox(height: 25),

        // --- 4. 5-Day Forecast (Full Width Stretch) ---
        const Text("5-Day Forecast", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: List.generate(
            weather.dailyForecast.isEmpty ? 5 : (weather.dailyForecast.length > 5 ? 5 : weather.dailyForecast.length),
            (index) {
              if (weather.dailyForecast.isEmpty) return Expanded(child: _buildForecastCard("--", "", "--"));
              final day = weather.dailyForecast[index];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == 4 ? 0 : 8),
                  child: _buildForecastCard(
                    DateFormat('E').format(day.dateTime), 
                    day.iconUrl, 
                    "${day.temperature.round()}°"
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Helper Components ---

  Widget _buildWindIndicator(String label, String text, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.air, color: color, size: 28),
              const SizedBox(width: 10),
              Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(String label, double value, String text, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: value, color: color, backgroundColor: Colors.grey[300], minHeight: 10),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildForecastCard(String day, String iconUrl, String temp) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade50, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: Colors.green.shade100)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          iconUrl.isEmpty ? const Icon(Icons.cloud_queue, size: 24) : Image.network(iconUrl, width: 24),
          const SizedBox(height: 4),
          Text(temp, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildEmptyHourly() {
    return Column(children: const [
      Text("--", style: TextStyle(color: Colors.white)), 
      SizedBox(height: 10), 
      Text("--", style: TextStyle(color: Colors.white))
    ]);
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
          children: [
            TextSpan(text: "UMUHIN", style: TextStyle(color: Colors.green.shade700)),
            TextSpan(text: "ZI+", style: TextStyle(color: Colors.yellow.shade700)),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
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
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFF6F4EB), borderRadius: BorderRadius.circular(10)),
      child: TextField(
        controller: _searchController,
        onSubmitted: (_) => _onSearch(),
        decoration: InputDecoration(
          hintText: "Search for a District",
          border: InputBorder.none,
          icon: const Icon(Icons.search),
          suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward), onPressed: _onSearch),
        ),
      ),
    );
  }

  Widget _buildPlaceholderBody() => Center(child: Text("Page $_selectedIndex Coming Soon"));
}