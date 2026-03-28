import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/tip_model.dart';

/// Reads tips from the Firestore `tips` collection.
/// Users have read-only access; admins manage content from the Firebase console.
abstract class TipsFirestoreDataSource {
  Future<List<TipModel>> getTips();
  Future<void> seedIfEmpty(List<TipModel> tips);
}

class TipsFirestoreDataSourceImpl implements TipsFirestoreDataSource {
  final FirebaseFirestore _firestore;

  TipsFirestoreDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('tips');

  @override
  Future<List<TipModel>> getTips() async {
    final snapshot = await _collection.orderBy('date', descending: true).get();

    return snapshot.docs.map((doc) => _fromFirestore(doc)).toList();
  }

  /// Seeds the `tips` collection with the provided tips if it is currently empty.
  /// This runs once on first launch so data is immediately available without
  /// any manual Firebase console setup.
  @override
  Future<void> seedIfEmpty(List<TipModel> tips) async {
    final snapshot = await _collection.limit(1).get();
    if (snapshot.docs.isNotEmpty) return; // already seeded

    final batch = _firestore.batch();
    for (final tip in tips) {
      final ref = _collection.doc(tip.id);
      batch.set(ref, _toFirestore(tip));
    }
    await batch.commit();
  }

  // Convert a Firestore document to a TipModel, handling Timestamp dates.
  TipModel _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final rawDate = data['date'];
    DateTime date;
    if (rawDate is Timestamp) {
      date = rawDate.toDate();
    } else {
      date = DateTime.parse(rawDate as String);
    }

    return TipModel(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String,
      body: data['body'] as String? ?? '',
      imageUrl: data['imageUrl'] as String,
      category: data['category'] as String,
      videoId: data['videoId'] as String?,
      date: date,
    );
  }

  Map<String, dynamic> _toFirestore(TipModel tip) {
    return {
      'title': tip.title,
      'description': tip.description,
      'body': tip.body,
      'imageUrl': tip.imageUrl,
      'category': tip.category,
      'videoId': tip.videoId,
      'date': tip.date.toIso8601String(),
    };
  }
}
