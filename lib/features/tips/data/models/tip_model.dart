import '../../domain/entities/tip_entity.dart';

// This model helps us convert tip data to and from JSON
class TipModel extends TipEntity {
  const TipModel({
    required super.id,
    required super.title,
    required super.description,
    required super.body,
    required super.imageUrl,
    required super.category,
    super.videoId,
    required super.date,
  });

  // This helps us create a tip from a map of data
  factory TipModel.fromJson(Map<String, dynamic> json) {
    return TipModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      body: json['body'] as String? ?? '', // default empty string if missing
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      videoId: json['videoId'] as String?,
      date: DateTime.parse(json['date'] as String),
    );
  }

  // This converts our tip object back into a map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'body': body,
      'imageUrl': imageUrl,
      'category': category,
      'videoId': videoId,
      'date': date.toIso8601String(),
    };
  }
}
