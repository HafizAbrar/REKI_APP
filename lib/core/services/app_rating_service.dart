import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

final appRatingServiceProvider =
    Provider<AppRatingService>((ref) => AppRatingService());

/// Phase 8 — ASO in-app rating prompts.
///
/// Strategy: prompt after meaningful positive moments (check-in, redemption,
/// save ×3) with generous cooldown. iOS/Android enforce their own quotas;
/// we additionally respect a 90-day cooldown and a 3× lifetime cap.
class AppRatingService {
  static const _lastPromptKey = 'rating_last_prompt';
  static const _promptCountKey = 'rating_prompt_count';
  static const _positiveActionsKey = 'rating_positive_actions';

  static const _cooldown = Duration(days: 90);
  static const _maxPrompts = 3;
  static const _actionsBeforePrompt = 3;

  /// Call after a positive moment; shows the native prompt when eligible.
  Future<void> recordPositiveMoment() async {
    final prefs = await SharedPreferences.getInstance();
    final actions = (prefs.getInt(_positiveActionsKey) ?? 0) + 1;
    await prefs.setInt(_positiveActionsKey, actions);
    if (actions < _actionsBeforePrompt) return;
    await prefs.setInt(_positiveActionsKey, 0);
    await _maybePrompt(prefs);
  }

  Future<void> _maybePrompt(SharedPreferences prefs) async {
    final count = prefs.getInt(_promptCountKey) ?? 0;
    if (count >= _maxPrompts) return;
    final lastMillis = prefs.getInt(_lastPromptKey);
    if (lastMillis != null) {
      final last = DateTime.fromMillisecondsSinceEpoch(lastMillis);
      if (DateTime.now().difference(last) < _cooldown) return;
    }

    try {
      final review = InAppReview.instance;
      if (await review.isAvailable()) {
        await review.requestReview();
        await prefs.setInt(_promptCountKey, count + 1);
        await prefs.setInt(
            _lastPromptKey, DateTime.now().millisecondsSinceEpoch);
      }
    } catch (e) {
      appLogger.w('In-app review prompt skipped: $e');
    }
  }

  /// "Rate us" menu item — opens the store listing directly.
  Future<void> openStoreListing() async {
    try {
      await InAppReview.instance.openStoreListing(appStoreId: '6750000000');
    } catch (e) {
      appLogger.w('Open store listing failed: $e');
    }
  }
}
