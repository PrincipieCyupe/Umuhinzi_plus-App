import '../../domain/entities/tip_entity.dart';
import '../../domain/repositories/tips_repository.dart';
import '../datasources/tips_local_data_source.dart';

// This class gets the tips from our local data source
class TipsRepositoryImpl implements TipsRepository {
  final TipsLocalDataSource localDataSource;

  TipsRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<List<TipEntity>> getTips() async {
    final models = await localDataSource.getTips();
    return models.toList();
  }
}
