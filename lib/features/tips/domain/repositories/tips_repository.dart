import '../entities/tip_entity.dart';

// Repository interface - defines what tips can be fetched
abstract class TipsRepository {
  Future<List<TipEntity>> getTips();
}
