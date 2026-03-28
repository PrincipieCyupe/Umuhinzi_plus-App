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

  // Watch for price changes and filter them by district, category, or search query
  @override
  Stream<List<MarketPriceModel>> watchPrices({
    String? district,
    String? category,
    String? searchQuery,
  }) {
    // Use cached data if available, otherwise fetch from CSV
    final cachedPrices = csvDataSource.getCachedPrices();
    if (cachedPrices.isNotEmpty) {
      // Return cached data immediately
      return Stream.value(
        _filterPrices(cachedPrices, district, category, searchQuery),
      );
    }

    // If no cached data, fetch from CSV and then return filtered results
    return Stream.fromFuture(
      csvDataSource.fetchAndSync().then((_) {
        var prices = csvDataSource.getCachedPrices();
        return _filterPrices(prices, district, category, searchQuery);
      }),
    );
  }

  // Exposed for unit testing only
  List<MarketPriceModel> filterPricesForTest(
    List<MarketPriceModel> prices,
    String? district,
    String? category,
    String? searchQuery,
  ) => _filterPrices(prices, district, category, searchQuery);

  // Helper method to filter prices based on district, category, and search query
  List<MarketPriceModel> _filterPrices(
    List<MarketPriceModel> prices,
    String? district,
    String? category,
    String? searchQuery,
  ) {
    // Filter by district if one is chosen
    // CSV stores full names like "Kigali City", "Eastern Province" etc.
    // so we use contains (case-insensitive) to match short names like "Kigali", "Eastern"
    if (district != null && district != 'All') {
      final lowerDistrict = district.toLowerCase();
      prices = prices
          .where(
            (p) =>
                p.district.toLowerCase().contains(lowerDistrict) ||
                p.market.toLowerCase().contains(lowerDistrict),
          )
          .toList();
    }

    // Filter by category (commodity name contains category string)
    if (category != null && category != 'All') {
      final lowerCategory = category.toLowerCase();
      prices = prices.where((p) {
        final commodity = p.commodity.toLowerCase();
        // Natural matching: e.g. 'Maize' matches 'Grains' indirectly if we had category mapping,
        // but for now we match by the category string provided by the tabs.
        // Since the CSV doesn't have a 'category' column, we match against commodity names.
        if (lowerCategory == 'grains') {
          return commodity.contains('maize') ||
              commodity.contains('rice') ||
              commodity.contains('wheat') ||
              commodity.contains('sorghum');
        }
        if (lowerCategory == 'vegetables') {
          return commodity.contains('tomato') ||
              commodity.contains('onion') ||
              commodity.contains('potato') ||
              commodity.contains('cabbage') ||
              commodity.contains('beans');
        }
        if (lowerCategory == 'fruits') {
          return commodity.contains('banana') ||
              commodity.contains('mango') ||
              commodity.contains('pineapple') ||
              commodity.contains('orange');
        }
        return true; // Default to showing if no match logic found
      }).toList();
    }

    // Search filtering
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      prices = prices
          .where(
            (p) =>
                p.commodity.toLowerCase().contains(query) ||
                p.market.toLowerCase().contains(query),
          )
          .toList();
    }

    return prices;
  }
}
