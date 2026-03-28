import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../home/presentation/bloc/weather/weather_bloc.dart';
import '../home/presentation/bloc/weather/weather_event.dart';
import '../home/presentation/bloc/weather/weather_state.dart';
import '../home/domain/entities/weather_entity.dart';
import '../../../core/constants/rwanda_data.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final TextEditingController _searchController = TextEditingController();

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

    context.read<WeatherBloc>().add(
      FetchWeatherByDistrict(districtName: district),
    );
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
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
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchField(),
              const SizedBox(height: 20),
              const Text(
                "Welcome",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Check today's updates for your farm and how weather can affect it",
                style: TextStyle(color: Colors.grey),
              ),
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
    // Use same formatting as home screen for consistency
    final temp = weather.temperature.toStringAsFixed(0);
    final humidity = weather.humidity.toString();
    final windSpeed = weather.windSpeed.toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. Main Green Card ---
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
              const Text(
                "Today's Weather",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                weather.districtName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$temp°",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                weather.weatherMain,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),

              const SizedBox(height: 30),

              // Weather details row inside card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWeatherDetail(
                    Icons.water_drop,
                    "Humidity",
                    "$humidity%",
                  ),
                  _buildWeatherDetail(Icons.air, "Wind", "$windSpeed m/s"),
                  _buildWeatherDetail(Icons.thermostat, "Feels", "$temp°"),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),

        // --- 2. Summary Box ---
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Weather",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    weather.districtName,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "$temp° ${weather.weatherDescription}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.read<WeatherBloc>().add(
                  FetchWeatherByDistrict(districtName: weather.districtName),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Refresh",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // --- 3. Humidity & Wind ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildHumidityIndicator(
              "Humidity",
              weather.humidity / 100,
              "$humidity%",
              Colors.blue,
            ),
            const SizedBox(width: 15),
            _buildWindIndicator("Wind Speed", "$windSpeed m/s", Colors.orange),
          ],
        ),
        const SizedBox(height: 25),

        // --- 4. Additional Weather Details ---
        const Text(
          "Weather Details",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
            ],
          ),
          child: Column(
            children: [
              _buildDetailRow(
                "Min Temperature",
                "${weather.tempMin.toStringAsFixed(0)}°C",
              ),
              const Divider(),
              _buildDetailRow(
                "Max Temperature",
                "${weather.tempMax.toStringAsFixed(0)}°C",
              ),
              const Divider(),
              _buildDetailRow("Pressure", "${weather.pressure} hPa"),
              const Divider(),
              _buildDetailRow(
                "Visibility",
                "${(weather.visibility / 1000).toStringAsFixed(1)} km",
              ),
              const Divider(),
              _buildDetailRow("Cloudiness", "${weather.clouds}%"),
              const Divider(),
              _buildDetailRow("Sunrise", _formatTime(weather.sunrise)),
              const Divider(),
              _buildDetailRow("Sunset", _formatTime(weather.sunset)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildHumidityIndicator(
    String label,
    double value,
    String text,
    Color color,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: value,
            color: color,
            backgroundColor: Colors.grey[300],
            minHeight: 10,
          ),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildWindIndicator(String label, String text, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.air, color: color, size: 28),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4EB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: (_) => _onSearch(),
        decoration: InputDecoration(
          hintText: "Search for a farm's Location",
          border: InputBorder.none,
          icon: const Icon(Icons.search)
        ),
      ),
    );
  }
}
