import 'dart:convert';
import 'dart:async';
import '../models/city.dart';
import 'city_repository.dart';
import '../../core/storage/secure_storage.dart';

class CitySelectionService {
  final CityRepository _repository;
  final SecureStorage _storage;

  static const _selectedCityKey = 'selected_city_id';
  static const _lastDetectedCityKey = 'last_detected_city_id';

  CitySelectionService(this._repository, this._storage);

  /// Get currently selected city
  Future<City?> getSelectedCity() async {
    final snapshot = await _storage.read(key: 'selected_city_snapshot');
    if (snapshot != null) {
      try {
        return City.fromJson(jsonDecode(snapshot) as Map<String, dynamic>);
      } catch (_) {/* migrate older/invalid storage below */}
    }
    final id = await _storage.read(key: _selectedCityKey);
    if (id != null) {
      try {
        return await _repository.getCityById(id) ?? City.findById(id);
      } catch (_) {
        return City.findById(id);
      }
    }
    return null;
  }

  Future<void> selectCity(City city) async {
    if (!city.isActive) throw StateError('This city is not available yet.');
    await _storage.write(
        key: 'selected_city_snapshot', value: jsonEncode(city.toJson()));
    await _storage.write(key: _selectedCityKey, value: city.id);
    unawaited(_syncCity(city));
  }

  Future<void> _syncCity(City city) async {
    try {
      await _repository.setUserCity(city.slug);
    } catch (_) {}
    try {
      final lang = city.supportedLanguages.isNotEmpty
          ? city.supportedLanguages.first
          : 'en';
      await _repository.setUserLocale(language: lang, timezone: city.timezone);
    } catch (_) {}
  }

  /// Select city by slug
  Future<void> selectCityBySlug(String slug) async {
    final city = await _repository.getCityBySlug(slug);
    if (city != null) {
      await selectCity(city);
    } else {
      throw Exception('City not found: $slug');
    }
  }

  /// Auto-detect city from GPS and select if confident
  Future<City?> autoDetectAndSelectCity(double lat, double lng) async {
    // Try backend detection first
    City? detected = await detectCity(lat, lng);

    // Fallback to local nearest city

    if (detected != null && detected.isActive) {
      await _storage.write(key: _lastDetectedCityKey, value: detected.id);
      await selectCity(detected);
    }

    return detected;
  }

  Future<City?> detectCity(double lat, double lng) async {
    try {
      final city = await _repository.detectCityFromLocation(lat, lng);
      if (city != null) return city.isActive ? city : null;
    } catch (_) {}
    return City.findNearest(lat, lng);
  }

  /// Get last detected city (for suggestions)
  Future<City?> getLastDetectedCity() async {
    final cityId = await _storage.read(key: _lastDetectedCityKey);
    if (cityId != null) {
      try {
        return await _repository.getCityById(cityId) ?? City.findById(cityId);
      } catch (_) {
        return City.findById(cityId);
      }
    }
    return null;
  }

  /// Get available cities for selection UI
  Future<List<City>> getAvailableCities() async {
    try {
      return await _repository.getActiveCities();
    } catch (_) {
      return _repository.getFallbackActiveCities();
    }
  }

  /// Get all cities including inactive (for admin)
  Future<List<City>> getAllCities() async {
    try {
      return await _repository.getCities();
    } catch (_) {
      return _repository.getFallbackCities();
    }
  }

  /// Clear selected city
  Future<void> clearSelectedCity() async {
    await _storage.delete(key: _selectedCityKey);
    await _storage.delete(key: 'selected_city_snapshot');
  }

  /// Check if city is RTL
  bool isCityRTL(City city) => city.isRTL;

  /// Get city's supported languages
  List<String> getCityLanguages(City city) => city.supportedLanguages;

  /// Get city's currency info
  ({String code, String symbol}) getCityCurrency(City city) => (
        code: city.currency,
        symbol: city.currencySymbol,
      );

  /// Get city's date/time format
  ({String dateFormat, String timeFormat}) getCityDateTimeFormat(City city) => (
        dateFormat: city.dateFormat,
        timeFormat: city.timeFormat,
      );
}
