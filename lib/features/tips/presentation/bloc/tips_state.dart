import 'package:equatable/equatable.dart';
import '../../domain/entities/tip_entity.dart';

// These represent what we show on the screen, like a loading spinner or the list of tips
abstract class TipsState extends Equatable {
  const TipsState();

  @override
  List<Object?> get props => [];
}

// Initial state before loading
class TipsInitial extends TipsState {}

// Show loading indicator
class TipsLoading extends TipsState {}

// Successfully loaded tips
class TipsLoaded extends TipsState {
  final List<TipEntity> tips;
  final String query;
  final String category;

  const TipsLoaded({
    required this.tips,
    this.query = '',
    this.category = 'All',
  });

  @override
  List<Object?> get props => [tips, query, category];
}

// Show error if something goes wrong
class TipsError extends TipsState {
  final String message;

  const TipsError(this.message);

  @override
  List<Object?> get props => [message];
}
