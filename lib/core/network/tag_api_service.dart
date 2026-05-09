import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

final tagApiServiceProvider = Provider<TagApiService>((ref) {
  return TagApiService(ref.read(apiClientProvider));
});

class TagApiService {
  final Dio _dio;
  TagApiService(this._dio);

  // GET /tags - Get all vibe + music tags
  Future<Map<String, dynamic>> getAllTags() async {
    final response = await _dio.get('/tags');
    return response.data as Map<String, dynamic>;
  }

  // GET /tags/vibes - Get all vibe tags only
  Future<List<String>> getVibeTags() async {
    final response = await _dio.get('/tags/vibes');
    final data = response.data is Map ? response.data['data'] ?? response.data['tags'] ?? response.data : response.data;
    return List<String>.from(data as List);
  }

  // GET /tags/music - Get all music tags only
  Future<List<String>> getMusicTags() async {
    final response = await _dio.get('/tags/music');
    final data = response.data is Map ? response.data['data'] ?? response.data['tags'] ?? response.data : response.data;
    return List<String>.from(data as List);
  }

  // GET /tags/search - Search tags by name
  Future<List<String>> searchTags(String query) async {
    final response = await _dio.get('/tags/search', queryParameters: {'q': query});
    final data = response.data is Map ? response.data['data'] ?? response.data['tags'] ?? response.data : response.data;
    return List<String>.from(data as List);
  }
}
