import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/produce_model.dart';

/// Abstract interface for the market remote data source.
abstract class MarketRemoteDataSource {
  /// Returns a stream of produce list filtered by [category].
  Stream<List<ProduceModel>> getProduceByCategory(String category);

  /// Returns a stream of produce list filtered by [query].
  Stream<List<ProduceModel>> searchProduce(String query);

  /// Adds a new produce item to Firestore.
  Future<void> addProduce(ProduceModel produce);

  /// Updates an existing produce item in Firestore.
  Future<void> updateProduce(ProduceModel produce);

  /// Deletes a produce item from Firestore.
  Future<void> deleteProduce(String produceId);
}

/// Implementation of [MarketRemoteDataSource] using [FirebaseFirestore].
class MarketRemoteDataSourceImpl implements MarketRemoteDataSource {
  final FirebaseFirestore firestore;

  MarketRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<ProduceModel>> getProduceByCategory(String category) {
    Query<Map<String, dynamic>> query = firestore
        .collection('market_produce')
        .limit(50);

    if (category != 'All') {
      query = query.where(
        'category',
        whereIn: [category, category.toLowerCase()],
      );
    }

    return query.snapshots().map((snapshot) {
      debugPrint(
        'MarketRemoteDataSource: Query for "$category" returned ${snapshot.docs.length} docs',
      );
      return snapshot.docs
          .map((doc) => ProduceModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Stream<List<ProduceModel>> searchProduce(String query) {
    return firestore
        .collection('market_produce')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProduceModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<void> addProduce(ProduceModel produce) async {
    await firestore.collection('market_produce').add(produce.toJson());
  }

  @override
  Future<void> updateProduce(ProduceModel produce) async {
    await firestore
        .collection('market_produce')
        .doc(produce.id)
        .update(produce.toJson());
  }

  @override
  Future<void> deleteProduce(String produceId) async {
    await firestore.collection('market_produce').doc(produceId).delete();
  }
}
