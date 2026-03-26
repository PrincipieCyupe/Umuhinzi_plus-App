/// Weather Entity - Domain Layer
/// Represents the core weather data structure
class WeatherEntity {
  final double latitude;
  final double longitude;
  final String districtName;
  final String country;
  final String weatherMain;
  final String weatherDescription;
  final String weatherIcon;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int pressure;
  final int humidity;
  final double windSpeed;
  final double windGust;
  final int windDeg;
  final int visibility;
  final int clouds;
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime dateTime;

  const WeatherEntity({
    required this.latitude,
    required this.longitude,
    required this.districtName,
    required this.country,
    required this.weatherMain,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    required this.windSpeed,
    required this.windGust,
    required this.windDeg,
    required this.visibility,
    required this.clouds,
    required this.sunrise,
    required this.sunset,
    required this.dateTime,
  });

  /// Get weather icon URL
  String get iconUrl => 'https://openweathermap.org/img/wn/$weatherIcon@2x.png';

  /// Get temperature as formatted string
  String get temperatureString => '${temperature.toStringAsFixed(1)}°C';

  /// Get feels like as formatted string
  String get feelsLikeString => '${feelsLike.toStringAsFixed(1)}°C';

  /// Get humidity as formatted string
  String get humidityString => '$humidity%';

  /// Get wind speed as formatted string
  String get windSpeedString => '${windSpeed.toStringAsFixed(1)} m/s';

  /// Get visibility as formatted string (km)
  String get visibilityString => '${(visibility / 1000).toStringAsFixed(1)} km';

  /// Get cloudiness as formatted string
  String get cloudsString => '$clouds%';
}
