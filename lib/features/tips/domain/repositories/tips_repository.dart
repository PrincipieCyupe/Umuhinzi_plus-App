import '../entities/tip_entity.dart';

// This defines what we can do with tips, like fetching them
abstract class TipsRepository {
  // A simple way to get a list of tips
  Future<List<TipEntity>> getTips();
}
