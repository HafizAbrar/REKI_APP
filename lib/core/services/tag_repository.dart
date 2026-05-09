import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/tag_api_service.dart';
import '../utils/error_handler.dart';
import '../utils/result.dart';

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return TagRepository(ref.read(tagApiServiceProvider));
});

class TagRepository {
  final TagApiService _apiService;
  TagRepository(this._apiService);

  Future<Result<Map<String, dynamic>>> getAllTags() async {
    try {
      return Result.success(await _apiService.getAllTags());
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<List<String>>> getVibeTags() async {
    try {
      return Result.success(await _apiService.getVibeTags());
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<List<String>>> getMusicTags() async {
    try {
      return Result.success(await _apiService.getMusicTags());
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<List<String>>> searchTags(String query) async {
    try {
      return Result.success(await _apiService.searchTags(query));
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }
}
