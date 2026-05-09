import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/offer.dart';
import '../../../core/services/offer_repository.dart';

final offerDetailProvider = FutureProvider.family<Offer, String>((ref, id) async {
  final repository = ref.read(offerRepositoryProvider);
  final result = await repository.getOfferById(id);
  return result.when(
    success: (offer) => offer,
    failure: (error) => throw Exception(error),
  );
});

// Notifier for claim / redeem / wallet-pass actions
final offerActionProvider =
    StateNotifierProvider.family<OfferActionNotifier, OfferActionState, String>(
  (ref, offerId) => OfferActionNotifier(ref.read(offerRepositoryProvider), offerId),
);

class OfferActionState {
  final bool isLoading;
  final Map<String, dynamic>? claimData;   // voucher code + QR from /claim
  final Map<String, dynamic>? redeemData;  // redemption result from /redeem
  final Map<String, dynamic>? walletData;  // wallet pass URL from /wallet-pass
  final String? error;

  const OfferActionState({
    this.isLoading = false,
    this.claimData,
    this.redeemData,
    this.walletData,
    this.error,
  });

  OfferActionState copyWith({
    bool? isLoading,
    Map<String, dynamic>? claimData,
    Map<String, dynamic>? redeemData,
    Map<String, dynamic>? walletData,
    String? error,
  }) =>
      OfferActionState(
        isLoading: isLoading ?? this.isLoading,
        claimData: claimData ?? this.claimData,
        redeemData: redeemData ?? this.redeemData,
        walletData: walletData ?? this.walletData,
        error: error,
      );
}

class OfferActionNotifier extends StateNotifier<OfferActionState> {
  final OfferRepository _repository;
  final String _offerId;

  OfferActionNotifier(this._repository, this._offerId)
      : super(const OfferActionState());

  // POST /offers/{id}/claim
  Future<bool> claim() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.claimOffer(_offerId);
    return result.when(
      success: (data) {
        state = state.copyWith(isLoading: false, claimData: data);
        return true;
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, error: error);
        return false;
      },
    );
  }

  // POST /offers/{id}/redeem
  Future<bool> redeem() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.redeemOffer(_offerId);
    return result.when(
      success: (data) {
        state = state.copyWith(isLoading: false, redeemData: data);
        return true;
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, error: error);
        return false;
      },
    );
  }

  // POST /offers/{id}/wallet-pass
  Future<bool> generateWalletPass() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.generateWalletPass(_offerId);
    return result.when(
      success: (data) {
        state = state.copyWith(isLoading: false, walletData: data);
        return true;
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, error: error);
        return false;
      },
    );
  }
}