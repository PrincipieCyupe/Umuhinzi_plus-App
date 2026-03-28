import 'package:equatable/equatable.dart';

// These are the things that can happen in the tips screen, like loading or filtering
abstract class TipsEvent extends Equatable {
  const TipsEvent();

  @override
  List<Object?> get props => [];
}

// Load tips when screen opens
class LoadTips extends TipsEvent {}

// Filter tips when search query or tab changes
class FilterTips extends TipsEvent {
  final String query;
  final String category;

  const FilterTips({required this.query, required this.category});

  @override
  List<Object?> get props => [query, category];
}

// Refresh tips when pull-to-refresh is used
class RefreshTips extends TipsEvent {}
