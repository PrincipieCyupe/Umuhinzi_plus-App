import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/produce_entity.dart';

/// Model class for produce data, extending [ProduceEntity].
class ProduceModel extends ProduceEntity {
  const ProduceModel({
    required super.id,
    required super.name,
    required super.price,
    required super.unit,
    required super.category,
    required super.imageUrl,
    required super.isAvailable,
    required super.updatedAt,
  });

  /// Creates a [ProduceModel] from a JSON map.
  factory ProduceModel.fromJson(Map<String, dynamic> json, String id) {
    try {
      return ProduceModel(
        id: id,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        unit: json['unit'] as String,
        category: json['category'] as String,
        imageUrl: json['imageUrl'] as String,
        isAvailable: json['isAvailable'] as bool,
        updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      );
    } catch (e) {
      debugPrint('ProduceModel: Error parsing document $id: $e');
      debugPrint('ProduceModel: Data was: $json');
      rethrow;
    }
  }

  /// Converts the [ProduceModel] to a JSON map for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'unit': unit,
      'category': category,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Creates a [ProduceModel] from a Firestore [DocumentSnapshot].
  factory ProduceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProduceModel.fromJson(data, doc.id);
  }
}
