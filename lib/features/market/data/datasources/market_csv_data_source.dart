import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/market_price_model.dart';

// This file fetches Rwanda market price data from a public CSV file on the HDX website
class MarketCsvDataSource {
  final http.Client client;
  DateTime? _lastUpdated;
  List<MarketPriceModel> _cachedPrices = [];

  MarketCsvDataSource({required this.client});

  // This method handles the main job of getting and syncing data
  Future<void> fetchAndSync() async {
    try {
      // The URL for the WFP Rwanda food prices CSV
      final url = Uri.parse(
        'https://data.humdata.org/dataset/a4a84c1c-81d1-491b-9fbe-1955ae736508/resource/8c22eeb5-cc2e-46bc-8a0d-08b7486b2486/download/wfp_food_prices_rwa.csv',
      );

      // Fetch the CSV file from the HDX website
      final response = await client.get(url);

      if (response.statusCode == 200) {
        // Split the big string into individual lines
        final lines = const LineSplitter().convert(response.body);
        if (lines.isEmpty) return;

        // Skip the first row because it contains headers, not data
        final dataLines = lines.skip(1);
        final Map<String, MarketPriceModel> deduplicated = {};
        DateTime? maxDate;

        for (var line in dataLines) {
          if (line.trim().isEmpty) continue;

          // Parse each line using our custom splitter that handles quotes
          final values = _splitCsvLine(line);
          if (values.length < 14) continue;

          final admin1 = values[1];
          final market = values[3];
          final commodity = values[8];
          final unit = values[10];
          final priceType = values[12];
          final currency = values[13];
          final priceStr = values[14];
          final dateStr = values[0];

          // Filter out anything that isn't in RWF currency
          if (currency != 'RWF') continue;

          final price = double.tryParse(priceStr) ?? 0.0;
          final date = DateTime.tryParse(dateStr);

          // Keep track of the most recent date we've seen in the file
          if (date != null) {
            if (maxDate == null || date.isAfter(maxDate)) {
              maxDate = date;
            }
          }

          // Convert the CSV data into our internal data model
          final model = MarketPriceModel(
            commodity: commodity,
            market: market,
            district: admin1,
            price: price,
            unit: unit,
            date: dateStr,
            priceType: priceType,
            fetchedAt: date ?? DateTime.now(),
          );

          // Deduplicate: Keep only the most recent price for each crop in each market
          final key = '${commodity}_$market';
          if (deduplicated.containsKey(key)) {
            final existing = deduplicated[key]!;
            if (existing.date.compareTo(dateStr) < 0) {
              deduplicated[key] = model;
            }
          } else {
            deduplicated[key] = model;
          }
        }

        // Save the results into our cache
        _cachedPrices = deduplicated.values.toList();
        _lastUpdated = maxDate;
        debugPrint(
          'CSV sync successful. Parsed ${_cachedPrices.length} unique records.',
        );
      } else {
        // If the web request fails, tell us why
        throw Exception('Failed to fetch CSV: Status ${response.statusCode}');
      }
    } catch (e) {
      // If something goes wrong during the process, throw an error

      debugPrint('CSV Fetch failed: $e');
      throw Exception('WFP sync failed: $e');
    }
  }

  // Returns the date when the data was last updated at the source
  DateTime? getLastUpdated() => _lastUpdated;

  // Gets the latest list of market prices we have stored
  List<MarketPriceModel> getCachedPrices() => _cachedPrices;

  List<String> _splitCsvLine(String line) {
    final result = <String>[];
    StringBuffer current = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString().trim());
        current.clear();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString().trim());
    return result;
  }
}
