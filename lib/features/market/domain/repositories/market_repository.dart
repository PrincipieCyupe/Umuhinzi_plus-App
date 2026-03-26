import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/produce_entity.dart';

/// Repository interface for market-related data operations.
abstract class MarketRepository {
  /// Returns a stream of produce list filtered by [category].
  Stream<Either<Failure, List<ProduceEntity>>> getProduceByCategory(
    String category,
  );

  /// Returns a stream of produce list filtered by [query].
  Stream<Either<Failure, List<ProduceEntity>>> searchProduce(String query);

  /// Adds a new [produce] item to the market.
  Future<Either<Failure, void>> addProduce(ProduceEntity produce);

  /// Updates an existing [produce] item in the market.
  Future<Either<Failure, void>> updateProduce(ProduceEntity produce);

  /// Deletes a produce item by its [produceId].
  Future<Either<Failure, void>> deleteProduce(String produceId);
}
