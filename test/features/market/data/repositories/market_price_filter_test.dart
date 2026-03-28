import 'package:flutter_test/flutter_test.dart';
import 'package:umuhinzi_plus/features/market/data/models/market_price_model.dart';
import 'package:umuhinzi_plus/features/market/data/repositories/market_price_repository_impl.dart';
import 'package:umuhinzi_plus/features/market/data/datasources/market_csv_data_source.dart';
import 'package:umuhinzi_plus/features/market/data/datasources/market_price_firestore_source.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

class MockHttpClient extends Mock implements http.Client {}

class MockMarketPriceFirestoreSource extends Mock
    implements MarketPriceFirestoreSource {}

// Helper to build a test price model
MarketPriceModel _makePrice({
  required String commodity,
  required String district,
  String market = 'Test Market',
  double price = 100.0,
}) {
  return MarketPriceModel(
    commodity: commodity,
    market: market,
    district: district,
    price: price,
    unit: 'KG',
    date: '2024-01-01',
    priceType: 'Retail',
    fetchedAt: DateTime(2024, 1, 1),
  );
}

void main() {
  late MarketPriceRepositoryImpl repository;
  late MarketCsvDataSource csvDataSource;
  late MockMarketPriceFirestoreSource mockFirestoreSource;

  setUp(() {
    csvDataSource = MarketCsvDataSource(client: MockHttpClient());
    mockFirestoreSource = MockMarketPriceFirestoreSource();
    repository = MarketPriceRepositoryImpl(
      csvDataSource: csvDataSource,
      firestoreSource: mockFirestoreSource,
    );
  });

  group('filterByDistrict', () {
    test('returns all prices when district is null', () async {
      final prices = [
        _makePrice(commodity: 'Maize', district: 'Kigali City'),
        _makePrice(commodity: 'Rice', district: 'Eastern Province'),
      ];

      final result = repository.filterPricesForTest(prices, null, null, null);
      expect(result.length, 2);
    });

    test(
      'matches partial province name — Eastern matches Eastern Province',
      () async {
        final prices = [
          _makePrice(commodity: 'Maize', district: 'Eastern Province'),
          _makePrice(commodity: 'Rice', district: 'Kigali City'),
          _makePrice(commodity: 'Beans', district: 'Northern Province'),
        ];

        final result = repository.filterPricesForTest(
          prices,
          'Eastern',
          null,
          null,
        );
        expect(result.length, 1);
        expect(result.first.district, 'Eastern Province');
      },
    );

    test('matches Kigali inside Kigali City', () {
      final prices = [
        _makePrice(commodity: 'Tomato', district: 'Kigali City'),
        _makePrice(commodity: 'Onion', district: 'Southern Province'),
      ];

      final result = repository.filterPricesForTest(
        prices,
        'Kigali',
        null,
        null,
      );
      expect(result.length, 1);
      expect(result.first.commodity, 'Tomato');
    });

    test('returns empty when no district matches', () {
      final prices = [_makePrice(commodity: 'Maize', district: 'Kigali City')];

      final result = repository.filterPricesForTest(
        prices,
        'Western',
        null,
        null,
      );
      expect(result.isEmpty, true);
    });
  });

  group('filterByCategory', () {
    test('filters grains correctly', () {
      final prices = [
        _makePrice(commodity: 'Maize (white)', district: 'Kigali City'),
        _makePrice(commodity: 'Rice', district: 'Kigali City'),
        _makePrice(commodity: 'Tomato', district: 'Kigali City'),
      ];

      final result = repository.filterPricesForTest(
        prices,
        null,
        'Grains',
        null,
      );
      expect(result.length, 2);
      expect(result.any((p) => p.commodity == 'Tomato'), false);
    });

    test('filters vegetables correctly', () {
      final prices = [
        _makePrice(commodity: 'Tomato', district: 'Kigali City'),
        _makePrice(commodity: 'Onion', district: 'Kigali City'),
        _makePrice(commodity: 'Banana', district: 'Kigali City'),
      ];

      final result = repository.filterPricesForTest(
        prices,
        null,
        'Vegetables',
        null,
      );
      expect(result.length, 2);
      expect(result.any((p) => p.commodity == 'Banana'), false);
    });

    test('filters fruits correctly', () {
      final prices = [
        _makePrice(commodity: 'Banana', district: 'Kigali City'),
        _makePrice(commodity: 'Mango', district: 'Kigali City'),
        _makePrice(commodity: 'Maize', district: 'Kigali City'),
      ];

      final result = repository.filterPricesForTest(
        prices,
        null,
        'Fruits',
        null,
      );
      expect(result.length, 2);
      expect(result.any((p) => p.commodity == 'Maize'), false);
    });

    test('returns all when category is All', () {
      final prices = [
        _makePrice(commodity: 'Banana', district: 'Kigali City'),
        _makePrice(commodity: 'Maize', district: 'Kigali City'),
        _makePrice(commodity: 'Tomato', district: 'Kigali City'),
      ];

      final result = repository.filterPricesForTest(prices, null, 'All', null);
      expect(result.length, 3);
    });
  });

  group('filterBySearchQuery', () {
    test('returns matching commodities by search query', () {
      final prices = [
        _makePrice(commodity: 'Maize (white)', district: 'Kigali City'),
        _makePrice(commodity: 'Rice', district: 'Kigali City'),
      ];

      final result = repository.filterPricesForTest(
        prices,
        null,
        null,
        'maize',
      );
      expect(result.length, 1);
      expect(result.first.commodity, 'Maize (white)');
    });

    test('returns empty list when no match', () {
      final prices = [_makePrice(commodity: 'Maize', district: 'Kigali City')];

      final result = repository.filterPricesForTest(
        prices,
        null,
        null,
        'banana',
      );
      expect(result.isEmpty, true);
    });
  });
}
