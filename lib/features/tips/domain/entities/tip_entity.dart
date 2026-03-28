import 'package:equatable/equatable.dart';

// This is the base data for a tip, like its id and title
class TipEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String body;
  final String imageUrl;
  final String category; // 'Post' | 'Video' | 'Article'
  final String? videoId; // YouTube video ID
  final DateTime date;

  const TipEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.body,
    required this.imageUrl,
    required this.category,
    this.videoId,
    required this.date,
  });

  @override
  List<Object?> get props => [id, title, description, body, imageUrl, category, videoId, date];
}
