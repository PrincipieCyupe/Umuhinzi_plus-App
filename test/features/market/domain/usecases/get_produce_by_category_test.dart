import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:umuhinzi_plus/core/error/failures.dart';
import 'package:umuhinzi_plus/features/market/domain/entities/produce_entity.dart';
import 'package:umuhinzi_plus/features/market/domain/repositories/market_repository.dart';
import 'package:umuhinzi_plus/features/market/domain/usecases/get_produce_by_category.dart';

// Manual Mock
class MockMarketRepository extends Mock implements MarketRepository {
  @override
  Stream<Either<Failure, List<ProduceEntity>>> getProduceByCategory(
    String? category,
  ) {
    return super.noSuchMethod(
      Invocation.method(#getProduceByCategory, [category]),
      returnValue: Stream<Either<Failure, List<ProduceEntity>>>.empty(),
    );
  }

  @override
  Stream<Either<Failure, List<ProduceEntity>>> searchProduce(String? query) {
    return super.noSuchMethod(
      Invocation.method(#searchProduce, [query]),
      returnValue: Stream<Either<Failure, List<ProduceEntity>>>.empty(),
    );
  }
}

void main() {
  late GetProduceByCategory usecase;
  late MockMarketRepository mockMarketRepository;

  setUp(() {
    mockMarketRepository = MockMarketRepository();
    usecase = GetProduceByCategory(mockMarketRepository);
  });

  final tCategory = 'Vegetables';
  final tProduceList = [
    ProduceEntity(
      id: '1',
      name: 'Tomatoes',
      price: 1.99,
      unit: 'kg',
      category: 'Vegetables',
      imageUrl: 'url',
      isAvailable: true,
      updatedAt: DateTime.now(),
    ),
  ];

  test('should get produce for the category from the repository', () async {
    // arrange
    when(
      mockMarketRepository.getProduceByCategory(any),
    ).thenAnswer((_) => Stream.value(Right(tProduceList)));
    // act
    final result = usecase(tCategory);
    // assert
    expect(result, emits(Right(tProduceList)));
    verify(mockMarketRepository.getProduceByCategory(tCategory));
    verifyNoMoreInteractions(mockMarketRepository);
  });
}
