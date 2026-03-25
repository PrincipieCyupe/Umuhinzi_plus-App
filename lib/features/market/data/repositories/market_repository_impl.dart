import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/produce_entity.dart';
import '../../domain/repositories/market_repository.dart';
import '../datasources/market_remote_data_source.dart';
import '../models/produce_model.dart';

/// Implementation of [MarketRepository] connecting domain to data layer.
class MarketRepositoryImpl implements MarketRepository {
  final MarketRemoteDataSource remoteDataSource;

  MarketRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<ProduceEntity>>> getProduceByCategory(
    String category,
  ) {
    return remoteDataSource
        .getProduceByCategory(category)
        .map<Either<Failure, List<ProduceEntity>>>((models) => Right(models))
        .handleError((e) => Left(ServerFailure(e.toString())));
  }

  @override
  Stream<Either<Failure, List<ProduceEntity>>> searchProduce(String query) {
    return remoteDataSource
        .searchProduce(query)
        .map<Either<Failure, List<ProduceEntity>>>((models) => Right(models))
        .handleError((e) => Left(ServerFailure(e.toString())));
  }

  @override
  Future<Either<Failure, void>> addProduce(ProduceEntity produce) async {
    try {
      final model = ProduceModel(
        id: produce.id,
        name: produce.name,
        price: produce.price,
        unit: produce.unit,
        category: produce.category,
        imageUrl: produce.imageUrl,
        isAvailable: produce.isAvailable,
        updatedAt: produce.updatedAt,
      );
      await remoteDataSource.addProduce(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduce(ProduceEntity produce) async {
    try {
      final model = ProduceModel(
        id: produce.id,
        name: produce.name,
        price: produce.price,
        unit: produce.unit,
        category: produce.category,
        imageUrl: produce.imageUrl,
        isAvailable: produce.isAvailable,
        updatedAt: produce.updatedAt,
      );
      await remoteDataSource.updateProduce(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduce(String produceId) async {
    try {
      await remoteDataSource.deleteProduce(produceId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
