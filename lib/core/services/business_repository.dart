import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/business_api_service.dart';
import '../utils/error_handler.dart';
import '../utils/result.dart';

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepository(ref.read(businessApiServiceProvider));
});

class BusinessRepository {
  final BusinessApiService _api;
  BusinessRepository(this._api);

  Future<Result<Map<String, dynamic>>> businessLogin(String email, String password) async {
    try {
      return Result.success(await _api.businessLogin(email: email, password: password));
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<Map<String, dynamic>>> businessRegister(Map<String, dynamic> data) async {
    try {
      return Result.success(await _api.businessRegister(data));
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<Map<String, dynamic>>> businessForgotPassword(String email) async {
    try {
      return Result.success(await _api.businessForgotPassword(email));
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<Map<String, dynamic>>> businessResetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      return Result.success(await _api.businessResetPassword(token: token, newPassword: newPassword));
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<List<Map<String, dynamic>>>> getMyVenues() async {
    try {
      return Result.success(await _api.getMyVenues());
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<Map<String, dynamic>>> updateVenue(String id, Map<String, dynamic> data) async {
    try {
      return Result.success(await _api.updateVenue(id, data));
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<void>> deleteVenue(String id) async {
    try {
      await _api.deleteVenue(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<Map<String, dynamic>>> getDashboard(String venueId) async {
    try {
      return Result.success(await _api.getDashboard(venueId));
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<Map<String, dynamic>>> getAnalytics(String venueId) async {
    try {
      return Result.success(await _api.getAnalytics(venueId));
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<Map<String, dynamic>>> updateVenueStatus(
    String venueId, {String? busyness, String? vibe, String? liveInfo}) async {
    try {
      return Result.success(await _api.updateVenueStatus(
        venueId, busyness: busyness, vibe: vibe, liveInfo: liveInfo));
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<Map<String, dynamic>>> getVenueStatus(String venueId) async {
    try {
      return Result.success(await _api.getVenueStatus(venueId));
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<List<Map<String, dynamic>>>> getVenueOffers(String venueId) async {
    try {
      return Result.success(await _api.getVenueOffers(venueId));
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<Map<String, dynamic>>> createOffer(Map<String, dynamic> data) async {
    try {
      return Result.success(await _api.createOffer(data));
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<Map<String, dynamic>>> updateOffer(String id, Map<String, dynamic> data) async {
    try {
      return Result.success(await _api.updateOffer(id, data));
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<void>> deleteOffer(String id) async {
    try {
      await _api.deleteOffer(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<Map<String, dynamic>>> toggleOffer(String id) async {
    try {
      return Result.success(await _api.toggleOffer(id));
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }
}
