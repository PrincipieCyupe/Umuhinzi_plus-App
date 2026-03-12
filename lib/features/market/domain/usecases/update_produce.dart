import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/produce_entity.dart';
import '../repositories/market_repository.dart';

/// Use case for updating an existing produce item.
class UpdateProduce {
  final MarketRepository repository;

  UpdateProduce(this.repository);

  /// Executes the use case with the given [produce].
  Future<Either<Failure, void>> call(ProduceEntity produce) async {
    return await repository.updateProduce(produce);
  }
}
