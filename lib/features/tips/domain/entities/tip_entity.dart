import 'package:equatable/equatable.dart';

// Tip entity - base class for agricultural tips
class TipEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category; // 'Post' | 'Video' | 'Article'
  final DateTime date;

  const TipEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.date,
  });

  @override
  List<Object?> get props => [id, title, description, imageUrl, category, date];
}
