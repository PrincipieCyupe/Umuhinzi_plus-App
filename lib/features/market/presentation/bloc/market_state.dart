import 'package:equatable/equatable.dart';
import '../../domain/entities/produce_entity.dart';

/// Base class for all market states.
abstract class MarketState extends Equatable {
  const MarketState();

  @override
  List<Object?> get props => [];
}

/// Initial state of the market.
class MarketInitial extends MarketState {}

/// State indicating that market data is being loaded.
class MarketLoading extends MarketState {}

/// State indicating that market data has been successfully loaded.
class MarketLoaded extends MarketState {
  final List<ProduceEntity> produceList;
  final String activeCategory;
  final String currency;

  const MarketLoaded({
    required this.produceList,
    required this.activeCategory,
    required this.currency,
  });

  @override
  List<Object?> get props => [produceList, activeCategory, currency];
}

/// State indicating an error occurred while fetching market data.
class MarketError extends MarketState {
  final String message;

  const MarketError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State indicating a successful CRUD operation.
class MarketOperationSuccess extends MarketState {
  final String message;

  const MarketOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// State indicating a failed CRUD operation.
class MarketOperationFailure extends MarketState {
  final String message;

  const MarketOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}
