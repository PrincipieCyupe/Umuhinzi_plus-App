import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/market_repository.dart';

/// Use case for deleting a produce item.
class DeleteProduce {
  final MarketRepository repository;

  DeleteProduce(this.repository);

  /// Executes the use case with the given [produceId].
  Future<Either<Failure, void>> call(String produceId) async {
    return await repository.deleteProduce(produceId);
  }
}
