import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/tag_repository.dart';

// GET /tags - all vibe + music tags
final allTagsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final result = await ref.read(tagRepositoryProvider).getAllTags();
  return result.when(success: (data) => data, failure: (_) => {});
});

// GET /tags/vibes - vibe tags only
final vibeTagsProvider = FutureProvider<List<String>>((ref) async {
  final result = await ref.read(tagRepositoryProvider).getVibeTags();
  return result.when(success: (data) => data, failure: (_) => []);
});

// GET /tags/music - music tags only
final musicTagsProvider = FutureProvider<List<String>>((ref) async {
  final result = await ref.read(tagRepositoryProvider).getMusicTags();
  return result.when(success: (data) => data, failure: (_) => []);
});

// GET /tags/search - search tags by name
final tagSearchProvider =
    StateNotifierProvider<TagSearchNotifier, AsyncValue<List<String>>>((ref) {
  return TagSearchNotifier(ref.read(tagRepositoryProvider));
});

class TagSearchNotifier extends StateNotifier<AsyncValue<List<String>>> {
  final TagRepository _repository;
  TagSearchNotifier(this._repository) : super(const AsyncValue.data([]));

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    final result = await _repository.searchTags(query);
    state = result.when(
      success: (data) => AsyncValue.data(data),
      failure: (e) => AsyncValue.error(e, StackTrace.current),
    );
  }

  void clear() => state = const AsyncValue.data([]);
}
