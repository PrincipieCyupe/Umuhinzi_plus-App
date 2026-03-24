import '../../domain/repositories/market_price_repository.dart';
import '../datasources/market_price_firestore_source.dart';
import '../datasources/market_csv_data_source.dart';
import '../models/market_price_model.dart';
import 'dart:async';

class MarketPriceRepositoryImpl implements MarketPriceRepository {
  final MarketCsvDataSource csvDataSource;
  final MarketPriceFirestoreSource firestoreSource;

  MarketPriceRepositoryImpl({
    required this.csvDataSource,
    required this.firestoreSource,
  });

  @override
  Future<void> syncPrices() async {
    await csvDataSource.fetchAndSync();
  }

  @override
  Stream<List<MarketPriceModel>> watchPrices({String? district}) {
    // If repo returns a Stream, wrap Future using Stream.fromFuture()
    return Stream.fromFuture(csvDataSource.fetchAndSync().then((_) {
      var prices = csvDataSource.getCachedPrices();
      if (district != null && district != 'All') {
        prices = prices.where((p) => p.district == district || p.market == district).toList();
      }
      return prices;
    }));
  }
}
