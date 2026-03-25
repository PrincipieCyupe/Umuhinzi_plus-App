import 'package:equatable/equatable.dart';

/// Input Details State - Presentation Layer
class InputDetailsState extends Equatable {
  final String? selectedCrop;
  final String? selectedSeason;
  final String? selectedProvince;
  final String? selectedDistrict;
  final List<String> currentDistricts;
  final bool isSaved;
  final String? errorMessage;

  const InputDetailsState({
    this.selectedCrop,
    this.selectedSeason,
    this.selectedProvince,
    this.selectedDistrict,
    this.currentDistricts = const [],
    this.isSaved = false,
    this.errorMessage,
  });

  /// Initial state
  factory InputDetailsState.initial() {
    return const InputDetailsState(currentDistricts: [], isSaved: false);
  }

  /// Copy with method for immutable state updates
  InputDetailsState copyWith({
    String? selectedCrop,
    String? selectedSeason,
    String? selectedProvince,
    String? selectedDistrict,
    List<String>? currentDistricts,
    bool? isSaved,
    String? errorMessage,
    bool clearCrop = false,
    bool clearSeason = false,
    bool clearProvince = false,
    bool clearDistrict = false,
    bool clearError = false,
  }) {
    return InputDetailsState(
      selectedCrop: clearCrop ? null : (selectedCrop ?? this.selectedCrop),
      selectedSeason: clearSeason
          ? null
          : (selectedSeason ?? this.selectedSeason),
      selectedProvince: clearProvince
          ? null
          : (selectedProvince ?? this.selectedProvince),
      selectedDistrict: clearDistrict
          ? null
          : (selectedDistrict ?? this.selectedDistrict),
      currentDistricts: currentDistricts ?? this.currentDistricts,
      isSaved: isSaved ?? this.isSaved,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Check if all required fields are selected
  bool get isComplete =>
      selectedCrop != null &&
      selectedSeason != null &&
      selectedProvince != null &&
      selectedDistrict != null;

  @override
  List<Object?> get props => [
    selectedCrop,
    selectedSeason,
    selectedProvince,
    selectedDistrict,
    currentDistricts,
    isSaved,
    errorMessage,
  ];
}
