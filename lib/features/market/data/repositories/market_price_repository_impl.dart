import '../../domain/repositories/market_price_repository.dart';
import '../datasources/market_price_firestore_source.dart';
import '../datasources/wfp_price_datasource.dart';
import '../models/market_price_model.dart';

class MarketPriceRepositoryImpl implements MarketPriceRepository {
  final WfpPriceDataSource wfpDataSource;
  final MarketPriceFirestoreSource firestoreSource;

  MarketPriceRepositoryImpl({
    required this.wfpDataSource,
    required this.firestoreSource,
  });

  @override
  Future<void> syncPrices() async {
    await wfpDataSource.fetchAndSync();
  }

  @override
  Stream<List<MarketPriceModel>> watchPrices({String? district}) {
    return firestoreSource.pricesStream(district: district);
  }
}
