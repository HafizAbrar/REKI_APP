import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/social_models.dart';
import '../../../core/services/social_repository.dart';

final venueHistoryProvider = StateNotifierProvider<VenueHistoryNotifier,
    AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return VenueHistoryNotifier(ref.read(socialRepositoryProvider));
});

class VenueHistoryNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final SocialRepository _repository;
  VenueHistoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }
  Future<void> load() async =>
      state = AsyncValue.data(await _repository.getHistory());
  Future<void> record(String id, String name) async {
    await _repository.recordVisit(id, name);
    await load();
  }

  Future<void> clear() async {
    await _repository.clearHistory();
    await load();
  }
}

final venueReviewsProvider = StateNotifierProvider.family<VenueReviewsNotifier,
    AsyncValue<List<VenueReview>>, String>((ref, venueId) {
  return VenueReviewsNotifier(ref.read(socialRepositoryProvider), venueId);
});

class VenueReviewsNotifier
    extends StateNotifier<AsyncValue<List<VenueReview>>> {
  final SocialRepository _repository;
  final String venueId;
  VenueReviewsNotifier(this._repository, this.venueId)
      : super(const AsyncValue.loading()) {
    load();
  }
  Future<void> load() async =>
      state = AsyncValue.data(await _repository.getReviews(venueId));
  Future<bool> submit(int rating, String text, bool vibeAccurate) async {
    try {
      final review = await _repository.submitReview(
          venueId: venueId,
          rating: rating,
          text: text,
          vibeAccurate: vibeAccurate);
      state = AsyncValue.data([review, ...state.valueOrNull ?? []]);
      return true;
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
      return false;
    }
  }

  Future<bool> update(
      VenueReview review, int rating, String text, bool vibeAccurate) async {
    try {
      final updated = await _repository.updateReview(
        review: review,
        rating: rating,
        text: text,
        vibeAccurate: vibeAccurate,
      );
      final reviews = [...state.valueOrNull ?? <VenueReview>[]];
      final index = reviews.indexWhere((item) => item.id == review.id);
      if (index >= 0) reviews[index] = updated;
      state = AsyncValue.data(reviews);
      return true;
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
      return false;
    }
  }

  Future<bool> delete(String reviewId) async {
    try {
      await _repository.deleteReview(reviewId);
      state = AsyncValue.data((state.valueOrNull ?? <VenueReview>[])
          .where((item) => item.id != reviewId)
          .toList());
      return true;
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
      return false;
    }
  }

}

final achievementsProvider = FutureProvider<List<Achievement>>(
    (ref) => ref.read(socialRepositoryProvider).getAchievements());
final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>(
    (ref) => ref.read(socialRepositoryProvider).getLeaderboard());
final checkInsProvider = FutureProvider<List<VenueCheckIn>>(
    (ref) => ref.read(socialRepositoryProvider).getCheckIns());
