import 'package:equatable/equatable.dart';

// This is the base data for a tip, like its id and title
class TipEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category; // 'Post' | 'Video' | 'Article'
  final String? videoUrl; // Link to YouTube video if available
  final String? articleUrl; // Full URL of the article to open in-app
  final DateTime date;

  const TipEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    this.videoUrl,
    this.articleUrl,
    required this.date,
  });

  @override
  List<Object?> get props => [id, title, description, imageUrl, category, videoUrl, articleUrl, date];
}
