import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/market_price_model.dart';

class MarketPriceFirestoreSource {
  final FirebaseFirestore firestore;

  MarketPriceFirestoreSource({required this.firestore});

  Stream<List<MarketPriceModel>> pricesStream({String? district}) {
    Query<Map<String, dynamic>> query = firestore.collection('market_prices');

    if (district != null && district != 'All' && district.isNotEmpty) {
      query = query.where('district', isEqualTo: district);
    }

    return query.orderBy('date', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MarketPriceModel.fromFirestore(doc)).toList();
    });
  }
}
