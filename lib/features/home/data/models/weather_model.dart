import '../../domain/entities/weather_entity.dart';

class WeatherModel extends WeatherEntity {
  const WeatherModel({
    required super.latitude,
    required super.longitude,
    required super.districtName,
    required super.country,
    required super.weatherMain,
    required super.weatherDescription,
    required super.weatherIcon,
    required super.temperature,
    required super.feelsLike,
    required super.tempMin,
    required super.tempMax,
    required super.pressure,
    required super.humidity,
    required super.windSpeed,
    required super.windGust,
    required super.windDeg,
    required super.visibility,
    required super.clouds,
    required super.sunrise,
    required super.sunset,
    required super.dateTime,
    super.hourlyForecast = const [], 
    super.dailyForecast = const [],
  });

  factory WeatherModel.fromJson(
    Map<String, dynamic> json,
    String districtName,
  ) {
    // Determine if this is the full response or a nested forecast item
    final list = json['list'] as List?;
    final Map<String, dynamic> data = (list != null && list.isNotEmpty) 
        ? list[0] as Map<String, dynamic> 
        : json;

    final main = data['main'] as Map<String, dynamic>? ?? {};
    final wind = data['wind'] as Map<String, dynamic>? ?? {};
    final clouds = data['clouds'] as Map<String, dynamic>? ?? {};
    final weather = (data['weather'] as List?)?.first as Map<String, dynamic>? ?? {};

    // For coordinates and sys, look in the 'city' object if available
    final city = json['city'] as Map<String, dynamic>?;
    final sys = data['sys'] as Map<String, dynamic>? ?? city ?? {};

    Map<String, dynamic>? coord = city?['coord'] ?? json['coord'];

    return WeatherModel(
      latitude: (coord?['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (coord?['lon'] as num?)?.toDouble() ?? 0.0,
      districtName: districtName,
      country: city?['country'] as String? ?? 'RW',
      weatherMain: weather['main'] as String? ?? 'Unknown',
      weatherDescription: weather['description'] as String? ?? 'No description',
      weatherIcon: weather['icon'] as String? ?? '01d',
      temperature: _kelvinToCelsius((main['temp'] as num?)?.toDouble() ?? 0.0),
      feelsLike: _kelvinToCelsius((main['feels_like'] as num?)?.toDouble() ?? 0.0),
      tempMin: _kelvinToCelsius((main['temp_min'] as num?)?.toDouble() ?? 0.0),
      tempMax: _kelvinToCelsius((main['temp_max'] as num?)?.toDouble() ?? 0.0),
      pressure: main['pressure'] as int? ?? 0,
      humidity: main['humidity'] as int? ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      windGust: (wind['gust'] as num?)?.toDouble() ?? 0.0,
      windDeg: wind['deg'] as int? ?? 0,
      visibility: data['visibility'] as int? ?? 10000,
      clouds: clouds['all'] as int? ?? 0,
      sunrise: _parseDateTime(sys['sunrise']),
      sunset: _parseDateTime(sys['sunset']),
      dateTime: _parseDateTime(data['dt'] ?? data['dt_txt']),
      hourlyForecast: [],
      dailyForecast: [],
    );
  }

  static double _kelvinToCelsius(double kelvin) => kelvin - 273.15;

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}