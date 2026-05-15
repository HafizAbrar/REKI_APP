import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/business_repository.dart';

// GET /business/venues - Get all my venues
final myVenuesProvider = StateNotifierProvider<MyVenuesNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return MyVenuesNotifier(ref.read(businessRepositoryProvider));
});

class MyVenuesNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final BusinessRepository _repository;
  MyVenuesNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await _repository.getMyVenues();
    state = result.when(
      success: (data) => AsyncValue.data(data),
      failure: (e) => AsyncValue.error(e, StackTrace.current),
    );
  }

  // PUT /business/venues/{id}
  Future<bool> updateVenue(String id, Map<String, dynamic> data) async {
    final result = await _repository.updateVenue(id, data);
    return result.when(success: (_) { load(); return true; }, failure: (_) => false);
  }

  // DELETE /business/venues/{id}
  Future<bool> deleteVenue(String id) async {
    final result = await _repository.deleteVenue(id);
    return result.when(success: (_) { load(); return true; }, failure: (_) => false);
  }
}

// GET /business/dashboard/{venueId}
final businessDashboardProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, venueId) async {
  final result = await ref.read(businessRepositoryProvider).getDashboard(venueId);
  return result.when(success: (data) => data, failure: (e) => throw Exception(e));
});

// Auto-refreshing dashboard stream (polls every 30s)
final liveDashboardProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, venueId) async* {
  final repo = ref.read(businessRepositoryProvider);
  while (true) {
    final result = await repo.getDashboard(venueId);
    yield result.when(success: (d) => d, failure: (_) => {});
    await Future.delayed(const Duration(seconds: 30));
  }
});

// GET /business/analytics/{venueId}
final businessAnalyticsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, venueId) async {
  final result = await ref.read(businessRepositoryProvider).getAnalytics(venueId);
  return result.when(success: (data) => data, failure: (e) => throw Exception(e));
});

// GET /business/venues/{id}/status
final venueStatusProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, venueId) async {
  final result = await ref.read(businessRepositoryProvider).getVenueStatus(venueId);
  return result.when(success: (data) => data, failure: (e) => throw Exception(e));
});

// GET /business/venues/{id}/offers
final businessVenueOffersProvider = StateNotifierProvider.family<BusinessOffersNotifier, AsyncValue<List<Map<String, dynamic>>>, String>((ref, venueId) {
  return BusinessOffersNotifier(ref.read(businessRepositoryProvider), venueId);
});

class BusinessOffersNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final BusinessRepository _repository;
  final String _venueId;

  BusinessOffersNotifier(this._repository, this._venueId) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await _repository.getVenueOffers(_venueId);
    state = result.when(
      success: (data) => AsyncValue.data(data),
      failure: (e) => AsyncValue.error(e, StackTrace.current),
    );
  }

  // POST /business/offers
  Future<bool> createOffer(Map<String, dynamic> data) async {
    final result = await _repository.createOffer(data);
    return result.when(success: (_) { load(); return true; }, failure: (_) => false);
  }

  // PUT /business/offers/{id}
  Future<bool> updateOffer(String id, Map<String, dynamic> data) async {
    final result = await _repository.updateOffer(id, data);
    return result.when(success: (_) { load(); return true; }, failure: (_) => false);
  }

  // DELETE /business/offers/{id}
  Future<bool> deleteOffer(String id) async {
    final result = await _repository.deleteOffer(id);
    return result.when(success: (_) { load(); return true; }, failure: (_) => false);
  }

  // PUT /business/offers/{id}/toggle
  Future<bool> toggleOffer(String id) async {
    final result = await _repository.toggleOffer(id);
    return result.when(success: (_) { load(); return true; }, failure: (_) => false);
  }
}

// PUT /business/venues/{id}/status notifier
final venueStatusNotifierProvider = StateNotifierProvider.family<VenueStatusNotifier, AsyncValue<Map<String, dynamic>?>, String>((ref, venueId) {
  return VenueStatusNotifier(ref.read(businessRepositoryProvider), venueId);
});

class VenueStatusNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final BusinessRepository _repository;
  final String _venueId;

  VenueStatusNotifier(this._repository, this._venueId) : super(const AsyncValue.data(null));

  // Phase 6: added liveInfo for Worker "What's On" updates
  Future<bool> updateStatus({String? busyness, String? vibe, String? liveInfo}) async {
    state = const AsyncValue.loading();
    final result = await _repository.updateVenueStatus(
      _venueId,
      busyness: busyness,
      vibe: vibe,
      liveInfo: liveInfo,
    );
    return result.when(
      success: (data) { state = AsyncValue.data(data); return true; },
      failure: (e) { state = AsyncValue.error(e, StackTrace.current); return false; },
    );
  }
}

// POST /auth/business/login + register + forgot-password notifier
final businessAuthProvider = StateNotifierProvider<BusinessAuthNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  return BusinessAuthNotifier(ref.read(businessRepositoryProvider));
});

class BusinessAuthNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final BusinessRepository _repository;
  BusinessAuthNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _repository.businessLogin(email, password);
    return result.when(
      success: (data) { state = AsyncValue.data(data); return true; },
      failure: (e) { state = AsyncValue.error(e, StackTrace.current); return false; },
    );
  }

  Future<bool> register(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    final result = await _repository.businessRegister(data);
    return result.when(
      success: (data) { state = AsyncValue.data(data); return true; },
      failure: (e) { state = AsyncValue.error(e, StackTrace.current); return false; },
    );
  }

  Future<String?> forgotPassword(String email) async {
    state = const AsyncValue.loading();
    final result = await _repository.businessForgotPassword(email);
    return result.when(
      success: (data) {
        state = AsyncValue.data(data);
        // Extract token from response if backend returns it
        return data['token']?.toString() ??
               data['data']?['token']?.toString() ??
               data['resetToken']?.toString();
      },
      failure: (e) { state = AsyncValue.error(e, StackTrace.current); return null; },
    );
  }

  Future<bool> resetPassword({required String token, required String newPassword}) async {
    state = const AsyncValue.loading();
    final result = await _repository.businessResetPassword(token: token, newPassword: newPassword);
    return result.when(
      success: (_) { state = const AsyncValue.data(null); return true; },
      failure: (e) { state = AsyncValue.error(e, StackTrace.current); return false; },
    );
  }
}
