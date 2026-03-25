import 'package:equatable/equatable.dart';
import '../../domain/entities/produce_entity.dart';

/// Base class for all market events.
abstract class MarketEvent extends Equatable {
  const MarketEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load produce by category.
class LoadProduceByCategoryEvent extends MarketEvent {
  final String category;

  const LoadProduceByCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

/// Event to search for produce.
class SearchProduceEvent extends MarketEvent {
  final String query;

  const SearchProduceEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to add a new produce item.
class AddProduceEvent extends MarketEvent {
  final ProduceEntity produce;

  const AddProduceEvent(this.produce);

  @override
  List<Object?> get props => [produce];
}

/// Event to update an existing produce item.
class UpdateProduceEvent extends MarketEvent {
  final ProduceEntity produce;

  const UpdateProduceEvent(this.produce);

  @override
  List<Object?> get props => [produce];
}

/// Event to delete a produce item.
class DeleteProduceEvent extends MarketEvent {
  final String produceId;

  const DeleteProduceEvent(this.produceId);

  @override
  List<Object?> get props => [produceId];
}

/// Event to reset the market state to the current category and clear search.
class ResetMarketEvent extends MarketEvent {
  const ResetMarketEvent();
}
