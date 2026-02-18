# API Routes Integration in Screens

## Implemented API Integrations

### Home Screen (Customer App)
**File:** `lib/features/venues/presentation/home_screen.dart`
- **API Used:** `GET /venues`
- **Provider:** `venueManagementProvider`
- **Functionality:** Loads and displays all venues with real-time data including busyness, vibe, and offers

### Business Update Screen
**File:** `lib/features/business/presentation/business_update_screen.dart`
- **API Used:** `PATCH /venues/{id}/live-state`
- **Provider:** `venueManagementProvider.notifier.updateLiveState()`
- **Functionality:** Updates venue busyness level and current vibe in real-time

### Venue Management Screen
**File:** `lib/features/venues/presentation/venue_management_screen.dart`
- **API Used:** `GET /venues`
- **Provider:** `venueManagementProvider`
- **Functionality:** Lists all venues for management

### Create Venue Screen
**File:** `lib/features/venues/presentation/create_venue_screen.dart`
- **API Used:** `POST /venues`
- **Provider:** `venueManagementProvider.notifier.createVenue()`
- **Functionality:** Creates new venues

### Venue Live State Screen
**File:** `lib/features/venues/presentation/venue_live_state_screen.dart`
- **API Used:** 
  - `GET /venues/{id}` (via venueDetailProvider)
  - `PATCH /venues/{id}/live-state`
- **Functionality:** View and update venue live state

### Vibe Schedules Screen
**File:** `lib/features/venues/presentation/vibe_schedules_screen.dart`
- **API Used:**
  - `GET /venues/{id}/vibe-schedules`
  - `POST /venues/{id}/vibe-schedules`
- **Provider:** `vibeSchedulesProvider`
- **Functionality:** View and create vibe schedules

## API Coverage

✅ GET /venues - Home Screen, Venue Management Screen
✅ POST /venues - Create Venue Screen
✅ GET /venues/{id} - Venue Live State Screen
✅ PATCH /venues/{id}/live-state - Business Update Screen, Venue Live State Screen
✅ POST /venues/{id}/vibe-schedules - Vibe Schedules Screen
✅ GET /venues/{id}/vibe-schedules - Vibe Schedules Screen
✅ GET /venues/{id}/current-vibe - Available via currentVibeProvider

## Data Flow

1. **Customer discovers venues** → GET /venues → Display in home screen
2. **Business updates status** → PATCH /venues/{id}/live-state → Broadcast to customers
3. **Admin creates venue** → POST /venues → Add to system
4. **Business schedules vibes** → POST /venues/{id}/vibe-schedules → Automate vibe changes
5. **System checks current vibe** → GET /venues/{id}/current-vibe → Display active vibe
