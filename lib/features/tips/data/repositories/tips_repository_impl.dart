import '../../domain/entities/tip_entity.dart';
import '../../domain/repositories/tips_repository.dart';
import '../datasources/tips_local_data_source.dart';
import '../datasources/tips_remote_data_source.dart';

// This class actually gets the tips from our local or remote data source
class TipsRepositoryImpl implements TipsRepository {
  final TipsLocalDataSource localDataSource;
  final TipsRemoteDataSource remoteDataSource;

  TipsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<TipEntity>> getTips() async {
    try {
      // First try to get tips from the real APIs
      return await remoteDataSource.fetchTips();
    } catch (e) {
      // If that fails, we use our local backup list
      final models = await localDataSource.getTips();
      return models.toList();
    }
  }
}
