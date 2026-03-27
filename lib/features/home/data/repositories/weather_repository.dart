import '../../../../core/constants/rwanda_data.dart';
import '../../domain/entities/weather_entity.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';

class WeatherRepository {
  final WeatherService _weatherService;

  WeatherRepository({required WeatherService weatherService})
      : _weatherService = weatherService;

  Future<WeatherEntity> getWeatherByDistrict(String districtName) async {
    final coordinates = RwandaDistricts.getCoordinates(districtName);

    if (coordinates == null) {
      throw Exception('District "$districtName" not found in Rwanda');
    }

    return await getWeatherByCoordinates(
      lat: coordinates['lat']!,
      lon: coordinates['lon']!,
      locationName: districtName,
    );
  }

  // 2. Updated Coordinates Method
  Future<WeatherEntity> getWeatherByCoordinates({
    required double lat,
    required double lon,
    required String locationName,
  }) async {
    try {
      final Map<String, dynamic> rawData = await _weatherService.getWeatherRawData(
        lat: lat,
        lon: lon,
      );

      final List list = rawData['list'] as List? ?? [];
      final cityData = rawData['city'];

      // Create Current Weather object
      final current = WeatherModel.fromJson(rawData, locationName);

      // Parse Hourly
      final List<WeatherEntity> hourly = list.take(8).map((item) {
        return WeatherModel.fromJson(item as Map<String, dynamic>, locationName);
      }).toList();

      // Parse Daily
      final Map<String, WeatherEntity> dailyMap = {};
      for (var item in list) {
        final dtTxt = item['dt_txt'] as String? ?? "";
        if (dtTxt.isEmpty) continue;
        
        final dateKey = dtTxt.split(' ')[0];
        if (!dailyMap.containsKey(dateKey)) {
          dailyMap[dateKey] = WeatherModel.fromJson(item as Map<String, dynamic>, locationName);
        }
      }

      // Return the full Entity
      return WeatherEntity(
        latitude: current.latitude,
        longitude: current.longitude,
        districtName: current.districtName,
        country: current.country,
        weatherMain: current.weatherMain,
        weatherDescription: current.weatherDescription,
        weatherIcon: current.weatherIcon,
        temperature: current.temperature,
        feelsLike: current.feelsLike,
        tempMin: current.tempMin,
        tempMax: current.tempMax,
        pressure: current.pressure,
        humidity: current.humidity,
        windSpeed: current.windSpeed,
        windGust: current.windGust,
        windDeg: current.windDeg,
        visibility: current.visibility,
        clouds: current.clouds,
        sunrise: current.sunrise,
        sunset: current.sunset,
        dateTime: current.dateTime,
        hourlyForecast: hourly,
        dailyForecast: dailyMap.values.take(5).toList(),
      );
    } catch (e) {
      print("REPO ERROR: $e");
      rethrow;
    }
  }
}
