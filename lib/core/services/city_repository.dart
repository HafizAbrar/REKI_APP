import '../models/city.dart';
import 'city_api_service.dart';

class CityRepository {
  final CityApiService _apiService;

  CityRepository(this._apiService);

  /// Get all cities (with caching)
  Future<List<City>> getCities({bool forceRefresh = false}) async {
    return _apiService.getCities();
  }

  /// Get active cities only
  Future<List<City>> getActiveCities() async {
    return _apiService.getActiveCities();
  }

  /// Get city by slug
  Future<City?> getCityBySlug(String slug) async {
    return _apiService.getCityBySlug(slug);
  }

  /// Get city by ID
  Future<City?> getCityById(String id) async {
    return _apiService.getCityById(id);
  }

  /// Set user's preferred city
  Future<void> setUserCity(String citySlug) async {
    return _apiService.setUserCity(citySlug);
  }

  /// Persist locale and timezone
  Future<void> setUserLocale(
      {required String language, required String timezone}) async {
    return _apiService.setUserLocale(language: language, timezone: timezone);
  }

  /// Get user's current city
  Future<City?> getUserCity() async {
    return _apiService.getUserCity();
  }

  /// Detect city from coordinates
  Future<City?> detectCityFromLocation(double lat, double lng) async {
    return _apiService.detectCityFromLocation(lat, lng);
  }

  /// Get fallback cities (offline/default)
  List<City> getFallbackCities() => City.defaultCities();

  /// Get fallback active cities
  List<City> getFallbackActiveCities() =>
      City.defaultCities().where((c) => c.isActive).toList();
}
