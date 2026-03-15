import '../../core/constants/rwanda_data.dart';
import '../../domain/entities/weather_entity.dart';
import '../services/weather_service.dart';

/// Weather Repository - Data Layer
/// Abstracts the weather service and provides clean interface
class WeatherRepository {
  final WeatherService _weatherService;

  WeatherRepository({required WeatherService weatherService})
    : _weatherService = weatherService;

  /// Get weather by district name
  /// Uses the district coordinates mapping
  Future<WeatherEntity> getWeatherByDistrict(String districtName) async {
    // Get coordinates from district name
    final coordinates = RwandaDistricts.getCoordinates(districtName);

    if (coordinates == null) {
      throw Exception(
        'District "$districtName" not found in coordinates database',
      );
    }

    return await _weatherService.getWeatherByCoordinates(
      lat: coordinates['lat']!,
      lon: coordinates['lon']!,
      districtName: districtName,
    );
  }

  /// Get weather by coordinates directly
  Future<WeatherEntity> getWeatherByCoordinates({
    required double lat,
    required double lon,
    required String locationName,
  }) async {
    return await _weatherService.getWeatherByCoordinates(
      lat: lat,
      lon: lon,
      districtName: locationName,
    );
  }

  /// Get weather by city name
  Future<WeatherEntity> getWeatherByCity(String cityName) async {
    return await _weatherService.getWeatherByCity(cityName: cityName);
  }
}
