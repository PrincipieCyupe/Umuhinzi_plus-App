import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/tip_entity.dart';
import '../../domain/usecases/get_tips.dart';
import 'tips_event.dart';
import 'tips_state.dart';

// This bloc manages the logic for the tips screen
class TipsBloc extends Bloc<TipsEvent, TipsState> {
  final GetTips getTips;
  List<TipEntity> _allTips = [];

  TipsBloc({required this.getTips}) : super(TipsInitial()) {
    on<LoadTips>(_onLoadTips);
    on<FilterTips>(_onFilterTips);
    on<RefreshTips>(_onRefreshTips);
  }

  // Load all tips from local data source
  Future<void> _onLoadTips(LoadTips event, Emitter<TipsState> emit) async {
    emit(TipsLoading());
    try {
      _allTips = await getTips();
      emit(TipsLoaded(tips: _allTips));
    } catch (e) {
      emit(const TipsError("Failed to load farming tips."));
    }
  }

  // Refresh tips (simulated delay for pull-to-refresh)
  Future<void> _onRefreshTips(RefreshTips event, Emitter<TipsState> emit) async {
    await _onLoadTips(LoadTips(), emit);
  }

  // Filter tips based on search query and selected tab
  void _onFilterTips(FilterTips event, Emitter<TipsState> emit) {
    if (state is TipsLoaded) {
      final filteredTips = _allTips.where((tip) {
        final matchesQuery = tip.title.toLowerCase().contains(event.query.toLowerCase());
        final matchesCategory = event.category == 'All' || tip.category == event.category;
        return matchesQuery && matchesCategory;
      }).toList();

      emit(TipsLoaded(
        tips: filteredTips,
        query: event.query,
        category: event.category,
      ));
    }
  }
}
