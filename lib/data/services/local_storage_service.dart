import 'package:shared_preferences/shared_preferences.dart';

/// Local Storage Service
/// Handles storing user preferences and farm details locally
class LocalStorageService {
  static const String _keySelectedCrop = 'selected_crop';
  static const String _keySelectedSeason = 'selected_season';
  static const String _keySelectedProvince = 'selected_province';
  static const String _keySelectedDistrict = 'selected_district';
  static const String _keyIsOnboardingComplete = 'is_onboarding_complete';
  static const String _keyLanguage = 'language';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';

  late SharedPreferences _prefs;

  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== Farm Details ====================

  /// Save selected crop
  Future<bool> setSelectedCrop(String crop) async {
    return await _prefs.setString(_keySelectedCrop, crop);
  }

  /// Get selected crop
  String? getSelectedCrop() {
    return _prefs.getString(_keySelectedCrop);
  }

  /// Save selected season
  Future<bool> setSelectedSeason(String season) async {
    return await _prefs.setString(_keySelectedSeason, season);
  }

  /// Get selected season
  String? getSelectedSeason() {
    return _prefs.getString(_keySelectedSeason);
  }

  /// Save selected province
  Future<bool> setSelectedProvince(String province) async {
    return await _prefs.setString(_keySelectedProvince, province);
  }

  /// Get selected province
  String? getSelectedProvince() {
    return _prefs.getString(_keySelectedProvince);
  }

  /// Save selected district
  Future<bool> setSelectedDistrict(String district) async {
    return await _prefs.setString(_keySelectedDistrict, district);
  }

  /// Get selected district
  String? getSelectedDistrict() {
    return _prefs.getString(_keySelectedDistrict);
  }

  /// Check if farm details are complete
  bool isFarmDetailsComplete() {
    return getSelectedCrop() != null &&
        getSelectedSeason() != null &&
        getSelectedProvince() != null &&
        getSelectedDistrict() != null;
  }

  /// Clear all farm details
  Future<bool> clearFarmDetails() async {
    await _prefs.remove(_keySelectedCrop);
    await _prefs.remove(_keySelectedSeason);
    await _prefs.remove(_keySelectedProvince);
    await _prefs.remove(_keySelectedDistrict);
    return true;
  }

  // ==================== Onboarding ====================

  /// Set onboarding complete status
  Future<bool> setOnboardingComplete(bool complete) async {
    return await _prefs.setBool(_keyIsOnboardingComplete, complete);
  }

  /// Get onboarding complete status
  bool isOnboardingComplete() {
    return _prefs.getBool(_keyIsOnboardingComplete) ?? false;
  }

  // ==================== Language ====================

  /// Set language preference (en, rw, fr)
  Future<bool> setLanguage(String languageCode) async {
    return await _prefs.setString(_keyLanguage, languageCode);
  }

  /// Get language preference
  String getLanguage() {
    return _prefs.getString(_keyLanguage) ?? 'en';
  }

  // ==================== User Info ====================

  /// Save user email
  Future<bool> setUserEmail(String email) async {
    return await _prefs.setString(_keyUserEmail, email);
  }

  /// Get user email
  String? getUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  /// Save user name
  Future<bool> setUserName(String name) async {
    return await _prefs.setString(_keyUserName, name);
  }

  /// Get user name
  String? getUserName() {
    return _prefs.getString(_keyUserName);
  }

  /// Clear all user data (logout)
  Future<bool> clearAll() async {
    return await _prefs.clear();
  }
}
