import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city.dart';
import 'api_client.dart';

final cityApiServiceProvider = Provider<CityApiService>((ref) {
  return CityApiService(ref.read(apiClientProvider));
});

class CityApiService {
  final Dio _dio;

  CityApiService(this._dio);

  Future<List<City>> getCities() async {
    final response = await _dio.get('/cities');
    return (response.data as List).map((json) => City.fromJson(json)).toList();
  }

  Future<City> createCity(Map<String, dynamic> cityData) async {
    final response = await _dio.post('/cities', data: cityData);
    return City.fromJson(response.data);
  }

  Future<City> getCityById(String id) async {
    final response = await _dio.get('/cities/$id');
    return City.fromJson(response.data);
  }

  Future<City> getCityByName(String name) async {
    final response = await _dio.get('/cities/by-name/$name');
    return City.fromJson(response.data);
  }
}
