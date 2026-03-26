import 'package:flutter/material.dart';
import 'package:umuhinzi_plus/core/constant/rwanda_data.dart';
import 'package:umuhinzi_plus/features/home/data/services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  final String district;

  const WeatherPage({super.key, required this.district});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherService _weatherService = WeatherService();

  String _temp = "--";
  String _condition = "Loading...";
  String _humidity = "--";
  String _windSpeed = "--";
  String _locationName = "";
  bool _isLoading = false;

  List dailyWeather = [];

  Future<void> _getWeather() async {
    setState(() => _isLoading = true);

    try {
      final coords = RwandaDistricts.getCoordinates(widget.district);

      if (coords == null) {
        throw Exception("Invalid district");
      }

      final weather = await _weatherService.getWeatherByCoordinates(
        lat: coords['lat']!,
        lon: coords['lon']!,
        districtName: widget.district,
      );

      final forecasts = weather.forecastList;

      setState(() {
        _temp = "${weather.temperature.round()}°C";
        _condition = weather.weatherMain;
        _humidity = "${weather.humidity}%";
        _windSpeed = "${(weather.windSpeed * 3.6).round()} km/h";
        _locationName = weather.districtName;

        // 5-day selection (every 24h)
        if (forecasts.length >= 33) {
          dailyWeather = [
            forecasts[0],
            forecasts[8],
            forecasts[16],
            forecasts[24],
            forecasts[32],
          ];
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _locationName = widget.district;
    _getWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text('UMUHINZI+ Weather'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _getWeather,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      _locationName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Weather insights for your farm",
                      style: TextStyle(color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 20),

                    // MAIN CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [

                          Text(
                            _temp,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            _condition,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              _stat("Humidity", _humidity, Icons.water_drop),
                              _stat("Wind", _windSpeed, Icons.air),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 🌤️ 5-DAY FORECAST (HORIZONTAL)
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: dailyWeather.length,
                              itemBuilder: (context, index) {
                                final day = dailyWeather[index];

                                final temp =
                                    (day['main']['temp'] - 273.15).round();

                                final condition =
                                    day['weather'][0]['main'];

                                final date = day['dt_txt'];

                                return Container(
                                  width: 90,
                                  margin:
                                      const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [

                                      Text(
                                        date.substring(5, 10),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),

                                      const SizedBox(height: 6),

                                      Icon(
                                        _getWeatherIcon(condition),
                                        color: Colors.white,
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                        "$temp°C",
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _stat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'rain':
        return Icons.grain;
      case 'clouds':
        return Icons.cloud;
      case 'clear':
        return Icons.wb_sunny;
      default:
        return Icons.wb_cloudy;
    }
  }
}