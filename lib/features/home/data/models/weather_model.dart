import '../../domain/entities/weather_entity.dart';

/// Weather Model - Data Layer
/// Handles JSON parsing from RapidAPI OpenWeather 5-day Forecast API
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
  });

  /// Factory constructor to create WeatherModel from RapidAPI 5-day forecast JSON
  /// The API returns 'list' array with forecast data, we take the first item (current)
  factory WeatherModel.fromJson(
    Map<String, dynamic> json,
    String districtName,
  ) {
    // Handle 5-day forecast API response format
    final list = json['list'] as List?;

    // Use first forecast item as current weather
    Map<String, dynamic> forecast;
    if (list != null && list.isNotEmpty) {
      forecast = list[0] as Map<String, dynamic>;
    } else {
      // Fallback to direct response (current weather endpoint)
      forecast = json;
    }

    final main = forecast['main'] as Map<String, dynamic>? ?? {};
    final wind = forecast['wind'] as Map<String, dynamic>? ?? {};
    final clouds = forecast['clouds'] as Map<String, dynamic>? ?? {};
    final weather =
        (forecast['weather'] as List?)?.first as Map<String, dynamic>? ?? {};

    // Get city info from the 'city' field (5-day API)
    final city = json['city'] as Map<String, dynamic>?;
    final sys = city?['country'] != null
        ? {
            'country': city!['country'],
            'sunrise': city['sunrise'],
            'sunset': city['sunset'],
          }
        : forecast['sys'] as Map<String, dynamic>? ?? {};

    // Get coordinates from 'city' or 'coord' field
    Map<String, dynamic>? coord;
    if (city?['coord'] != null) {
      coord = city!['coord'] as Map<String, dynamic>;
    } else {
      coord = json['coord'] as Map<String, dynamic>?;
    }

    // Temperature is in Kelvin by default! Convert to Celsius
    // Kelvin to Celsius: C = K - 273.15
    double tempKelvin = (main['temp'] as num?)?.toDouble() ?? 0.0;
    double feelsLikeKelvin = (main['feels_like'] as num?)?.toDouble() ?? 0.0;
    double tempMinKelvin = (main['temp_min'] as num?)?.toDouble() ?? 0.0;
    double tempMaxKelvin = (main['temp_max'] as num?)?.toDouble() ?? 0.0;

    return WeatherModel(
      latitude: coord?['lat'] != null ? (coord!['lat'] as num).toDouble() : 0.0,
      longitude: coord?['lon'] != null
          ? (coord!['lon'] as num).toDouble()
          : 0.0,
      districtName: districtName,
      country: 'RW', // Always Rwanda - the coordinates are in Rwanda
      weatherMain: weather['main'] as String? ?? 'Unknown',
      weatherDescription: weather['description'] as String? ?? 'No description',
      weatherIcon: weather['icon'] as String? ?? '01d',
      temperature: _kelvinToCelsius(tempKelvin),
      feelsLike: _kelvinToCelsius(feelsLikeKelvin),
      tempMin: _kelvinToCelsius(tempMinKelvin),
      tempMax: _kelvinToCelsius(tempMaxKelvin),
      pressure: main['pressure'] as int? ?? 0,
      humidity: main['humidity'] as int? ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      windGust: (wind['gust'] as num?)?.toDouble() ?? 0.0,
      windDeg: wind['deg'] as int? ?? 0,
      visibility: forecast['visibility'] as int? ?? 10000,
      clouds: clouds['all'] as int? ?? 0,
      sunrise: _parseDateTime(sys['sunrise']),
      sunset: _parseDateTime(sys['sunset']),
      dateTime: _parseDateTime(forecast['dt']),
    );
  }

  /// Convert Kelvin to Celsius
  static double _kelvinToCelsius(double kelvin) {
    return kelvin - 273.15;
  }

  /// Helper to parse datetime from unix timestamp or ISO string
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// Convert to JSON (for caching)
  Map<String, dynamic> toJson() {
    return {
      'coord': {'lat': latitude, 'lon': longitude},
      'weather': [
        {
          'main': weatherMain,
          'description': weatherDescription,
          'icon': weatherIcon,
        },
      ],
      'main': {
        'temp': temperature,
        'feels_like': feelsLike,
        'temp_min': tempMin,
        'temp_max': tempMax,
        'pressure': pressure,
        'humidity': humidity,
      },
      'wind': {'speed': windSpeed, 'deg': windDeg, 'gust': windGust},
      'clouds': {'all': clouds},
      'visibility': visibility,
      'sys': {
        'country': country,
        'sunrise': sunrise.millisecondsSinceEpoch ~/ 1000,
        'sunset': sunset.millisecondsSinceEpoch ~/ 1000,
      },
      'dt': dateTime.millisecondsSinceEpoch ~/ 1000,
    };
  }
}
