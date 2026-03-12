import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/produce_entity.dart';
import '../repositories/market_repository.dart';

/// Use case for searching produce by query.
class SearchProduce {
  final MarketRepository repository;

  SearchProduce(this.repository);

  /// Executes the use case with the given [query].
  Stream<Either<Failure, List<ProduceEntity>>> call(String query) {
    return repository.searchProduce(query);
  }
}
