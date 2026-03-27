import '../../domain/entities/tip_entity.dart';
import '../../domain/repositories/tips_repository.dart';
import '../datasources/tips_local_data_source.dart';

// Dummy class to satisfy home_screen.dart without touching the restricted file
class TipsRemoteDataSourceImpl {
  TipsRemoteDataSourceImpl({required dynamic client});
}

// This class gets the tips from our local data source
class TipsRepositoryImpl implements TipsRepository {
  final TipsLocalDataSource localDataSource;

  TipsRepositoryImpl({
    required this.localDataSource,
    dynamic remoteDataSource, // Allow unused parameter
  });

  @override
  Future<List<TipEntity>> getTips() async {
    final models = await localDataSource.getTips();
    return models.toList();
  }
}
