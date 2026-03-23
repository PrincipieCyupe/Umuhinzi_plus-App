import 'package:cloud_firestore/cloud_firestore.dart';

class MarketPriceModel {
  final String commodity;
  final String market;
  final String district;
  final double price;
  final String unit;
  final String date;
  final String priceType;
  final DateTime fetchedAt;

  MarketPriceModel({
    required this.commodity,
    required this.market,
    required this.district,
    required this.price,
    required this.unit,
    required this.date,
    required this.priceType,
    required this.fetchedAt,
  });

  factory MarketPriceModel.fromJson(Map<String, dynamic> json) {
    return MarketPriceModel(
      commodity: json['cmname']?.toString() ?? 'Unknown',
      market: json['mktname']?.toString() ?? 'Unknown',
      district: json['adm1_name']?.toString() ?? 'Unknown',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      unit: json['unit']?.toString() ?? 'N/A',
      date: json['date']?.toString() ?? '1970-01-01',
      priceType: json['pricetype']?.toString() ?? 'Unknown',
      fetchedAt: DateTime.now(),
    );
  }

  factory MarketPriceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MarketPriceModel(
      commodity: data['commodity'] ?? 'Unknown',
      market: data['market'] ?? 'Unknown',
      district: data['district'] ?? 'Unknown',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      unit: data['unit'] ?? 'N/A',
      date: data['date'] ?? '1970-01-01',
      priceType: data['priceType'] ?? 'Unknown',
      fetchedAt: (data['fetchedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'commodity': commodity,
      'market': market,
      'district': district,
      'price': price,
      'unit': unit,
      'date': date,
      'priceType': priceType,
      'fetchedAt': Timestamp.fromDate(fetchedAt),
    };
  }
}
