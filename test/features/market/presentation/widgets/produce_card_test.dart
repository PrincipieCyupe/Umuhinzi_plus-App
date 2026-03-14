import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:umuhinzi_plus/features/market/domain/entities/produce_entity.dart';
import 'package:umuhinzi_plus/features/market/presentation/widgets/produce_card.dart';

// Mock HttpOverrides to avoid network errors in tests
class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient extends Mock implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) =>
      Future.value(_MockHttpClientRequest());

  @override
  bool get autoUncompress => true;
  @override
  set autoUncompress(bool value) {}
}

class _MockHttpClientRequest extends Mock implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() => Future.value(_MockHttpClientResponse());
}

class _MockHttpHeaders extends Mock implements HttpHeaders {}

class _MockHttpClientResponse extends Mock implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => 0;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => const Stream<List<int>>.empty().listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
}

void main() {
  HttpOverrides.global = MockHttpOverrides();

  final tProduce = ProduceEntity(
    id: '1',
    name: 'Tomatoes',
    price: 1.99,
    unit: 'kg',
    category: 'Vegetables',
    imageUrl: 'https://example.com/image.png',
    isAvailable: true,
    updatedAt: DateTime.now(),
  );

  testWidgets('should render produce name, price and currency', (
    WidgetTester tester,
  ) async {
    // arrange
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 300,
              child: ProduceCard(produce: tProduce, currency: 'RWF'),
            ),
          ),
        ),
      ),
    );

    // assert
    expect(find.text('Tomatoes'), findsOneWidget);
    expect(find.text('RWF 1.99/kg'), findsOneWidget);
  });
}
