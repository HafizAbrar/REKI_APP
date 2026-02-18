import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city.dart';
import '../network/city_api_service.dart';
import '../utils/result.dart';

final cityRepositoryProvider = Provider<CityRepository>((ref) {
  return CityRepository(ref.read(cityApiServiceProvider));
});

class CityRepository {
  final CityApiService _apiService;

  CityRepository(this._apiService);

  Future<Result<List<City>>> getCities() async {
    try {
      final cities = await _apiService.getCities();
      return Result.success(cities);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<City>> createCity(Map<String, dynamic> cityData) async {
    try {
      final city = await _apiService.createCity(cityData);
      return Result.success(city);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<City>> getCityById(String id) async {
    try {
      final city = await _apiService.getCityById(id);
      return Result.success(city);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<City>> getCityByName(String name) async {
    try {
      final city = await _apiService.getCityByName(name);
      return Result.success(city);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
