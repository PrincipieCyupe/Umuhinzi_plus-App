import '../entities/tip_entity.dart';

// This model helps us convert tip data to and from JSON
class TipModel extends TipEntity {
  const TipModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.category,
    required super.date,
  });

  // Convert JSON to model
  factory TipModel.fromJson(Map<String, dynamic> json) {
    return TipModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      category: json['category'],
      date: DateTime.parse(json['date']),
    );
  }

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'date': date.toIso8601String(),
    };
  }
}
