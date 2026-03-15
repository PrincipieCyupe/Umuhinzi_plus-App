import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

/// Weather Service - Data Layer
/// Handles API calls to RapidAPI OpenWeather
class WeatherService {
  // RapidAPI credentials
  static const String _baseUrl =
      'https://open-weather13.p.rapidapi.com/fivedaysforcast';
  static const String _apiKey =
      'a8c3cf7301mshbc7038fce89b4a8p1fc78fjsndb42a59b59f1';
  static const String _apiHost = 'open-weather13.p.rapidapi.com';

  // Empty constructor
  WeatherService();

  /// Fetch 5-day weather forecast by coordinates
  /// Returns WeatherModel (current weather) on success
  /// Throws Exception on failure
  Future<WeatherModel> getWeatherByCoordinates({
    required double lat,
    required double lon,
    required String districtName,
  }) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'latitude': lat.toString(),
          'longitude': lon.toString(),
          'lang': 'EN',
        },
      );

      final response = await http
          .get(
            uri,
            headers: {
              'x-rapidapi-key': _apiKey,
              'x-rapidapi-host': _apiHost,
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet.',
              );
            },
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherModel.fromJson(json, districtName);
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your configuration.');
      } else if (response.statusCode == 404) {
        throw Exception('Location not found.');
      } else {
        throw Exception('Failed to fetch weather data: ${response.statusCode}');
      }
    } on FormatException {
      throw Exception('Invalid response format from server.');
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('HandshakeException')) {
        throw Exception(
          'Network error. Please check your internet connection.',
        );
      }
      rethrow;
    }
  }

  /// Fetch weather data by city name
  /// Returns WeatherModel on success
  Future<WeatherModel> getWeatherByCity({required String cityName}) async {
    // For city-based requests, we'll use coordinates from the district
    // This is a fallback - the main usage should be by coordinates
    throw Exception(
      'Please use district-based weather fetching with coordinates.',
    );
  }
}
