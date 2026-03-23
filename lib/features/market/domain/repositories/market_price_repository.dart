import '../../data/models/market_price_model.dart';

abstract class MarketPriceRepository {
  Future<void> syncPrices();
  Stream<List<MarketPriceModel>> watchPrices({String? district});
}
