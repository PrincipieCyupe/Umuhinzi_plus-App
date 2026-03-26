import '../../domain/entities/tip_entity.dart';
import '../../domain/repositories/tips_repository.dart';
import '../datasources/tips_local_data_source.dart';

// This class actually gets the tips from our local data source
class TipsRepositoryImpl implements TipsRepository {
  final TipsLocalDataSource localDataSource;

  TipsRepositoryImpl({required this.localDataSource});

  @override
  Future<List<TipEntity>> getTips() async {
    // Just fetch from local source for now
    return await localDataSource.getTips();
  }
}
