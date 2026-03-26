import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/tip_model.dart';

// This class fetches real data from YouTube and NewsAPI
abstract class TipsRemoteDataSource {
  Future<List<TipModel>> fetchTips();
}

class TipsRemoteDataSourceImpl implements TipsRemoteDataSource {
  final http.Client client;

  TipsRemoteDataSourceImpl({required this.client});

  @override
  Future<List<TipModel>> fetchTips() async {
    try {
      // Fetch from both sources
      final results = await Future.wait([
        _fetchYouTubeVideos(),
        _fetchNewsArticles(),
      ]);

      // Combine and sort by date descending
      final allTips = results.expand((list) => list).toList();
      allTips.sort((a, b) => b.date.compareTo(a.date));

      return allTips;
    } catch (e) {
      throw Exception('Failed to fetch tips from remote APIs: $e');
    }
  }

  // Source 1: YouTube Data API v3
  Future<List<TipModel>> _fetchYouTubeVideos() async {
    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/search'
      '?part=snippet&q=agriculture+Rwanda+farming+tips&type=video&maxResults=10&key=${ApiConfig.youtubeApiKey}',
    );

    final response = await client.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List items = data['items'] ?? [];

      return items.map((item) {
        final snippet = item['snippet'];
        final videoId = item['id']['videoId'];

        return TipModel(
          id: videoId,
          title: snippet['title'],
          description: snippet['description'],
          imageUrl: snippet['thumbnails']['medium']['url'],
          category: 'Video',
          videoUrl: 'https://www.youtube.com/watch?v=$videoId',
          date: DateTime.parse(snippet['publishedAt']),
        );
      }).toList();
    } else {
      throw Exception('YouTube API error: ${response.statusCode}');
    }
  }

  // Source 2: NewsAPI
  Future<List<TipModel>> _fetchNewsArticles() async {
    final url = Uri.parse(
      'https://newsapi.org/v2/everything'
      '?q=agriculture+Rwanda+farming&language=en&sortBy=publishedAt&pageSize=20&apiKey=${ApiConfig.newsApiKey}',
    );

    final response = await client.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List articles = data['articles'] ?? [];

      return articles.asMap().entries.map((entry) {
        final index = entry.key;
        final article = entry.value;

        return TipModel(
          id: article['url'],
          title: article['title'],
          description: article['description'] ?? '',
          imageUrl: article['urlToImage'] ?? 'https://placehold.co/400x200/e8f5e9/2e7d32?text=AgriNews',
          category: index % 2 == 0 ? 'Post' : 'Article',
          videoUrl: null,
          date: DateTime.parse(article['publishedAt']),
        );
      }).toList();
    } else {
      throw Exception('NewsAPI error: ${response.statusCode}');
    }
  }
}
