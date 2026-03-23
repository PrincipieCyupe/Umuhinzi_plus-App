import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/market_price_repository.dart';
import '../../data/models/market_price_model.dart';

abstract class MarketPriceState extends Equatable {
  const MarketPriceState();

  @override
  List<Object?> get props => [];
}

class MarketPriceInitial extends MarketPriceState {}

class MarketPriceLoading extends MarketPriceState {}

class MarketPriceLoaded extends MarketPriceState {
  final List<MarketPriceModel> prices;
  final String lastUpdated;

  const MarketPriceLoaded(this.prices, this.lastUpdated);

  @override
  List<Object?> get props => [prices, lastUpdated];
}

class MarketPriceError extends MarketPriceState {
  final String message;

  const MarketPriceError(this.message);

  @override
  List<Object?> get props => [message];
}

class MarketPriceCubit extends Cubit<MarketPriceState> {
  final MarketPriceRepository repository;
  StreamSubscription<List<MarketPriceModel>>? _pricesSubscription;
  Timer? _syncTimer;
  String? _currentDistrict;

  MarketPriceCubit({required this.repository}) : super(MarketPriceInitial()) {
    _init();
  }

  void _init() {
    emit(MarketPriceLoading());
    // Initial sync
    repository.syncPrices();
    
    // Subscribe to stream (default: All districts)
    _subscribeToStream();

    // Start 30-minute periodic sync
    _syncTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      repository.syncPrices();
    });
  }

  void filterByDistrict(String district) {
    _currentDistrict = district == 'All' ? null : district;
    emit(MarketPriceLoading());
    _subscribeToStream();
  }

  void _subscribeToStream() {
    _pricesSubscription?.cancel();
    _pricesSubscription = repository.watchPrices(district: _currentDistrict).listen(
      (prices) {
        if (prices.isEmpty) {
          emit(const MarketPriceLoaded([], 'N/A'));
        } else {
          // Find most recent date manually to be safe
          String latestDate = prices.first.date;
          for (var item in prices) {
            if (item.date.compareTo(latestDate) > 0) {
              latestDate = item.date;
            }
          }
          emit(MarketPriceLoaded(prices, latestDate));
        }
      },
      onError: (error) {
        emit(MarketPriceError('Prices unavailable'));
      },
    );
  }

  @override
  Future<void> close() {
    _syncTimer?.cancel();
    _pricesSubscription?.cancel();
    return super.close();
  }
}
