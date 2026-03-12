import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/produce_entity.dart';
import '../../domain/usecases/add_produce.dart';
import '../../domain/usecases/delete_produce.dart';
import '../../domain/usecases/get_produce_by_category.dart';
import '../../domain/usecases/search_produce.dart';
import '../../domain/usecases/update_produce.dart';
import '../../data/datasources/preferences_service.dart';
import 'market_event.dart';
import 'market_state.dart';

/// BLoC for managing market state and business logic.
class MarketBloc extends Bloc<MarketEvent, MarketState> {
  final GetProduceByCategory getProduceByCategory;
  final SearchProduce searchProduce;
  final AddProduce addProduce;
  final UpdateProduce updateProduce;
  final DeleteProduce deleteProduce;
  final PreferencesService preferencesService;

  StreamSubscription? _produceSubscription;

  MarketBloc({
    required this.getProduceByCategory,
    required this.searchProduce,
    required this.addProduce,
    required this.updateProduce,
    required this.deleteProduce,
    required this.preferencesService,
  }) : super(MarketInitial()) {
    on<LoadProduceByCategoryEvent>(_onLoadProduceByCategory);
    on<SearchProduceEvent>(
      _onSearchProduce,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 300))
          .switchMap(mapper),
    );
    on<AddProduceEvent>(_onAddProduce);
    on<UpdateProduceEvent>(_onUpdateProduce);
    on<DeleteProduceEvent>(_onDeleteProduce);
    on<ResetMarketEvent>(_onResetMarket);

    // Initial load: Restore last selected category and dispatch event.
    final lastCategory = preferencesService.getLastSelectedCategory();
    add(LoadProduceByCategoryEvent(lastCategory));
  }

  Future<void> _onLoadProduceByCategory(
    LoadProduceByCategoryEvent event,
    Emitter<MarketState> emit,
  ) async {
    debugPrint('MarketBloc: Loading produce for category: ${event.category}');
    emit(MarketLoading());
    await preferencesService.saveLastSelectedCategory(event.category);

    await emit.forEach(
      getProduceByCategory(event.category),
      onData: (Either<Failure, List<ProduceEntity>> result) {
        return result.fold(
          (failure) {
            debugPrint('MarketBloc: Error loading produce: ${failure.message}');
            return MarketError(failure.message);
          },
          (produceList) {
            debugPrint(
              'MarketBloc: Loaded ${produceList.length} items for ${event.category}',
            );
            return MarketLoaded(
              produceList: produceList,
              activeCategory: event.category,
              currency: preferencesService.getPreferredCurrency(),
            );
          },
        );
      },
    );
  }

  Future<void> _onSearchProduce(
    SearchProduceEvent event,
    Emitter<MarketState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(ResetMarketEvent());
      return;
    }

    emit(MarketLoading());
    await preferencesService.saveLastSearchQuery(event.query);

    await _produceSubscription?.cancel();
    _produceSubscription = searchProduce(event.query).listen((result) {
      result.fold(
        (failure) => emit(MarketError(failure.message)),
        (produceList) => emit(
          MarketLoaded(
            produceList: produceList,
            activeCategory: 'Search',
            currency: preferencesService.getPreferredCurrency(),
          ),
        ),
      );
    });
  }

  Future<void> _onAddProduce(
    AddProduceEvent event,
    Emitter<MarketState> emit,
  ) async {
    final result = await addProduce(event.produce);
    result.fold(
      (failure) => emit(MarketOperationFailure(failure.message)),
      (_) => emit(const MarketOperationSuccess('Produce added successfully')),
    );
  }

  Future<void> _onUpdateProduce(
    UpdateProduceEvent event,
    Emitter<MarketState> emit,
  ) async {
    final result = await updateProduce(event.produce);
    result.fold(
      (failure) => emit(MarketOperationFailure(failure.message)),
      (_) => emit(const MarketOperationSuccess('Produce updated successfully')),
    );
  }

  Future<void> _onDeleteProduce(
    DeleteProduceEvent event,
    Emitter<MarketState> emit,
  ) async {
    final result = await deleteProduce(event.produceId);
    result.fold(
      (failure) => emit(MarketOperationFailure(failure.message)),
      (_) => emit(const MarketOperationSuccess('Produce deleted successfully')),
    );
  }

  Future<void> _onResetMarket(
    ResetMarketEvent event,
    Emitter<MarketState> emit,
  ) async {
    final lastCategory = preferencesService.getLastSelectedCategory();
    add(LoadProduceByCategoryEvent(lastCategory));
  }

  @override
  Future<void> close() {
    _produceSubscription?.cancel();
    return super.close();
  }
}
