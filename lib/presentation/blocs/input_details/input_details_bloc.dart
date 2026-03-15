import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/rwanda_data.dart';
import 'input_details_event.dart';
import 'input_details_state.dart';

/// Input Details BLoC - Presentation Layer
/// Manages farmer input selection state (crop, season, province, district)
class InputDetailsBloc extends Bloc<InputDetailsEvent, InputDetailsState> {
  InputDetailsBloc() : super(InputDetailsState.initial()) {
    on<SelectCrop>(_onSelectCrop);
    on<SelectSeason>(_onSelectSeason);
    on<SelectProvince>(_onSelectProvince);
    on<SelectDistrict>(_onSelectDistrict);
    on<SaveInputDetails>(_onSaveInputDetails);
    on<ResetInputDetails>(_onResetInputDetails);
  }

  /// Handle SelectCrop event
  void _onSelectCrop(SelectCrop event, Emitter<InputDetailsState> emit) {
    emit(state.copyWith(selectedCrop: event.crop, clearError: true));
  }

  /// Handle SelectSeason event
  void _onSelectSeason(SelectSeason event, Emitter<InputDetailsState> emit) {
    emit(state.copyWith(selectedSeason: event.season, clearError: true));
  }

  /// Handle SelectProvince event
  /// When province changes, reset district and load new districts
  void _onSelectProvince(
    SelectProvince event,
    Emitter<InputDetailsState> emit,
  ) {
    final districts = RwandaDistricts.districtsByProvince[event.province] ?? [];
    emit(
      state.copyWith(
        selectedProvince: event.province,
        selectedDistrict: null,
        currentDistricts: districts,
        clearDistrict: true,
        clearError: true,
      ),
    );
  }

  /// Handle SelectDistrict event
  void _onSelectDistrict(
    SelectDistrict event,
    Emitter<InputDetailsState> emit,
  ) {
    emit(state.copyWith(selectedDistrict: event.district, clearError: true));
  }

  /// Handle SaveInputDetails event
  void _onSaveInputDetails(
    SaveInputDetails event,
    Emitter<InputDetailsState> emit,
  ) async {
    if (state.isComplete) {
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_crop', state.selectedCrop ?? '');
      await prefs.setString('selected_season', state.selectedSeason ?? '');
      await prefs.setString('selected_province', state.selectedProvince ?? '');
      await prefs.setString('selected_district', state.selectedDistrict ?? '');

      // Mark as saved
      emit(state.copyWith(isSaved: true, clearError: true));
      print(
        "Saved: ${state.selectedCrop}, ${state.selectedSeason}, ${state.selectedProvince}, ${state.selectedDistrict}",
      );
    } else {
      // Show validation error
      String error = 'Please complete all selections:';
      if (state.selectedCrop == null) error += '\n- Select a crop';
      if (state.selectedSeason == null) error += '\n- Select a season';
      if (state.selectedProvince == null) error += '\n- Select a province';
      if (state.selectedDistrict == null) error += '\n- Select a district';

      emit(state.copyWith(errorMessage: error));
    }
  }

  /// Handle ResetInputDetails event
  void _onResetInputDetails(
    ResetInputDetails event,
    Emitter<InputDetailsState> emit,
  ) {
    emit(InputDetailsState.initial());
  }
}
