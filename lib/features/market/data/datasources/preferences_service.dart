import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local preferences using [SharedPreferences].
class PreferencesService {
  final SharedPreferences sharedPreferences;

  static const String keyLastCategory = 'last_selected_category';
  static const String keyPreferredCurrency = 'preferred_currency';
  static const String keyLastSearchQuery = 'last_search_query';

  PreferencesService({required this.sharedPreferences});

  /// Saves the last selected category.
  Future<void> saveLastSelectedCategory(String category) async {
    await sharedPreferences.setString(keyLastCategory, category);
  }

  /// Gets the last selected category, defaults to 'All'.
  String getLastSelectedCategory() {
    return sharedPreferences.getString(keyLastCategory) ?? 'All';
  }

  /// Saves the preferred currency.
  Future<void> savePreferredCurrency(String currency) async {
    await sharedPreferences.setString(keyPreferredCurrency, currency);
  }

  /// Gets the preferred currency, defaults to 'RWF'.
  String getPreferredCurrency() {
    return sharedPreferences.getString(keyPreferredCurrency) ?? 'RWF';
  }

  /// Saves the last search query.
  Future<void> saveLastSearchQuery(String query) async {
    await sharedPreferences.setString(keyLastSearchQuery, query);
  }

  /// Gets the last search query, defaults to an empty string.
  String getLastSearchQuery() {
    return sharedPreferences.getString(keyLastSearchQuery) ?? '';
  }
}
