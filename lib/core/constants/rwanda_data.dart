/// Rwanda Districts Data with Coordinates
/// Used for weather API calls
class RwandaDistricts {
  RwandaDistricts._();

  /// Maps Provinces to their specific Districts
  static const Map<String, List<String>> districtsByProvince = {
    'Kigali City': ['Gasabo', 'Kicukiro', 'Nyarugenge'],
    'Northern Province': ['Burera', 'Gakenke', 'Gicumbi', 'Musanze', 'Rulindo'],
    'Southern Province': [
      'Gisagara',
      'Huye',
      'Kamonyi',
      'Muhanga',
      'Nyamagabe',
      'Nyanza',
      'Nyaruguru',
      'Ruhango',
    ],
    'Eastern Province': [
      'Bugesera',
      'Gatsibo',
      'Kayonza',
      'Kirehe',
      'Ngoma',
      'Nyagatare',
      'Rwamagana',
    ],
    'Western Province': [
      'Karongi',
      'Ngororero',
      'Nyabihu',
      'Nyamasheke',
      'Rubavu',
      'Rusizi',
      'Rutsiro',
    ],
  };

  /// Province abbreviations for display
  static const Map<String, String> provinceAbbreviations = {
    'Kigali City': 'Kigali',
    'Northern Province': 'North',
    'Southern Province': 'South',
    'Eastern Province': 'East',
    'Western Province': 'West',
  };

  /// District name to coordinates mapping - CORRECTED
  /// Format: 'DistrictName': {'lat': latitude, 'lon': longitude}
  static const Map<String, Map<String, double>> districtCoordinates = {
    // Kigali City
    'Gasabo': {'lat': -1.9404, 'lon': 30.0606},
    'Kicukiro': {'lat': -1.9833, 'lon': 30.1333},
    'Nyarugenge': {'lat': -1.9404, 'lon': 30.0445},
    // Northern Province
    'Burera': {'lat': -1.4611, 'lon': 29.7597},
    'Gakenke': {'lat': -1.6958, 'lon': 29.8889},
    'Gicumbi': {'lat': -1.6825, 'lon': 30.0892},
    'Musanze': {'lat': -1.4997, 'lon': 29.5349},
    'Rulindo': {'lat': -1.7181, 'lon': 29.8933},
    // Southern Province
    'Gisagara': {'lat': -2.3394, 'lon': 29.8386},
    'Huye': {'lat': -2.5969, 'lon': 29.7392},
    'Kamonyi': {'lat': -2.0964, 'lon': 29.8886},
    'Muhanga': {'lat': -2.0786, 'lon': 29.7453},
    'Nyamagabe': {'lat': -2.3408, 'lon': 29.5708},
    'Nyanza': {'lat': -2.3539, 'lon': 29.9308},
    'Nyaruguru': {'lat': -2.5556, 'lon': 29.5653},
    'Ruhango': {'lat': -2.1914, 'lon': 29.7803},
    // Eastern Province
    'Bugesera': {'lat': -2.1925, 'lon': 30.0575},
    'Gatsibo': {'lat': -1.7114, 'lon': 30.4289},
    'Kayonza': {'lat': -1.9086, 'lon': 30.2167},
    'Kirehe': {'lat': -2.2208, 'lon': 30.5789},
    'Ngoma': {'lat': -2.2539, 'lon': 30.3986},
    'Nyagatare': {'lat': -1.3308, 'lon': 30.3317},
    'Rwamagana': {'lat': -1.9486, 'lon': 30.4417},
    // Western Province
    'Karongi': {'lat': -2.1064, 'lon': 29.3778},
    'Ngororero': {'lat': -1.7592, 'lon': 29.3911},
    'Nyabihu': {'lat': -1.6889, 'lon': 29.2422},
    'Nyamasheke': {'lat': -2.2592, 'lon': 29.1036},
    'Rubavu': {'lat': -1.6800, 'lon': 29.2561},
    'Rusizi': {'lat': -2.5139, 'lon': 28.8986},
    'Rutsiro': {'lat': -1.8675, 'lon': 29.2214},
  };

  /// Get coordinates for a district
  static Map<String, double>? getCoordinates(String district) {
    return districtCoordinates[district];
  }

  /// Get province for a district
  static String? getProvince(String district) {
    for (final entry in districtsByProvince.entries) {
      if (entry.value.contains(district)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Get province abbreviation for display
  static String getProvinceAbbreviation(String district) {
    final province = getProvince(district);
    if (province != null) {
      return provinceAbbreviations[province] ?? province;
    }
    return '';
  }

  /// Get all districts as a flat list
  static List<String> get allDistricts {
    return districtsByProvince.values.expand((districts) => districts).toList();
  }
}

/// Crops List
class Crops {
  Crops._();

  static const List<String> crops = [
    'Maize',
    'Beans',
    'Rice',
    'Cassava',
    'Irish Potatoes',
    'Bananas',
    'Coffee',
    'Tea',
  ];
}

/// Seasons List
class Seasons {
  Seasons._();

  static const List<String> seasons = ['Season A', 'Season B', 'Season C'];
}

/// Provinces List
class Provinces {
  Provinces._();

  static const List<String> provinces = [
    'Kigali City',
    'Northern Province',
    'Southern Province',
    'Eastern Province',
    'Western Province',
  ];
}
