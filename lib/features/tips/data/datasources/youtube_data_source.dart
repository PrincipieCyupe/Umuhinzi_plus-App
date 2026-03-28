import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/tip_model.dart';

class YoutubeDataSource {
  final http.Client client;

  YoutubeDataSource({required this.client});

  Future<List<TipModel>> fetchVideos() async {
    try {
      final url = Uri.parse(
          'https://www.googleapis.com/youtube/v3/search?part=snippet&q=agriculture%20Rwanda%20farming%20tips&type=video&maxResults=6&relevanceLanguage=en&key=${ApiConfig.youtubeApiKey}');
      
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;

        return items.map((item) {
          return TipModel(
            id: item['id']['videoId'] as String,
            title: item['snippet']['title'] as String,
            description: item['snippet']['description'] as String,
            body: item['snippet']['description'] as String,
            imageUrl: item['snippet']['thumbnails']['medium']['url'] as String,
            category: 'Video',
            videoId: item['id']['videoId'] as String,
            date: DateTime.parse(item['snippet']['publishedAt'] as String),
          );
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
