import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:umuhinzi_plus/features/market/data/datasources/market_remote_data_source.dart';
import 'package:umuhinzi_plus/features/market/data/models/produce_model.dart';
import 'package:umuhinzi_plus/features/market/data/repositories/market_repository_impl.dart';

// Manual Mock
class MockMarketRemoteDataSource extends Mock
    implements MarketRemoteDataSource {
  @override
  Stream<List<ProduceModel>> getProduceByCategory(String? category) {
    return super.noSuchMethod(
      Invocation.method(#getProduceByCategory, [category]),
      returnValue: Stream<List<ProduceModel>>.empty(),
    );
  }

  @override
  Stream<List<ProduceModel>> searchProduce(String? query) {
    return super.noSuchMethod(
      Invocation.method(#searchProduce, [query]),
      returnValue: Stream<List<ProduceModel>>.empty(),
    );
  }
}

void main() {
  late MarketRepositoryImpl repository;
  late MockMarketRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockMarketRemoteDataSource();
    repository = MarketRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  final tCategory = 'Vegetables';
  final tProduceModel = ProduceModel(
    id: '1',
    name: 'Tomatoes',
    price: 1.99,
    unit: 'kg',
    category: 'Vegetables',
    imageUrl: 'url',
    isAvailable: true,
    updatedAt: DateTime.now(),
  );
  final tProduceList = [tProduceModel];

  test(
    'should return a stream of produce when the call to remote data source is successful',
    () async {
      // arrange
      when(
        mockRemoteDataSource.getProduceByCategory(any),
      ).thenAnswer((_) => Stream.value(tProduceList));
      // act
      final result = repository.getProduceByCategory(tCategory);
      // assert
      result.listen((either) {
        either.fold(
          (failure) => fail('Should not fail'),
          (list) => expect(list, tProduceList),
        );
      });
      verify(mockRemoteDataSource.getProduceByCategory(tCategory));
    },
  );
}
