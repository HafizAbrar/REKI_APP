# Offers API Implementation

Complete offers management system integrated into REKI MVP.

## Files Created

### Core Layer
1. **lib/core/network/offer_api_service.dart**
   - API client for offer endpoints
   - Methods: getAllOffers, createOffer, getOffersByVenue, getOfferById, redeemOffer, markOfferViewed, markOfferClicked, getOfferStats, updateOfferStatus

2. **lib/core/services/offer_repository.dart**
   - Business logic layer with error handling
   - Returns Result<T> for all operations

### Feature Layer
3. **lib/features/offers/data/offer_management_provider.dart**
   - Riverpod state management
   - offerManagementProvider: manages offer list
   - venueOffersProvider: fetches offers by venue
   - offerDetailProvider: fetches individual offer
   - offerStatsProvider: gets offer statistics

## API Endpoints Implemented

```
GET    /offers                    - Get all offers
POST   /offers                    - Create new offer
GET    /offers/by-venue/{venueId} - Get offers by venue
GET    /offers/{id}               - Get offer by ID
POST   /offers/redeem             - Redeem offer
PATCH  /offers/{id}/view          - Mark offer as viewed
PATCH  /offers/{id}/click         - Mark offer as clicked
GET    /offers/{id}/stats         - Get offer statistics
PATCH  /offers/{id}/status        - Update offer status
```

## Screen Integrations

### Offer Detail Screen
**File:** `lib/features/offers/presentation/offer_detail_screen.dart`
- **APIs Used:**
  - `PATCH /offers/{id}/view` - Auto-tracks when user views offer
  - `PATCH /offers/{id}/click` - Tracks when user clicks redeem
  - `POST /offers/redeem` - Redeems the offer
- **Provider:** `offerDetailProvider`, `offerRepositoryProvider`

### Manage Offers Screen (Business)
**File:** `lib/features/business/presentation/manage_offers_screen.dart`
- **APIs Used:**
  - `GET /offers` - Loads all offers
  - `PATCH /offers/{id}/status` - Toggles offer active/inactive
- **Provider:** `offerManagementProvider`

## Usage Example

```dart
// Load all offers
ref.read(offerManagementProvider.notifier).loadOffers();

// Get offers for a venue
final offers = ref.watch(venueOffersProvider(venueId));

// Redeem an offer
await ref.read(offerRepositoryProvider).redeemOffer(offerId);

// Toggle offer status
await ref.read(offerManagementProvider.notifier).updateOfferStatus(id, true);
```

## Features

✅ List all offers
✅ Create new offers
✅ Get offers by venue
✅ View offer details
✅ Redeem offers
✅ Track offer views
✅ Track offer clicks
✅ Get offer statistics
✅ Toggle offer status (active/inactive)
✅ Real-time UI updates
✅ Error handling and loading states
