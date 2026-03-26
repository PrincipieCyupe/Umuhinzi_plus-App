import '../../domain/entities/tip_entity.dart';

// This model helps us convert tip data to and from JSON
class TipModel extends TipEntity {
  const TipModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.category,
    super.videoUrl,
    required super.date,
  });

  // This helps us create a tip from a map of data
  factory TipModel.fromJson(Map<String, dynamic> json) {
    return TipModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      videoUrl: json['videoUrl'] as String?,
      date: DateTime.parse(json['date'] as String),
    );
  }

  // This converts our tip object back into a map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'videoUrl': videoUrl,
      'date': date.toIso8601String(),
    };
  }
}
