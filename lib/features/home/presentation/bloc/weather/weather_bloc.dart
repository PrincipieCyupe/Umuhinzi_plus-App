import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/weather_repository.dart';
import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository _weatherRepository;
  String? _lastDistrictName;

  WeatherBloc({required WeatherRepository weatherRepository})
      : _weatherRepository = weatherRepository,
        super(const WeatherInitial()) {
    on<FetchWeatherByDistrict>(_onFetchWeatherByDistrict);
    on<FetchWeatherByCoordinates>(_onFetchWeatherByCoordinates);
    on<RefreshWeather>(_onRefreshWeather);
    on<ClearWeather>(_onClearWeather);
  }

  Future<void> _onFetchWeatherByDistrict(
    FetchWeatherByDistrict event,
    Emitter<WeatherState> emit,
  ) async {
    emit(const WeatherLoading());
    _lastDistrictName = event.districtName;

    try {
      final weather = await _weatherRepository.getWeatherByDistrict(
        event.districtName,
      );
      emit(WeatherLoaded(weather: weather));
    } catch (e) {
      emit(WeatherError(message: e.toString()));
    }
  }

  Future<void> _onFetchWeatherByCoordinates(
    FetchWeatherByCoordinates event,
    Emitter<WeatherState> emit,
  ) async {
    emit(const WeatherLoading());
    // We use the provided location name or fall back to 'Unknown'
    final location = event.locationName ?? 'Unknown';
    _lastDistrictName = location;

    try {
      final weather = await _weatherRepository.getWeatherByCoordinates(
        lat: event.latitude,
        lon: event.longitude,
        locationName: location// Pass the location name here
      );
      emit(WeatherLoaded(weather: weather));
    } catch (e) {
      emit(WeatherError(message: e.toString()));
    }
  }

  Future<void> _onRefreshWeather(
    RefreshWeather event,
    Emitter<WeatherState> emit,
  ) async {
    // If we have a district name, re-trigger the fetch logic
    if (_lastDistrictName != null) {
      add(FetchWeatherByDistrict(districtName: _lastDistrictName!));
    }
  }

  void _onClearWeather(ClearWeather event, Emitter<WeatherState> emit) {
    _lastDistrictName = null;
    emit(const WeatherInitial());
  }
}
