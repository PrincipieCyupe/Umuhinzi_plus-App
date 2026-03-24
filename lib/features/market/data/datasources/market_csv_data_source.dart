import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/market_price_model.dart';
import '../../../../core/error/exceptions.dart';

class MarketCsvDataSource {
  final http.Client client;
  DateTime? _lastUpdated;
  List<MarketPriceModel> _cachedPrices = [];

  MarketCsvDataSource({required this.client});

  Future<void> fetchAndSync() async {
    try {
      final url = Uri.parse(
        'https://data.humdata.org/dataset/a4a84c1c-81d1-491b-9fbe-1955ae736508/resource/8c22eeb5-cc2e-46bc-8a0d-08b7486b2486/download/wfp_food_prices_rwa.csv',
      );

      final response = await client.get(url);

      if (response.statusCode == 200) {
        final lines = const LineSplitter().convert(response.body);
        if (lines.isEmpty) return;

        // Skip header row
        final dataLines = lines.skip(1);
        final Map<String, MarketPriceModel> deduplicated = {};
        DateTime? maxDate;

        for (var line in dataLines) {
          if (line.trim().isEmpty) continue;
          
          // Custom CSV split respecting quotes
          final values = _splitCsvLine(line);
          if (values.length < 14) continue;

          final dateStr = values[0];
          final market = values[3];
          final commodity = values[7];
          final unit = values[8];
          final priceType = values[10];
          final currency = values[11];
          final priceStr = values[12];

          // Filter: keep only rows where currency == 'RWF'
          if (currency != 'RWF') continue;

          final price = double.tryParse(priceStr) ?? 0.0;
          final date = DateTime.tryParse(dateStr);
          
          if (date != null) {
            if (maxDate == null || date.isAfter(maxDate!)) {
              maxDate = date;
            }
          }

          final category = _determineCategory(commodity);
          final imageUrl = 'https://placehold.co/400x400/e8f5e9/2e7d32?text=${Uri.encodeComponent(commodity)}';

          final model = MarketPriceModel(
            commodity: commodity,
            market: market,
            district: '', // admin2 or empty if not needed
            price: price.toString(),
            unit: unit,
            date: dateStr,
            priceType: priceType,
            fetchedAt: DateTime.now(),
          );

          // Deduplicate: same commodity + market -> keep most recent date
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

        _cachedPrices = deduplicated.values.toList();
        _lastUpdated = maxDate;
        debugPrint('CSV sync successful. Parsed ${_cachedPrices.length} unique records.');
      } else {
        throw ServerException();
      }
    } catch (e) {
      debugPrint('CSV Fetch failed: $e');
      throw ServerException();
    }
  }

  DateTime? getLastUpdated() => _lastUpdated;
  
  List<MarketPriceModel> getCachedPrices() => _cachedPrices;

  String _determineCategory(String commodityAndCategory) {
    final lower = commodityAndCategory.toLowerCase();
    const vegKeyWords = ['vegetable', 'beans', 'peas', 'potato', 'tomato', 'onion', 'cabbage', 'carrot', 'spinach', 'oil', 'fats'];
    const fruitKeyWords = ['fruit', 'banana', 'mango', 'avocado', 'pineapple', 'papaya', 'orange'];

    for (var w in vegKeyWords) {
      if (lower.contains(w)) return 'Vegetables';
    }
    for (var w in fruitKeyWords) {
      if (lower.contains(w)) return 'Fruits';
    }
    return 'Grains';
  }

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
