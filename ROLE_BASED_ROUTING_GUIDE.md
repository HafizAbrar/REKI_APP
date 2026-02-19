# Role-Based Routing Implementation Guide

## Overview
This implementation adds role-based routing using the `/auth/me` endpoint to determine user roles and navigate accordingly.

## Flow

1. **Splash Screen** → Checks for access token
2. **If token exists** → Calls `/auth/me` endpoint
3. **Routes based on role:**
   - `ADMIN` → Admin Dashboard (`/admin-dashboard`)
   - `BUSINESS` → Business Dashboard (`/business-dashboard`)
   - `USER` → Home Screen (`/home`)
4. **If no token** → Signup Screen (`/signup`)

## Changes Made

### 1. User Model (`lib/core/models/user.dart`)
- Added `UserRole` enum: `USER`, `BUSINESS`, `ADMIN`
- Added `role` field to User model
- Added `isActive` field
- Updated `fromJson` to parse role from API response

### 2. Auth Service (`lib/core/services/auth_service.dart`)
- Added `setAccessToken()` method to store token
- Added `fetchCurrentUser()` method to call `/auth/me`
- Integrated with `flutter_secure_storage` for token persistence

### 3. Splash Screen (`lib/features/splash/splash_screen.dart`)
- Added authentication check on init
- Calls `/auth/me` if token exists
- Routes based on user role

### 4. Admin Dashboard (`lib/features/admin/presentation/admin_dashboard_screen.dart`)
- New screen for ADMIN role users
- Shows platform analytics
- Override controls for managing venues, users, offers

### 5. Token Input Screen (`lib/features/auth/presentation/token_input_screen.dart`)
- Testing screen to input JWT token manually
- Calls `/auth/me` and routes based on role
- Access via `/token-input` route

### 6. Router (`lib/core/router/app_router.dart`)
- Added `/admin-dashboard` route
- Added `/token-input` route

## Testing

### Using the Token Input Screen:

1. Run the app: `flutter run`
2. Navigate to `/token-input` route
3. Paste your JWT token (e.g., the one from your curl command)
4. Click "Continue"
5. App will call `/auth/me` and route based on role

### Example Token:
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImhhZml6QGdtYWlsLmNvbSIsInN1YiI6ImVlN2JmYjYyLWFmOGItNGQwMS05NjAzLTJhMGM5Zjc3YzMwOSIsInJvbGUiOiJBRE1JTiIsImlhdCI6MTc3MTQ4OTA1OCwiZXhwIjoxNzcxNDg5OTU4fQ.q3xy45HtgU6JzGBLdcdC_XJfqaVtZ77nRmvmu60sb4U
```

### Expected Response from `/auth/me`:
```json
{
  "id": "ee7bfb62-af8b-4d01-9603-2a0c9f77c309",
  "email": "hafiz@gmail.com",
  "role": "ADMIN",
  "isActive": true,
  "preferences": null,
  "createdAt": "2026-02-18T17:29:09.680Z",
  "updatedAt": "2026-02-19T08:17:39.083Z"
}
```

## API Configuration

Make sure your API base URL is configured in `lib/core/config/env.dart`:
```dart
class Env {
  static const String apiBaseUrl = 'http://18.171.182.71';
}
```

## Role Mapping

| API Role | App Route | Screen |
|----------|-----------|--------|
| `USER` | `/home` | Home Screen (Venue Discovery) |
| `BUSINESS` | `/business-dashboard` | Business Dashboard |
| `ADMIN` | `/admin-dashboard` | Admin Dashboard |

## Notes

- Token is stored in secure storage for persistence
- Auth interceptor automatically adds token to API requests
- Token refresh is handled automatically on 401 errors
- Mock data mode can be disabled by passing `useMockData: false` to AuthService
