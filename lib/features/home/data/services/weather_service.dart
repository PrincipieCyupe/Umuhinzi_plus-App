import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _baseUrl = 'https://open-weather13.p.rapidapi.com/fivedaysforcast';
  static const String _apiKey = 'ea028c6133msh9af7cf768a80606p1edd64jsnb9fdfa8ec4fe';
  static const String _apiHost = 'open-weather13.p.rapidapi.com';

  WeatherService();

  // Change return type to Future<Map<String, dynamic>> to keep the forecast list!
  Future<Map<String, dynamic>> getWeatherRawData({
    required double lat,
    required double lon,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'latitude': lat.toString(),
        'longitude': lon.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'x-rapidapi-key': _apiKey,
        'x-rapidapi-host': _apiHost,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch: ${response.statusCode}');
    }
  }
}