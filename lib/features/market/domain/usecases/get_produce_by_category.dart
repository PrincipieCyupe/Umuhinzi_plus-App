import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/produce_entity.dart';
import '../repositories/market_repository.dart';

/// Use case for fetching produce filtered by category.
class GetProduceByCategory {
  final MarketRepository repository;

  GetProduceByCategory(this.repository);

  /// Executes the use case with the given [category].
  Stream<Either<Failure, List<ProduceEntity>>> call(String category) {
    return repository.getProduceByCategory(category);
  }
}
