/// Weather Entity - Domain Layer
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

  final List<WeatherEntity> hourlyForecast;
  final List<WeatherEntity> dailyForecast;

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
    this.hourlyForecast = const [], // Default to empty list
    this.dailyForecast = const [], 
  });

  String get iconUrl => 'https://openweathermap.org/img/wn/$weatherIcon@2x.png';
  String get temperatureString => '${temperature.round()}°'; // Changed to round for UI cleaness
  String get feelsLikeString => '${feelsLike.toStringAsFixed(1)}°C';
  String get humidityString => '$humidity%';
  
  // Updated to km/h to match your UI requirement
  String get windSpeedString => '${(windSpeed * 3.6).toStringAsFixed(1)} km/h';
}
