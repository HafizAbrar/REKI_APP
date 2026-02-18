# Venue Management API Implementation

Complete venue management system integrated into REKI MVP.

## Files Created

### Core Layer
1. **lib/core/network/venue_api_service.dart**
   - API client for venue endpoints
   - Methods: getAllVenues, createVenue, getVenueById, updateLiveState, createVibeSchedule, getVibeSchedules, getCurrentVibe

2. **lib/core/services/venue_repository.dart**
   - Business logic layer with error handling
   - Returns Result<T> for all operations

3. **lib/core/models/vibe_schedule.dart**
   - Model for vibe schedules

### Feature Layer
4. **lib/features/venues/data/venue_management_provider.dart**
   - Riverpod state management
   - venueManagementProvider: manages venue list
   - venueDetailProvider: fetches individual venue
   - vibeSchedulesProvider: manages vibe schedules
   - currentVibeProvider: gets current vibe

5. **lib/features/venues/presentation/venue_management_screen.dart**
   - Main venue management screen
   - Lists all venues with edit capability

6. **lib/features/venues/presentation/create_venue_screen.dart**
   - Create new venue form
   - Validates and submits venue data

7. **lib/features/venues/presentation/venue_live_state_screen.dart**
   - Update venue busyness and vibe
   - Real-time state management

8. **lib/features/venues/presentation/vibe_schedules_screen.dart**
   - View and create vibe schedules
   - Schedule management interface

## API Endpoints Implemented

```
GET    /venues                           - Get all venues
POST   /venues                           - Create new venue
GET    /venues/{id}                      - Get venue by ID
PATCH  /venues/{id}/live-state           - Update venue live state
POST   /venues/{id}/vibe-schedules       - Create vibe schedule
GET    /venues/{id}/vibe-schedules       - Get vibe schedules
GET    /venues/{id}/current-vibe         - Get current vibe
```

## Usage Example

```dart
// Navigate to venue management
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => VenueManagementScreen()),
);

// Update live state
await ref.read(venueManagementProvider.notifier).updateLiveState(
  venueId,
  busyness: 'Busy',
  currentVibe: 'Party',
);
```

## Integration

- Uses existing Venue model from `lib/core/models/venue.dart`
- Integrates with existing API client and auth interceptor
- Follows project's Riverpod state management pattern
- Uses existing Result<T> utility for error handling

## Features

✅ List all venues
✅ Create new venues
✅ View venue details
✅ Update live state (busyness & vibe)
✅ Manage vibe schedules
✅ Get current vibe
✅ Real-time UI updates
✅ Error handling and loading states
✅ Authentication via existing interceptor
