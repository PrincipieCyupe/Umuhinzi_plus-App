import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object?> get props => [];
}

class FetchWeatherByDistrict extends WeatherEvent {
  final String districtName;

  const FetchWeatherByDistrict({required this.districtName});

  @override
  List<Object?> get props => [districtName];
}

class FetchWeatherByCoordinates extends WeatherEvent {
  final double latitude;
  final double longitude;
  final String? locationName;

  const FetchWeatherByCoordinates({
    required this.latitude,
    required this.longitude,
    this.locationName,
  });

  @override
  List<Object?> get props => [latitude, longitude, locationName];
}

class FetchWeatherByCity extends WeatherEvent {
  final String cityName;

  const FetchWeatherByCity({required this.cityName});

  @override
  List<Object?> get props => [cityName];
}

class RefreshWeather extends WeatherEvent {
  const RefreshWeather();
}

class ClearWeather extends WeatherEvent {
  const ClearWeather();
}
