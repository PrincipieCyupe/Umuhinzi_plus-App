import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:umuhinzi_plus/core/error/failures.dart';
import 'package:umuhinzi_plus/features/market/domain/entities/produce_entity.dart';
import 'package:umuhinzi_plus/features/market/domain/repositories/market_repository.dart';
import 'package:umuhinzi_plus/features/market/domain/usecases/search_produce.dart';

// Manual Mock (re-declaring if needed or import from other test)
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
  late SearchProduce usecase;
  late MockMarketRepository mockMarketRepository;

  setUp(() {
    mockMarketRepository = MockMarketRepository();
    usecase = SearchProduce(mockMarketRepository);
  });

  final tQuery = 'Tomatoes';
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

  test('should search produce from the repository', () async {
    // arrange
    when(
      mockMarketRepository.searchProduce(any),
    ).thenAnswer((_) => Stream.value(Right(tProduceList)));
    // act
    final result = usecase(tQuery);
    // assert
    expect(result, emits(Right(tProduceList)));
    verify(mockMarketRepository.searchProduce(tQuery));
    verifyNoMoreInteractions(mockMarketRepository);
  });
}
