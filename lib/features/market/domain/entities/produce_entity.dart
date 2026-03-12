import 'package:equatable/equatable.dart';

/// Represents a produce item in the market.
class ProduceEntity extends Equatable {
  /// Unique identifier for the produce.
  final String id;

  /// Name of the produce (e.g., "Tomatoes").
  final String name;

  /// Current market price of the produce.
  final double price;

  /// Unit of measurement (e.g., "kg", "head").
  final String unit;

  /// Category of the produce ("vegetables", "fruits", "grains").
  final String category;

  /// URL to the image of the produce.
  final String imageUrl;

  /// Indicates if the produce is currently available in the market.
  final bool isAvailable;

  /// The date and time when the produce information was last updated.
  final DateTime updatedAt;

  const ProduceEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    required this.category,
    required this.imageUrl,
    required this.isAvailable,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    unit,
    category,
    imageUrl,
    isAvailable,
    updatedAt,
  ];
}
