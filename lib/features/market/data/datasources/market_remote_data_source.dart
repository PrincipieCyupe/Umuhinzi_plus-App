import 'package:cloud_firestore/cloud_firestore.dart';
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
    return firestore
        .collection('market_produce')
        .where('category', isEqualTo: category)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProduceModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Stream<List<ProduceModel>> searchProduce(String query) {
    // Note: Firestore doesn't support native partial string matching (search).
    // For a real app, we'd use Algolia or a similar service.
    // For this implementation, we'll fetch all and filter client-side or use a simple prefix match.
    // Here we'll use a prefix match for demonstration as per requirements.
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
