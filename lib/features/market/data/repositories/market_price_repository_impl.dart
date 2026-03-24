import '../../domain/repositories/market_price_repository.dart';
import '../datasources/market_price_firestore_source.dart';
import '../datasources/market_csv_data_source.dart';
import '../models/market_price_model.dart';
import 'dart:async';

// This class connects our data sources to the rest of the app logic
class MarketPriceRepositoryImpl implements MarketPriceRepository {
  final MarketCsvDataSource csvDataSource;
  final MarketPriceFirestoreSource firestoreSource;

  MarketPriceRepositoryImpl({
    required this.csvDataSource,
    required this.firestoreSource,
  });

  // Pull the latest data from the CSV file
  @override
  Future<void> syncPrices() async {
    await csvDataSource.fetchAndSync();
  }

  // Watch for price changes and filter them by district if needed
  @override
  Stream<List<MarketPriceModel>> watchPrices({String? district}) {
    // We convert the future into a stream so the UI can listen to it
    return Stream.fromFuture(csvDataSource.fetchAndSync().then((_) {
      var prices = csvDataSource.getCachedPrices();
      if (district != null && district != 'All') {
        // If a district is chosen, filter out everything else
        prices = prices.where((p) => p.district == district || p.market == district).toList();
      }
      return prices;
    }));
  }
}

