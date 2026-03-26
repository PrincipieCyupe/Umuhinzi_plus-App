import '../entities/tip_entity.dart';
import '../repositories/tips_repository.dart';

// This usecase is specifically for getting tips from the repository
class GetTips {
  final TipsRepository repository;

  GetTips(this.repository);

  Future<List<TipEntity>> call() async {
    // Get all tips from repository
    return await repository.getTips();
  }
}
