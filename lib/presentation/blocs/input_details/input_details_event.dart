import 'package:equatable/equatable.dart';

/// Input Details Events - Presentation Layer
abstract class InputDetailsEvent extends Equatable {
  const InputDetailsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to select a crop
class SelectCrop extends InputDetailsEvent {
  final String crop;

  const SelectCrop({required this.crop});

  @override
  List<Object?> get props => [crop];
}

/// Event to select a season
class SelectSeason extends InputDetailsEvent {
  final String season;

  const SelectSeason({required this.season});

  @override
  List<Object?> get props => [season];
}

/// Event to select a province
class SelectProvince extends InputDetailsEvent {
  final String province;

  const SelectProvince({required this.province});

  @override
  List<Object?> get props => [province];
}

/// Event to select a district
class SelectDistrict extends InputDetailsEvent {
  final String district;

  const SelectDistrict({required this.district});

  @override
  List<Object?> get props => [district];
}

/// Event to save input details
class SaveInputDetails extends InputDetailsEvent {
  const SaveInputDetails();
}

/// Event to reset input details
class ResetInputDetails extends InputDetailsEvent {
  const ResetInputDetails();
}
