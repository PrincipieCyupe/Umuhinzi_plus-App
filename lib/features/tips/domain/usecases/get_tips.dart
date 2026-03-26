import '../entities/tip_entity.dart';
import '../repositories/tips_repository.dart';

// GetTips usecase - handles fetching and filtering logic
class GetTips {
  final TipsRepository repository;

  GetTips(this.repository);

  Future<List<TipEntity>> call() async {
    // Get all tips from repository
    return await repository.getTips();
  }
}
